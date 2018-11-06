
import Logger from '~/plugins/starpeace-client/logger.coffee'

PLANE_TYPES = ['plane.adchopper', 'plane.balloon.1', 'plane.balloon.2', 'plane.saucer', 'plane.zeppelin', 'plane.ufo']
PLANE_TYPE_WITH_DIRECTION = new Set(['plane.zeppelin'])
POSITIONS = ['left', 'top', 'right', 'bottom']
DIRECTIONS = {
  'left': {
    'top': 'e',
    'right': 'se',
    'bottom': 's'
  },
  'top': {
    'left': 'w',
    'right': 's',
    'bottom': 'sw'
  },
  'right': {
    'left': 'nw',
    'top': 'n',
    'bottom': 'w'
  },
  'bottom': {
    'left': 'n',
    'top': 'ne',
    'right': 'e'
  }
}
VELOCITY = {
  'n': [-1.5, -1]
  'ne': [0, -1]
  'e': [1.5, -1]
  'se': [1, 0]
  's': [1.5, 1]
  'sw': [0, 1]
  'w': [-1.5, 1]
  'nw': [-1, 0]
}


export default class PlaneManager
  constructor: (@asset_manager, @event_listener, @game_state, @ui_state) ->
    @requested_plane_metadata = false
    @plane_metadata = null
    @loaded_atlases = {}
    @plane_textures = {}

  @velocity_for: (direction, type) ->
    {
      x: (if type.startsWith 'plane.balloon' then .5 else if type == 'plane.saucer' || type == 'plane.ufo' then 2 else 1) * VELOCITY[direction][0]
      y: (if type.startsWith 'plane.balloon' then .5 else if type == 'plane.saucer' || type == 'plane.ufo' then 2 else 1) * VELOCITY[direction][1]
    }

  random_flight_plan: (viewport) ->
    source_position = POSITIONS[Math.floor(Math.random() * POSITIONS.length)]
    possible_target_positions = _.without(POSITIONS, source_position)
    target_position = possible_target_positions[Math.floor(Math.random() * possible_target_positions.length)]
    direction = DIRECTIONS[source_position][target_position]

    type = PLANE_TYPES[Math.floor(Math.random() * PLANE_TYPES.length)]
    type = "#{type}.#{direction}" if PLANE_TYPE_WITH_DIRECTION.has(type)
    plane_info = @plane_metadata.planes[type]

    map_offset_x = (viewport.half_canvas_width + plane_info.w) / @game_state.game_scale
    map_offset_y = (viewport.half_canvas_height + plane_info.h) / @game_state.game_scale

    map_offset_x = (Math.random() - 0.5) * map_offset_x if source_position == 'top' || source_position == 'bottom'
    map_offset_y = (Math.random() - 0.5) * map_offset_y if source_position == 'left' || source_position == 'right'

    map_offset_x = -map_offset_x if source_position == 'right'
    map_offset_y = -map_offset_y if source_position == 'bottom'

    x_direction = if source_position == 'left' then -1 else 1
    y_direction = if source_position == 'bottom' then -1 else 1

    map_offset_x -= x_direction * viewport.tile_width if source_position == 'left' || source_position == 'right'
    map_offset_y -= y_direction * viewport.tile_height if source_position == 'top' || source_position == 'bottom'

    source_map_x = Math.round(@game_state.view_offset_x + viewport.half_tile_width - map_offset_x)
    source_map_y = Math.round(@game_state.view_offset_y - map_offset_y)
    target_map_x = Math.round(@game_state.view_offset_x + viewport.half_tile_width + map_offset_x)
    target_map_y = Math.round(@game_state.view_offset_y + map_offset_y)

    {
      plane_info

      source_map_x
      source_map_y
      target_map_x
      target_map_y

      direction
      type
      velocity: PlaneManager.velocity_for(direction, type)
    }

  has_assets: () ->
    @plane_metadata? && @plane_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_plane_metadata || @plane_metadata?
    @requested_plane_metadata = true
    @asset_manager.queue('metadata.plane', './plane.metadata.json', (resource) =>
      @plane_metadata = resource.data
      plane.key = key for key,plane of @plane_metadata.planes
      @load_plane_atlas(resource.data.atlas)
    )

  load_plane_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource
          @plane_textures[plane.key] = _.map(plane.frames, (frame) -> PIXI.utils.TextureCache[frame]) for plane in @planes_for_atlas(path)
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()

  planes_for_atlas: (atlas_key) ->
    atlas_key = atlas_key.substring(2) if atlas_key.startsWith('./')
    planes = []
    for key,plane of @plane_metadata.planes
      planes.push(plane) if plane.atlas == atlas_key
    planes

  atlas_for: (key) ->
    @plane_metadata.planes[key].atlas

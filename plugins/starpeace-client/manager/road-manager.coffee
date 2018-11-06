
import Logger from '~/plugins/starpeace-client/logger.coffee'

import BuildingZone from '~/plugins/starpeace-client/map/types/building-zone.coffee'
import Road from '~/plugins/starpeace-client/map/types/road.coffee'

X_START = 190
X_END = 250
Y_START = 50
Y_END = 400
X_WITH_ROAD = new Set([X_START, 210, 230, X_END])

DUMMY_CHUNK_DATA = {}
DUMMY_ROAD_DATA = []

for y in [Y_START..Y_END] by 1
  for x in [X_START..X_END] by 1
    continue unless (y % 10 == 0 || X_WITH_ROAD.has(x))
    chunk_x = Math.floor(x/20)
    chunk_y = Math.floor(y/20)
    chunk_key = "#{chunk_x}x#{chunk_y}"
    DUMMY_CHUNK_DATA[chunk_key] = {
      chunk_x: chunk_x
      chunk_y: chunk_y
      width: 20
      height: 20
      data: new Array(20 * 20).fill(false)
    } unless DUMMY_CHUNK_DATA[chunk_key]?

    index = 20 * (y - chunk_y * 20) + (x - chunk_x * 20)
    DUMMY_CHUNK_DATA[chunk_key].data[index] = true
    DUMMY_ROAD_DATA[1000 * y + x] = true

  # y += (Math.round(15 * Math.random()) - 5)


export default class RoadManager
  @DUMMY_ROAD_DATA: DUMMY_ROAD_DATA

  constructor: (@asset_manager, @event_listener, @game_state) ->
    @requested_road_metadata = false
    @road_metadata = null
    @loaded_atlases = {}
    @chunk_promises = {}

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load road chunk at #{chunk_x}x#{chunk_y}")
    @game_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      data = new Array(width, height).fill(false)

      chunk = DUMMY_CHUNK_DATA[key]
      data = chunk.data if chunk?

      setTimeout(=>
        delete @chunk_promises[key]
        done(data)
        @game_state.finish_ajax()
      , 500)

  has_assets: () ->
    @road_metadata? && @road_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_road_metadata || @road_metadata?
    @requested_road_metadata = true
    @asset_manager.queue('metadata.road', './road.metadata.json', (resource) =>
      @road_metadata = resource.data
      overlay.key = key for key,overlay of @road_metadata.roads
      @load_road_atlas(resource.data.atlas)
    )

  load_road_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()

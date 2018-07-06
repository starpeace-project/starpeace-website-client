
import LayerBuildings from '~/plugins/starpeace-client/renderer/map/layer-buildings.coffee'
import LayerGround from '~/plugins/starpeace-client/renderer/map/layer-ground.coffee'
import LayerOverlay from '~/plugins/starpeace-client/renderer/map/layer-overlay.coffee'
import LayerTree from '~/plugins/starpeace-client/renderer/map/layer-tree.coffee'

class MapSprite
  constructor: (@layer, @sprite, @target_width, @target_height) ->

  width: (scale_x) ->
    Math.ceil(scale_x * (@sprite?.texture?.width || 0))

  height: (scale_y) ->
    Math.ceil(scale_y * (@sprite?.texture?.height || 0))

  within_canvas: (scale, canvas_x, canvas_y, canvas_width, canvas_height) ->
    width = @target_width
    height = if @target_height <= 0 then @height(scale) else @target_height
    canvas_x >= -width && (canvas_x < canvas_width + width) &&
      canvas_y >= -height && (canvas_y < canvas_height + height)

  should_render: (scale, canvas_x, canvas_y, canvas_width, canvas_height) ->
    @sprite? && @within_canvas(scale, canvas_x, canvas_y, canvas_width, canvas_height)

  render: (tile_info, counter, scale, canvas_x, canvas_y, tile_width, tile_height) ->
    target_height = if @target_height <= 0 then @height(scale) else @target_height
    if @layer instanceof LayerGround || @layer instanceof LayerTree
      @sprite.visible = true
      @sprite.x = canvas_x - (@target_width - tile_width)
      @sprite.y = canvas_y - (target_height - tile_height)
      @sprite.width = @target_width + 1
      @sprite.height = target_height + 1
      @sprite.tint = if tile_info.has_building_chunk_info then 0xFFFFFF else 0x555555
    else if @layer instanceof LayerOverlay
      @sprite.visible = true
      @sprite.alpha = 0.5
      @sprite.x = canvas_x
      @sprite.y = canvas_y
      @sprite.width = @target_width - 0.25
      @sprite.height = target_height - 0.25
    else if @layer instanceof LayerBuildings
      @sprite.visible = true
      @sprite.x = canvas_x
      @sprite.y = canvas_y - tile_height - (target_height - tile_height)
      @sprite.width = @target_width + 1
      @sprite.height = target_height + 1

    @layer.increment_counter(counter, tile_info)

export default MapSprite

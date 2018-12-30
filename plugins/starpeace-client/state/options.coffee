
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

OPTIONS = [
  {name: 'general.show_header', _default: true},
  {name: 'general.show_fps', _default: true},
  {name: 'general.show_mini_map', _default: true},

  {name: 'music.show_game_music', _default: true},
  {name: 'music.volume_muted', _default: false},

  {name: 'mini_map.zoom', _default: 1},
  {name: 'mini_map.width', _default: 300},
  {name: 'mini_map.height', _default: 200},

  {name: 'renderer.trees', _default: true},
  {name: 'renderer.buildings', _default: true},
  {name: 'renderer.building_animations', _default: true},
  {name: 'renderer.building_effects', _default: true},
  {name: 'renderer.planes', _default: true},

  {name: 'bookmarks.points_of_interest', _default: true},
  {name: 'bookmarks.capital', _default: true},
  {name: 'bookmarks.towns', _default: true},
  {name: 'bookmarks.mausoleums', _default: true},
  {name: 'bookmarks.corporation', _default: true}
]

export default class Options
  constructor: () ->
    @event_listener = new EventListener()

    @options_saved = {}
    @options_current = {}

    @load_state()

  subscribe_options_listener: (listener_callback) -> @event_listener.subscribe('options', listener_callback)
  notify_options_listeners: () -> @event_listener.notify_listeners('options')

  load_state: () ->
    for option in OPTIONS
      saved_value = localStorage.getItem(option.name)
      if saved_value?
        if (typeof option._default is 'number' and isFinite option._default)
          saved_value = parseInt(saved_value)
        else if typeof option._default is 'boolean'
          saved_value = saved_value == 'true'
      @options_saved[option.name] = @options_current[option.name] = if saved_value? then saved_value else option._default
    @notify_options_listeners()

  reset_state: () ->
    for option in OPTIONS
      localStorage.removeItem(option.name)
      @options_current[option.name] = option._default
    @notify_options_listeners()

  save_state: () ->
    for option in OPTIONS
      localStorage.setItem(option.name, @options_current[option.name].toString())
      @options_saved[option.name] = @options_current[option.name]
    @notify_options_listeners()

  can_reset: () ->
    matches_default = true
    for option in OPTIONS
      matches_default = false unless @options_current[option.name] == option._default
    !matches_default

  is_dirty: ->
    matches_saved = true
    for option in OPTIONS
      matches_saved = false unless @options_current[option.name] == @options_saved[option.name]
    !matches_saved

  language: () -> 'EN'

  option: (name) ->
    @options_current[name]

  set_and_save_option: (name, value) ->
    @options_saved[name] = @options_current[name] = value
    localStorage.setItem(name, value.toString())
    @notify_options_listeners()

  toggle: (name) ->
    @options_current[name] = !@options_current[name]
    @notify_options_listeners()

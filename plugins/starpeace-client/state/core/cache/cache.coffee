
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class Cache
  @FIVE_MINUTES: 300000
  @ONE_MINUTE: 60000

  constructor: () ->
    @event_listener = new EventListener()

  reset_multiverse: () -> # nothing to do, may be overriden
  reset_planet: () -> # nothing to do, may be overriden

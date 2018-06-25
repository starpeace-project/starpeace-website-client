
import moment from 'moment'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'
import Account from '~/plugins/starpeace-client/account/account.coffee'

MONTH_SEASONS = {
  0: 'winter'
  1: 'winter'
  2: 'spring'
  3: 'spring'
  4: 'spring'
  5: 'summer'
  6: 'summer'
  7: 'summer'
  8: 'fall'
  9: 'fall'
  10: 'fall'
  11: 'winter'
}

class GameState
  constructor: () ->
    @initialized = false
    @loading = false
    @has_assets = false


    @current_identity_authentication = Identity.from_local_storage()
      .then (identity) =>
        @current_identity = identity
        @current_identity_authentication = null
        console.debug "[starpeace] initialized identity <#{@current_identity}> from localStorage"
      .catch (error) ->
        # FIXME: TODO: figure out error handling
    @current_identity = null
    @current_account_authorization = null
    @current_account = null

    @current_planetary_system = null
    @current_planet = null
    # FIXME: TODO: consider loading state from url parameters (planet_id)


    @view_map_x = 512
    @view_map_y = 512

    @view_offset_x = 3600
    @view_offset_y = 4250

    @game_scale = 0.75

    @current_date = '2235-01-01'
    @current_season = 'winter'

    setInterval(=>
      return unless @initialized
      # FIXME: TODO: remove and get from server
      date = moment(@current_date).add(1, 'day')
      @current_date = date.format('YYYY-MM-DD')
      @current_season = MONTH_SEASONS[date.month()]
    , 250)

  proceed_as_visitor: () ->
    @current_identity.reset_and_destroy() if @current_identity?
    @current_identity = Identity.visitor()
    console.debug "[starpeace] proceeding with visitor identity <#{@current_identity}>"

    @current_account_authorization = Account.for_identity(@current_identity)
      .then (account) =>
        @current_account = account
        @current_account_authorization = null
        console.debug "[starpeace] successfully retrieved account <#{@current_account}> for identity"

      .catch (error) ->
        # FIXME: TODO: figure out error handling


export default GameState

<template lang='pug'>
.overall-container
  .message-header-info
    .sp-profile.profile-column
      .profile-container
        .profile-image
          .profile-none
          .profile-mask

    .info-columns
      .info-row
        span.message-entity.from {{mail.from_entity.name}}
        span.message-entity.to
          span.entity(v-for='(entity,index) in mail.to_entities') {{entity.name}}

        span.message-date {{planet_sent_at}} ({{sent_at}})

      div
        span.is-size-4.has-text-weight-bold {{mail.subject}}

  textarea.mail-body-input.sp-scrollbar(v-model='mail.body' disabled=true)

</template>

<script lang='coffee'>
import moment from 'moment'

export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  computed:
    mail: -> if @client_state.player.selected_mail_id? then @client_state.player.mail_by_id[@client_state.player.selected_mail_id] else null

    sent_at: -> if @mail?.sent_at? then moment.tz(@mail.sent_at, 'UTC').format('YYYY-MM-DD HH:mm z') else ''
    planet_sent_at: -> if @mail?.planet_sent_at? then moment.tz(@mail.planet_sent_at, 'UTC').format('MMM D, YYYY') else ''

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'
@import '~assets/stylesheets/starpeace-menus'

.overall-container
  position: relative

  > .message-header-info
    color: lighten($sp-primary, 10%)
    display: flex
    flex-direction: row
    font-size: 1.15rem
    height: 5.5rem
    padding: .5rem
    width: 100%

    .profile-column
      width: 3rem
      margin-right: .5rem

    .info-columns
      display: flex
      flex-direction: column
      flex-grow: 1

    .info-row
      display: flex
      align-items: center

    .message-entity
      &.from
        border-right: 2px solid darken($sp-dark, 10%)
        font-size: 1.5rem
        padding-right: 1.5rem
        margin-right: 1.5rem

      &.to
        flex-grow: 1

      .entity
        &:not(:last-child)
          margin-right: .5rem

          &::after
            padding-left: .1rem
            content: ';'

    .message-date
      padding-right: .5rem

  .mail-body-input
    background-color: $sp-dark-bg
    border: 0
    color: $sp-primary
    height: calc(100% - 5.5rem - 3rem - .5rem)
    margin: 0
    outline: none
    overflow-y: scroll
    padding: .5rem
    resize: none
    width: 100%


</style>

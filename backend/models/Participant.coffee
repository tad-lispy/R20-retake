# Participant model

mongoose    = require "mongoose"
_           = require "lodash"

valid =
  roles: [
    "reader"
    "student"
    "lawyer"
    "editor"
  ] # TODO: read from config.participants

Participant  = new mongoose.Schema
  name      :
    type      : String
    required  : yes
  roles     :
    type      : [ String ]
    # validate  : [
    #   validator : (roles) -> roles.length
    #   msg       : "At least one role required"
    # ,
    #   validator : (roles) ->
    #     for role in roles
    #       if not (role in valid.roles) then return no
    #     return yes
    #   msg       : "Invalid roles"
    # ]
  can       : {
    ###
    ## Capabilities

    Per request this will be defaulted with role.capabilities,
    and then checked in various contollers and views.
    ###
    type      : Object
    default   : {}
  }
  # TODO: validation (unique values, limit to set)
  bio       : String
  titles    : String
  email     :
    type      : String # TODO: validation (unique values, morphology)
    required  : yes
    unique    : yes
    # validate  :
    #   validator : (emails) -> emails.length
    #   msg       : "At least one email required"

Participant.pre "validate", (next) ->
  @roles  = _.unique @roles.map  (role)  -> do role.toLowerCase
  # @emails = _.unique @emails.map (email) -> do email.toLowerCase
  do next

module.exports = mongoose.model 'Participant', Participant

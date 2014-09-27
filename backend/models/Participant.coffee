# Participant model

mongoose    = require "mongoose"
_           = require "lodash"
config      = require "config-object"

Participant  = new mongoose.Schema
  name      :
    type      : String
    required  : yes
    default   : 'Anonymous'
    trim      : yes
  roles     :
    type      : [ String ]
    default   : [ 'reader' ]
    validate  : [
      validator : (roles) -> roles.length
      msg       : "At least one role required"
    ,
      validator : (roles) ->
        valid = (role for own role of config.get 'participants/roles')
        for role in roles
          if not (role in valid) then return no
        return yes
      msg       : "Invalid roles."
    ]
  capabilities:
    ###
    Per request this will be defaulted with role.capabilities,
    and then checked in various contollers and views.
    ###
    type      : [ String ]
    default   : []
  # TODO: validation (unique values, limit to set)
  bio       :
    type      : String
    trim      : yes
  titles    :
    type      : String
    trim      : yes
  email     :
    type      : String # TODO: validation (unique values, morphology)
    required  : yes
    unique    : yes
    trim      : yes
    # validate  :
    #   validator : (emails) -> emails.length
    #   msg       : "At least one email required"

resolved = config.get "/participants/roles/"
resolveRoleCapabilities = (spec, name, i = 0) ->
  i += 1
  if spec.as?
    spec.can = _.union spec.can, resolveRoleCapabilities resolved[spec.as], spec.as, i
    delete spec.as

  if i is 1 then resolved[name] = spec
  return spec.can


resolveRoleCapabilities spec, role for role, spec of resolved

Participant.virtual('resolved_capabilities').get ->
  capabilities = @capabilities
  for name in @roles
    capabilities = _.union capabilities, resolved[name]?.can
  return capabilities

Participant.methods.can = (capability) ->
  if 'everything' in @resolved_capabilities then yes
  else capability in @resolved_capabilities

Participant.set 'toObject', getters: yes
Participant.set 'toJSON', getters: yes

Participant.pre "validate", (next) ->
  @roles        = _.unique @roles.map  (role)      -> do role.toLowerCase
  @capabilities = _.unique @capabilities.map  (capability)  -> do capability.toLowerCase
  # @emails = _.unique @emails.map (email) -> do email.toLowerCase
  do next

module.exports = mongoose.model 'Participant', Participant

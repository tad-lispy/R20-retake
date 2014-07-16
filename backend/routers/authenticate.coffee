express     = require 'express'
passport    = require 'passport'
_           = require 'lodash'

config      = require 'config-object'
Participant = require '../models/Participant'

# Set up passport
strategies  =
  Local       : require('passport-local').Strategy
  Persona     : require('passport-persona').Strategy

# Disabled. Only persona authentication for now.
# passport.use new strategies.Local
#   usernameField: 'email'
#   (email, password, done) ->
#     { whitelist } = config.participants
#     if not whitelist?.length then done new Error2 "No whitelist specified in configuration."
#     data = _.find whitelist, (participant) ->
#       participant.email is email and participant.password is password
#
#     if data then return done null, new Participant data
#     done null, no, message: "Sorry, that didn't work."
#
#     # TODO: use real DB query
#     # Participant.findOne {email, password}, (error, participant) ->
#     #   if error then return done error
#     #   if participant then return done null, participant
#     #   done null, no, message: "Sorry, that didn't work."

passport.use new strategies.Persona
  audience: config.auth.persona?.audience or "#{config.scheme}://#{config.host}:#{config.port}"
  (email, done) ->
    Participant.findOne {email}, (error, participant) ->
      if error then return done error
      if not participant
        participant = new Participant {email}
        return participant.save done

      done null, participant

passport.serializeUser (user, done)    -> done null, user.email

passport.deserializeUser (email, done) -> Participant.findOne {email}, done


# And now for the main thing (routes)
router   = new express.Router

router.route '/login'
  .post passport.authenticate 'local',
    successRedirect: '/' # TODO: something smarter then that
    failureRedirect: '/'
    # failureFlash   : yes

router.route '/browserid'
  .post passport.authenticate 'persona',
    successRedirect: '/' # TODO: something smarter then that
    failureRedirect: '/'

router.route '/logout'
  .post (req, res) ->
    req.logout()
    res.redirect '/'

module.exports = router

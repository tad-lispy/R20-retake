express     = require 'express'
passport    = require 'passport'
_           = require 'lodash'

config      = require 'config-object'
Participant = require '../models/Participant'

# Set up passport
strategies  =
  # Local       : require('passport-local').Strategy
  Persona     : require('passport-persona').Strategy

passport.use new strategies.Persona
  audience: config.auth.persona?.audience or "#{config.scheme}://#{config.host}:#{config.port}"
  (email, done) ->
    Participant.findOne {email}, (error, participant) ->
      if error then return done error
      if not participant then participant = new Participant {email}

      if participant.email in (config.participants.administrators or [])
        participant.roles.push 'administrator'
      else
        participant.roles.remove 'administrator'

      participant.save done

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

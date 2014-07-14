express     = require 'express'
passport    = require 'passport'
_           = require 'lodash'

config      = require 'config-object'
Participant = require '../models/Participant'

# Set up passport
strategies  =
  Local       : require('passport-local').Strategy

passport.use new strategies.Local
  usernameField: 'email'
  (email, password, done) ->
    console.log "Authenticating", { email, password, participants: config.participants}
    data = _.find config.participants, (participant) ->
      console.log "#{participant.email} is #{email} and #{participant.password} is #{password}"
      participant.email is email and participant.password is password

    if data then return done null, new Participant data
    done null, no, message: "Sorry, that didn't work."

    # TODO: use real DB query
    # Participant.findOne {email, password}, (error, participant) ->
    #   if error then return done error
    #   if participant then return done null, participant
    #   done null, no, message: "Sorry, that didn't work."

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (user, done) ->
  done null, user

# And now for the main thing (routes)
router   = new express.Router

router.route '/login'
  .post passport.authenticate 'local',
    successRedirect: '/' # TODO: something smarter then that
    failureRedirect: '/authenticate'
    # failureFlash   : yes

router.route '/logout'
  .post (req, res) ->
    req.logout()
    res.redirect '/'

module.exports = router

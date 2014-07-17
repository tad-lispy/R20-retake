express = require 'express'
router  = new express.Router
_       = require "lodash"
Error2  = require "error2"

approve = require "../middleware/approve-request"
Participant   = require "../models/Participant"

# List's of stories operations
router.route '/'

  .get (req, res, done) ->
    res.template = require '../templates/participants/list'
    Participant.find (error, participants) ->
      if error then req.next error
      # Hide emails
      participant.email = undefined for participant in participants
      res.serve {participants}

# Single story's operations
router.param 'id', (req, res, done, id) ->
  Participant.findById id, (error, participant) ->
    if error then return done error
    # Hide emails
    if req.user.id isnt participant.id then participant.email = undefined
    req.participant = participant
    do done

router.route '/:id'
  .get (req, res) ->
    res.template = require '../templates/participants/single'
    res.serve participant: req.participant

  .put (req, res) ->
    unless req.user.id is req.participant.id or req.user.can 'edit others profiles'
      req.next Error2 "Forbidden", code: 403

    data = _.pick req.body, [
      'name'
      'bio'
      'roles'
    ]
    req.participant.set data
    req.participant.save (error) ->
      if error then return req.next error
      res.redirect "/participants/#{req.participant.id}"

module.exports = router

express = require 'express'
router  = new express.Router
_       = require "lodash"

approve = require "../middleware/approve-request"
Participant   = require "../models/Participant"

# List's of stories operations
router.route '/'

  .get (req, res, done) ->
    # res.template = require '../templates/participants/list'
    Participant.find (error, participants) ->
      if error then req.next error
      res.serve {participants}

# Single story's operations
router.route '/:id'
  .get (req, res) ->
    # res.template = require '../templates/participants/single'
    Participant.findById req.params.id, (error, participant) ->
      if error then return done error
      res.serve {participant}

  .put (req, res) ->
    res.serve "Update prarticipant's profile"

module.exports = router

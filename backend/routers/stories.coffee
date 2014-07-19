express = require 'express'
router  = new express.Router
_       = require "lodash"

approve = require "../middleware/approve-request"
Story   = require "../models/Story"

# List's of stories operations
router.route '/'

  .get (req, res, done) ->
    res.template = require '../templates/stories/list'
    Story.find (error, stories) ->
      if error then req.next error
      res.serve {stories}

  .post approve('tell a story'), (req, res) ->
    data = _.pick req.body, ['text']
    story = new Story data
    # TODO: Why error?
    story.saveDraft author: req.user.id, (error, draft)->
      res.redirect "/stories/#{story.id}/drafts/#{draft.id}"
    # res.serve {story}

# Single story's operations
router.route '/:story_id'
  .get (req, res) ->
    res.serve 'A single story'
  .put (req, res) ->
    res.serve 'Store a new draft for a story'
  .delete (req, res) ->
    res.serve 'Remove a story, but leave jou rnal'

# Questions' operations
router.route '/:story_id/questions'
  .get (req, res) ->
    res.serve 'A list of questions related to story'
  .post (req, res) ->
    res.serve 'Create a story-question link'

router.route '/:story_id/questions/:question_id'
  .delete (req, res) ->
    res.serve 'Remove a story-question link'

# Journal operations
router.route '/:story_id/apply'
  .post (req, res) ->
    res.serve 'Apply a draft or another a journal operation'

router.route '/:story_id/journal'
  .get (req, res) ->
    res.serve 'Get a list of journal entries for this story'

router.route '/:story_id/journal/:entry_id'
  .get (req, res) ->
    res.serve 'Single journal entry. Can be a draft with apply form.'

module.exports = router

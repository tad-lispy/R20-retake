express = require 'express'
router  = new express.Router
_       = require "lodash"
Error2  = require "error2"
async   = require "async"

approve = require "../middleware/approve-request"

Story       = require "../models/Story"
Participant = require "../models/Participant"

# List's of stories operations
router.route '/'

  .get (req, res) ->
    res.template = require '../templates/stories/list'
    if req.query.search
      Story.search req.query.search, (error, result) ->
        if error then return done error
        return res.serve result

    async.parallel
      stories:     (done) -> Story.find done
      unpublished: (done) -> Story.findUnpublished done
      (error, data) ->
        if error then return req.next error
        res.serve data
    # Story.find (error, stories) ->
    #   if error then req.next error
    #   res.serve {stories}

  .post approve('tell a story'), (req, res) ->
    data = _.pick req.body, ['text']
    story = new Story data
    story.saveDraft author: req.user.id, (error, draft)->
      if error then return done error
      res.redirect "/stories/#{story.id}/journal/#{draft.id}"

router.param 'story_id', (req, res, done, id) ->
  if not /^[0-9a-fA-F]{24}$/.test id then return done new Error2
    code: 422
    name: 'Unprocessable Entity'
    message: "#{_id} is not a valid story identifier. Check your url."

  async.waterfall [
    (done) -> Story.findByIdOrCreate id, done

    (story, done) -> story.findEntries action: 'draft', (error, journal) ->
      # TODO: If story is new and no drafts then 404
      done error, story, journal

    (story, journal, done) -> Participant.populate journal,
      path: 'meta.author'
      (error, journal) ->
        done error, story, journal
  ], (error, story, journal) ->
      if error then return done error
      req.story = story
      req.journal = journal
      done null

router.param 'entry_id', (req, res, done, id) ->
  req.entry = _.find req.journal, (entry) -> entry.id is id
  if not req.entry then return done new Error2
    code: 404
    name: "Not Found"
    message: "Journal entry not found."
  do done

# Single story's operations
router.route '/:story_id'
  .get (req, res) ->
    res.template = require "../templates/stories/single"
    {
      story
      journal
    } = req
    res.serve { story, journal }
  .post (req, res) ->
    data = _.pick req.body, [
      'text'
    ]
    { story } = req
    story.set data
    story.saveDraft author: req.user.id, (error, draft) ->
      if error then return done error
      res.redirect "/stories/#{story.id}/journal/#{draft.id}"

  .delete approve('unpublish a story'), (req, res) ->
    req.story.removeDocument author: req.user.id, (error, entry) ->
      res.redirect 'back'

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
# TODO: own router?

router.route '/:story_id/journal'
  .get (req, res) ->
    res.serve 'Get a list of journal entries for this story'

router.route '/:story_id/journal/:entry_id'
  .get (req, res) ->
    res.template = require "../templates/stories/single"
    data = _.pick req, [
      'story'
      'journal'
      'entry'
    ]
    res.serve data

router.route '/:story_id/journal/:entry_id/apply'
  .post approve('publish a story'), (req, res) ->
    req.entry.apply author: req.user.id, (error, story) ->
      res.redirect "/stories/#{story.id}"

module.exports = router

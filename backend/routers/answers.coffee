# This router is mounted by questions router

express = require 'express'
router  = new express.Router
_       = require "lodash"
Error2  = require "error2"
async   = require "async"

approve = require "../middleware/approve-request"

Answer      = require "../models/Answer"
Question    = require "../models/Question"
Participant = require "../models/Participant"

# List of answers operations
router.route '/'

  .get (req, res) ->
    # res.template = require '../templates/questions/list'
    { question } = req

    if req.query.search
      return Answer.search req.query.search, (error, result) ->
        if error then return done error
        res.serve answers: result
          .map    (hit)      -> hit.document
          .filter (document) -> document.question is question.id

    async.parallel
      answers    : (done) -> Answer.find
        question: question.id
        done

      unpublished: (done) -> Answer.findUnpublished
        'data.question': question._id
        done

      (error, data) ->
        if error then return req.next error
        res.serve data

  .post approve('answer a question'), (req, res) ->
    {
      question
      user
    } = req
    data =
      author   : user.id
      question : question.id
      text     : req.body.text

    async.waterfall [
      # Check if this question is already answer by this author
      (done) ->
        Answer.count author: user._id, question: question._id, done

      (count, done) ->
        if count then return done new Error2
          code: 403
          name: 'Question already answered by this author'
          message: "#{user.name} already answered this question"
        do done

      # Check if answer for this question is already drafted by this author
      (done) ->
        Answer.findUnpublished
          'data.author'  : user._id
          'data.question': question._id
          done

      (unpublished, done) ->
        if unpublished.length then return done new Error2
          code: 403
          name: 'Answer to this question already drafted by this author'
          message: "#{user.name} already drafted an answered to this question"
          draft  : unpublished[0]._id
        do done

      (done) ->
        answer = new Answer data
        answer.saveDraft author: user.id, done
    ],
      (error, draft) ->
        if error then return req.next error
        res.redirect "/questions/#{draft.data.question}/answers/#{draft.data._id}/journal/#{draft.id}"

router.param 'id', (req, res, done, id) ->
  if not /^[0-9a-fA-F]{24}$/.test id then return done new Error2
    code: 422
    name: 'Unprocessable Entity'
    message: "#{id} is not a valid answer identifier. Check your url."

  async.waterfall [
    (done) -> Answer.findByIdOrCreate id, done

    (answer, done) -> answer.populate path: 'author question', done

    (answer, done) -> answer.findEntries action: 'draft', (error, journal) ->
      done error, answer, journal

    (answer, journal, done) ->
      if answer.isNew and not journal.length then return done new Error2
        code   : 404
        name   : "Answer not found"
        message: "There is no answer at this address."

      Participant.populate journal,
        path: 'meta.author'
        (error, journal) ->
          done error, answer, journal

  ], (error, answer, journal) ->

      if error then return done error
      _.extend req, {
        answer
        journal
      }

      done null

router.param 'entry_id', (req, res, done, id) ->
  req.entry = _.find req.journal, (entry) -> entry.id is id
  if not req.entry then return done new Error2
    code   : 404
    name   : "Not Found"
    message: "Journal entry not found."
  do done

# Single answer's operations
router.route '/:id'
  .get (req, res) ->
    res.template = require "../templates/answers/single"
    res.serve _.pick req, [
      'answer'
      'journal'
      'question'
    ]

  # Store new draft of an answer
  .post approve('answer a question'), (req, res) ->
    data = _.pick req.body, [
      'text'
    ]
    {
      answer
      question
    } = req
    answer.set data
    answer.saveDraft author: req.user.id, (error, draft) ->
      if error then return done error
      res.redirect "/questions/#{question.id}/answers/#{answer.id}/journal/#{draft.id}"

  .delete approve('unpublish a story'), (req, res) ->
    req.answer.removeDocument author: req.user.id, (error, entry) ->
      res.redirect 'back'

# # Questions' operations
# router.route '/:id/stories'
#   .get (req, res) ->
#     res.serve 'A list of stories related to question'
#
# # Journal operations
# # TODO: own router?
#
# router.route '/:id/journal'
#   .get (req, res) ->
#     res.serve 'Get a list of journal entries for this question'
#
router.route '/:id/journal/:entry_id'
  .get (req, res) ->
    res.template = require "../templates/answers/single"
    data = _.pick req, [
      'answer'
      'journal'
      'entry'
      'question'
    ]
    res.serve data

router.route '/:id/journal/:entry_id/apply'
  .post approve('publish an answer'), (req, res) ->
    req.entry.apply author: req.user.id, (error, answer) ->
      if error then return req.next error
      {
        question
      } = req
      res.redirect "/questions/#{question.id}/answers/#{answer.id}"

module.exports = router

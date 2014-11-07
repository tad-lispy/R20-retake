express = require 'express'
router  = new express.Router
_       = require "lodash"
Error2  = require "error2"
async   = require "async"

approve = require "../middleware/approve-request"

Question    = require "../models/Question"
Story       = require "../models/Story"
Answer      = require "../models/Answer"
Participant = require "../models/Participant"

# List of questions operations
router.route '/'
  .get (req, res) ->
    res.template = require '../templates/search/results'

    if not req.query.search then return res.redirect '/'

    async.parallel
      questions: (done) -> Question.search req.query.search, done
      stories  : (done) -> Story.search    req.query.search, done
      (error, data) ->
        if error then return req.next error

        # Group questions by id
        questions = {}
        questions[question.document._id] = question for question in data.questions

        # Increase questions score based on stories
        # find all questions abstracted from matching stories
        Question.populate data.stories, 'document.questions', (error, stories) ->
          if error then return res.next error

          for story in stories
            for question in story.document.questions
              score = story.score * 0.1 # TODO: configurable value
              if questions[question._id]?
                # increasing score of existing result item (question) of by fraction of story score
                questions[question._id].score += score
              else
                # setting new question as a result item
                questions[question._id] =
                  document: question
                  score   : score

          questions = _(questions)
            .values()
            .sort 'score'
            .first 9
            .pluck 'document'
            .value()
          async.each questions,
            (question, done) ->
              question.findAnswers (error, answers) ->
                if error then return done error
                question.answers = answers
                do done
            (error) ->
              if error then return req.next error
              res.serve {questions}

router.route '/reindex'
  .post approve('recreate search index'), (req, res) ->
    async.each [
      Story
      Question
    ],
      (model, done) -> model.reindex done
      (error) ->
        if error then return req.next error
        res.redirect '/search'

module.exports = router

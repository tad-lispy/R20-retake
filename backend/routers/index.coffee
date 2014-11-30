# Index (/) route
express  = require 'express'

router = new express.Router

# Tags middleware
router.use require "../middleware/tags"

# List's of stories operations
router.route '/'
  .get (req, res) ->
    res.template = require '../templates/index'
    res.serve message: 'Hello there!'

# Load subrutes
router.use "/#{route}", require "./#{route}" for route in [
  'authenticate'
  'participants'
  'stories'
  'questions'
  # TODO: Enable when Elasticsearch works
  # 'search'
]

module.exports = router

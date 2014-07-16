Error2  = require "error2"

module.exports = (action) ->
  return (req, res, done) ->
    if req.user?.can action then return done null

    done new Error2
      name: "Forbidden"
      code: 403
      message: "You are not allowed to #{action}."
      action: action

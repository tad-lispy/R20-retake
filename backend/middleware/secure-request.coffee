_      = require "lodash"
Error2 = require "error2"

module.exports = (req, res, next) ->
  if req.user? or
     req.method in ['GET', 'HEAD'] or
     req.method is 'POST' and req.url in [
       '/authenticate/login'
       '/authenticate/browserid'
     ]
      return do next

  error = new Error2
    name   : "Unauthorized"
    code   : 401
    message: "You have to authenticate to make this kind of request."

  # TODO: Use below data to allow user to authenticate and retry request
  _.extend error, _.pick req, [
    'method'
    'url'
    'query'
    'body'
  ]

  next error

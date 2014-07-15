Error2 = require "error2"

module.exports = (req, res, next) ->
  if req.user? or
     req.method in ['GET', 'HEAD'] or
     req.method is 'POST' and req.url is '/authenticate/login'
      return do next

  next new Error2
    name   : "Unauthorized"
    code   : 401
    message: "You have to authenticate to make this kind of request (#{req.method})"

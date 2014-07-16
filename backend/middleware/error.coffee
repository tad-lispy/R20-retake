Error2 = require 'error2'

module.exports = (error, req, res, next) ->
  res.template = require '../templates/error'

  if error.name is 'ValidationError'
    console.error "[!] Validation error."
    # That's neat: http://www.bennadel.com/blog/2434-http-status-codes-for-invalid-data-400-vs-422.htm
    error       = new Error2 error
    error.code  = 422

  if error.name is 'CastError'
    console.error "[!] Probabily malformed url."
    error       = new Error2 error
    error.code  = 400

  if (Math.floor error.code / 100) is 4
    # If it's a client error, then let's client deal with it
    return res.serve error.code, {error}

  # Other kind of error.
  console.error "[!] Unhendeld error."
  console.error error
  res.serve 500, new Error2 "Internal Error", "There was an error. Go play."
  # TODO: Shutdown worker

express = require 'express'
app     = new express

app.get '/', (req, res) ->
  res.send 'Hello, R20.'

app.listen 3210

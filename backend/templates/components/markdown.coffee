View      = require "teacup-view"
marked    = require "marked"

marked.setOptions
  breaks      : true
  sanitize    : true
  smartypants : true

module.exports = new View (content) -> @raw marked content

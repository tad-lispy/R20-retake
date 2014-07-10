layout    = require "./layouts/aside"
View      = require "teacup-view"

module.exports = new View
  components: __dirname + "/components"
  (data) ->
    # TODO: fix layout (use teacup view)
    # layout data, =>   
    @markdown data.text




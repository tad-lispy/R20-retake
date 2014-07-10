# FindOrCreate mongoose plugin
#
# Extends Model with a static findByIdOrCreate method
# finds a document or creates new one (without saving it)

module.exports = (schema, options = {}) ->
  schema.statics.findByIdOrCreate = (id, data, callback) ->
    if (not callback) and (typeof data is "function")
      callback  = data
      data      = {}
    # TODO: ability to return a promise if callback is absent

    data._id = id


    @findById id, (error, document) =>
      if error then return callback error
      if not document then document = new @ data
      callback null, document

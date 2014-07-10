I18n      = require "i18n-2"
View      = require "teacup-view"

i18n      = new I18n
  locales: ['pl']

module.exports = new View (text, args...) -> @text i18n.__ text, args...

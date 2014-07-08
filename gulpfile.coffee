gulp       = require 'gulp'

coffee     = require 'gulp-coffee'
mocha      = require 'gulp-mocha'
nodemon    = require 'gulp-nodemon'
# browserify = require 'gulp-browserify'
rename     = require "gulp-rename"
stylus     = require 'gulp-stylus'
del        = require 'del'
path       = require 'path'
# watchify   = require 'watchify'
# source     = require 'vinyl-source-stream'
# coffeeify  = require 'coffeeify'

sources      =
  backend    : [
    'backend/app.coffee'
    'backend/**/*.coffee'
  ]
  scripts    : [
    'frontend/scripts/index.coffee'
    'frontend/scripts/**/*.coffee'
  ]
  styles     : [
    'frontend/styles/R20.styl'
    'frontend/styles/**/*.styl'
  ]
  test       : 'test/**/*.coffee'
  config     : [
    '*.cson'
    'package.json'
  ]

destinations =
  backend    : 'build/backend'
  scripts    : 'build/frontend/scripts'
  styles     : 'build/frontend/styles'

scripts    = []

gulp.task 'clean', (done) ->
  dirs = (directory + '/*' for name, directory of destinations)
  del dirs, done

# gulp.task 'pre-scripts', ->
#   # NOTE: Not being used without browserify process
#   scripts = []
#   gulp
#     .src sources.scripts, read: no
#     .pipe rename (name) ->
#       scripts.push path.relative '.', name.dirname + '/' + name.basename
#       name

gulp.task 'scripts', ->
  gulp
    .src sources.scripts
    .pipe coffee()
    .pipe gulp.dest destinations.scripts

gulp.task 'watch-scripts', ['scripts'], ->
  gulp.watch sources.scripts, ["scripts"]

gulp.task 'styles', ->
  gulp
    .src sources.styles[0]
    .pipe stylus errors: yes
    .pipe gulp.dest destinations.styles

gulp.task 'watch-styles', ['styles'], ->
  gulp.watch sources.styles, ['styles']


gulp.task 'build', ['clean', 'scripts', 'styles'], ->
  gulp
    .src sources.backend
    .pipe coffee()
    .pipe gulp.dest destinations.backend


gulp.task 'watch', ->
  gulp.watch sources.backend, ['build']
  gulp.watch [
    sources.test
    destinations.backend
  ], ['test']

gulp.task 'test', ->
  gulp.src sources.test
    .pipe mocha
      compilers : 'coffee:coffee-script'
      reporter  : 'spec'

gulp.task 'develop', ['watch-scripts', 'watch-styles'], ->
  script = nodemon
    script: sources.backend[0]
    watch : sources.backend
    ext   : 'coffee cson json'
    nodeArgs: [
      '--nodejs'
      '--debug'
    ]

  # Fix to JacksonGariety/gulp-nodemon#26
  gulp.watch sources.backend, -> do script.restart


gulp.task 'default', ['build', 'test', 'watch']

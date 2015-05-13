gulp = require('gulp')
karma = require 'goodeggs-karma'
angularBrowserify = require 'goodeggs-angular-browserify'
path = require 'path'

gulp.task 'test', (done) ->
  karma.run({
    files: [
      path.join(require.resolve('angular'), '..', 'angular.js')
      path.join(require.resolve('angular-mocks'))
      # test files
      'test/**/*.karma.coffee'
    ]
    singleRun: true
  }, done)

gulp.task 'compile', (done) ->
  angularBrowserify.run({
    src: 'src/index.coffee'
    dest: 'lib'
    bundleName: 'index.js'
  }, done)

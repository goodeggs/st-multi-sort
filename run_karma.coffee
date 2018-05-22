karma = require 'goodeggs-karma'
path = require 'path'

karma.run({
  files: [
    path.join(require.resolve('angular'), '..', 'angular.js')
    path.join(require.resolve('angular-mocks'))
    # test files
    'test/**/*.karma.coffee'
  ]
  singleRun: true
})


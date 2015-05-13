###
Like angular orderBy filter, but allows reversing each parameter individually (even getters)
###

angular.module('smart-table').filter 'multiOrderBy', ->
  require 'orderby'

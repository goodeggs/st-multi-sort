###
Generate unique ids to identify each sortable element on the page
###

angular.module('smart-table')

.factory 'stUniqueId', ->
  id = 0

  {
    generate: -> id++
  }

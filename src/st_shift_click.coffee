###
Service to manage shift clicks on elements
###

angular.module('smart-table')

.factory 'stShiftSort', ->
  clickedElements = []

  {
    getCount: ->
      clickedElements.length

    clickElement: (elementId) ->
      if elementId not in clickedElements
        clickedElements.push elementId
      clickedElements.length

    clear: ->
      clickedElements.length = 0
      0
  }

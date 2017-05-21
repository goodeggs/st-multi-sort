###
Service to manage shift clicks on elements
###
angular.module('smart-table')

.factory 'stShiftSort', ->
  clickedElements = []

  {
    getIndex: (elementId) ->
      clickedElements.indexOf(elementId) + 1

    clickElement: (elementId) ->
      if elementId not in clickedElements
        clickedElements.push elementId

    clear: ->
      clickedElements.length = 0
  }

require './multi_order_by'
require './st_element_id'
require './st_shift_click'

ng = angular

angular.module('smart-table').directive 'stMultiSort', [
  'stConfig'
  '$parse'
  '$rootScope'
  'stUniqueId'
  'stShiftSort'
  (stConfig, $parse, $rootScope, stUniqueId, stShiftSort) ->
    restrict: 'A'
    require: '^stTable'
    link: (scope, element, attr, ctrl) ->
      predicate = attr.stMultiSort
      getter = $parse(predicate)
      index = 0
      classAscent = attr.stClassAscent or stConfig.sort.ascentClass
      classDescent = attr.stClassDescent or stConfig.sort.descentClass
      stateClasses = [
        classAscent
        classDescent
      ]
      sortDefault = undefined
      skipNatural = if attr.stSkipNatural != undefined then attr.stSkipNatural else stConfig.skipNatural
      skipNatural = true
      elementId = stUniqueId.generate()
      ctrl.setSortFunction 'multiOrderBy'

      getIndexOfExistingSort = ->
        for i, sortConfig of ctrl.tableState().sort.predicate
          if sortConfig.elementId is elementId
            return i
        return -1

      ###*
      # sort the rows
      # @param {Function | String} predicate - function or string which will be used as predicate for the sorting
      # @param [reverse] - if you want to reverse the order
      ###
      sortBy = (predicate, reverse, holdingShiftKey) ->
        tableState = ctrl.tableState()
        tableState.sort.predicate ?= []

        sort =
          elementId: elementId
          predicate: predicate
          reverse: reverse == true

        do -> # clear existing sort
          indexOfExistingSort = getIndexOfExistingSort()
          if indexOfExistingSort isnt -1
            tableState.sort.predicate.splice indexOfExistingSort, 1

        do -> # add sort class to element
          index = if index % 2 == 0 then 2 else 1
          element.removeClass(stateClasses[index % 2]).addClass stateClasses[index - 1]
          if !holdingShiftKey
            $rootScope.$broadcast 'clearOtherSortClasses', elementId

        tableState.sort.predicate.splice(stShiftSort.getCount(), 0, sort)
        tableState.pagination.start = 0
        ctrl.pipe()


      sort = (holdingShiftKey) ->
        index++
        predicate = if ng.isFunction(getter(scope)) then getter(scope) else attr.stMultiSort
        # predicate = ng.isFunction(getter(scope)) ? getter(scope) : attr.stSort;
        if index % 3 == 0 and ! !skipNatural != true
          #manual reset
          index = 0
          ctrl.tableState().sort = {}
          ctrl.tableState().pagination.start = 0
          ctrl.pipe()
        else
          sortBy(predicate, index % 2 == 0, holdingShiftKey)
        return

      if attr.stSortDefault
        sortDefault = if scope.$eval(attr.stSortDefault) != undefined then scope.$eval(attr.stSortDefault) else attr.stSortDefault

      element.bind 'click', (e) ->
        if predicate
          if e.shiftKey
            stShiftSort.clickElement elementId
          else
            stShiftSort.clear()

          scope.$apply -> sort(e.shiftKey)

      if sortDefault
        index = if sortDefault == 'reverse' then 1 else 0
        sort()

      scope.$on 'clearOtherSortClasses', (e, sortedElementId) ->
        if sortedElementId isnt elementId
          index = 0
          element.removeClass(classAscent).removeClass(classDescent)
]

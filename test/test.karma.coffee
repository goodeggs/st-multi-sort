require 'mocha-sinon'
expect = require('chai').expect

require 'angular-smart-table'
stMultiSort = require '../src'


describe 'stMultiSort Directive', ->
  rootScope = undefined
  scope = undefined
  element = undefined
  tableState = undefined
  #expose table state for tests

  hasClass = (element, classname) ->
    Array::indexOf.call(element.classList, classname) != -1

  trToModel = (trs) ->
    Array::map.call trs, (ele) ->
      {
        name: ele.cells[0].innerHTML
        firstname: ele.cells[1].innerHTML
        age: +ele.cells[2].innerHTML
      }

  beforeEach ->
    angular.mock.module('smart-table', ($compileProvider) ->
      $compileProvider.directive 'dummy', ->
        {
          restrict: 'A'
          require: 'stTable'
          link: (scope, element, attr, ctrl) ->
            tableState = ctrl.tableState()
            return

        }
      return
  )

  describe 'customized stConfig', ->
    beforeEach inject(($compile, $rootScope, stConfig) ->
      oldAscentClass = stConfig.sort.ascentClass
      oldDescentClass = stConfig.sort.descentClass
      stConfig.sort.ascentClass = 'custom-ascent'
      stConfig.sort.descentClass = 'custom-descent'
      rootScope = $rootScope
      scope = $rootScope.$new()
      scope.rowCollection = [
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
      ]
      scope.getters =
        nameLength: (row) ->
          row.name.length
        firstnameLength: (row) ->
          row.age
      template = '<table dummy="" st-table="rowCollection">' + '<thead>' + '<tr><th st-multi-sort="name">name</th>' + '<th st-multi-sort="firstname">firstname</th>' + '<th st-multi-sort="age">age</th>' + '<th st-multi-sort="getters.nameLength">name length</th>' + '<th st-multi-sort="getters.firstnameLength">firstname length</th>' + '</tr>' + '</thead>' + '<tbody>' + '<tr class="test-row" ng-repeat="row in rowCollection">' + '<td>{{row.name}}</td>' + '<td>{{row.firstname}}</td>' + '<td>{{row.age}}</td>' + '</tr>' + '</tbody>' + '</table>'
      element = $compile(template)(scope)
      scope.$apply()
      stConfig.sort.ascentClass = oldAscentClass
      stConfig.sort.descentClass = oldDescentClass
      return
    )

    it 'should customize classes for sorting', ->
      ths = element.find('th')
      angular.element(ths[1]).triggerHandler 'click'
      expect(hasClass(ths[1], 'custom-ascent')).to.equal true
      expect(hasClass(ths[1], 'custom-descent')).to.equal false
      return
    return

  describe 'normal stConfig', ->
    beforeEach inject(($compile, $rootScope) ->
      rootScope = $rootScope
      scope = $rootScope.$new()
      scope.rowCollection = [
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
      ]
      scope.getters =
        nameLength: (row) ->
          row.name.length
        firstnameLength: (row) ->
          row.age

      template = '''
        <table dummy="" st-table="rowCollection">
          <thead>
            <tr>
              <th st-multi-sort="name">name</th>
              <th st-multi-sort="firstname">firstname</th>
              <th st-multi-sort="age">age</th>
              <th st-multi-sort="getters.nameLength">name length</th>
              <th st-multi-sort="getters.firstnameLength">firstname length</th>
            </tr>
          </thead>
          <tbody>
            <tr class="test-row" ng-repeat="row in rowCollection">
              <td>{{row.name}}</td>
              <td>{{row.firstname}}</td>
              <td>{{row.age}}</td>
            </tr>
          </tbody>
        </table>
      '''

      element = $compile(template)(scope)
      scope.$apply()
      return
    )

    it 'should sort by clicked header', ->
      ths = element.find('th')
      actual = undefined
      angular.element(ths[1]).triggerHandler 'click'
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal true
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal false
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
      ]
      return

    it 'should revert on the second click', ->
      ths = element.find('th')
      actual = undefined
      angular.element(ths[1]).triggerHandler 'click'
      angular.element(ths[1]).triggerHandler 'click'
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal false
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal true
      expect(actual).to.deep.equal [
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
      ]
      return

    it 'should sort by multiple columns when shift clicking', ->
      ths = element.find('th')
      angular.element(ths[0]).triggerHandler 'click'
      shiftClick = jQuery.Event('click')
      shiftClick.shiftKey = true
      angular.element(ths[2]).triggerHandler shiftClick
      actual = trToModel(element.find('tr.test-row'))
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
      ]
      angular.element(ths[2]).triggerHandler shiftClick
      actual = trToModel(element.find('tr.test-row'))
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
      ]
      return

    it 'should sort by multiple columns when ctrl clicking', ->
      ths = element.find('th')
      angular.element(ths[0]).triggerHandler 'click'
      shiftClick = jQuery.Event('click')
      shiftClick.ctrlKey = true
      angular.element(ths[2]).triggerHandler shiftClick
      actual = trToModel(element.find('tr.test-row'))
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
      ]
      angular.element(ths[2]).triggerHandler shiftClick
      actual = trToModel(element.find('tr.test-row'))
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
      ]
      return




    it 'should support getter function as predicate', ->
      ths = element.find('th')
      actual = undefined
      angular.element(ths[3]).triggerHandler 'click'
      actual = trToModel(element.find('tr.test-row'))
      expect(actual).to.deep.equal [
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
      ]
      return

    it 'should switch from getter function to the other', ->
      ths = element.find('th')
      actual = undefined
      angular.element(ths[3]).triggerHandler 'click'
      expect(hasClass(ths[3], 'st-sort-ascent')).to.equal true
      expect(hasClass(ths[4], 'st-sort-ascent')).to.equal false
      angular.element(ths[4]).triggerHandler 'click'
      expect(hasClass(ths[3], 'st-sort-ascent')).to.equal false
      expect(hasClass(ths[4], 'st-sort-ascent')).to.equal true

    it 'should reset its class if another element clicked', ->
      ths = element.find('th')
      angular.element(ths[1]).triggerHandler 'click'
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal true
      angular.element(ths[2]).triggerHandler 'click'
      scope.$apply()
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal false
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal false
      return

    it 'should sort by default a column', inject(($compile) ->
      template = '<table dummy="" st-table="rowCollection">' + '<thead>' + '<tr><th st-multi-sort="name">name</th>' + '<th st-sort-default="true" st-multi-sort="firstname">firstname</th>' + '<th st-multi-sort="getters.age">age</th>' + '</tr>' + '</thead>' + '<tbody>' + '<tr class="test-row" ng-repeat="row in rowCollection">' + '<td>{{row.name}}</td>' + '<td>{{row.firstname}}</td>' + '<td>{{row.age}}</td>' + '</tr>' + '</tbody>' + '</table>'
      element = $compile(template)(scope)
      scope.$apply()
      ths = element.find('th')
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal true
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal false
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
      ]
      return
    )

    it 'should evaluate st sort default and consider a falsy value', inject(($compile) ->
      scope.column = reverse: false
      template = '<table dummy="" st-table="rowCollection">' + '<thead>' + '<tr><th st-multi-sort="name">name</th>' + '<th st-sort-default="column.reverse" st-multi-sort="firstname">firstname</th>' + '<th st-multi-sort="getters.age">age</th>' + '</tr>' + '</thead>' + '<tbody>' + '<tr class="test-row" ng-repeat="row in rowCollection">' + '<td>{{row.name}}</td>' + '<td>{{row.firstname}}</td>' + '<td>{{row.age}}</td>' + '</tr>' + '</tbody>' + '</table>'
      element = $compile(template)(scope)
      scope.$apply()
      ths = element.find('th')
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal false
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal false
      expect(actual).to.deep.equal [
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
      ]
      return
    )

    it 'should sort by default a column in reverse mode', inject(($compile) ->
      template = '<table dummy="" st-table="rowCollection">' + '<thead>' + '<tr><th st-multi-sort="name">name</th>' + '<th st-sort-default="reverse" st-multi-sort="firstname">firstname</th>' + '<th st-multi-sort="getters.age">age</th>' + '</tr>' + '</thead>' + '<tbody>' + '<tr class="test-row" ng-repeat="row in rowCollection">' + '<td>{{row.name}}</td>' + '<td>{{row.firstname}}</td>' + '<td>{{row.age}}</td>' + '</tr>' + '</tbody>' + '</table>'
      element = $compile(template)(scope)
      scope.$apply()
      ths = element.find('th')
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal false
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal true
      expect(actual).to.deep.equal [
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
      ]
      return
    )

    it 'should skip natural order', inject(($compile) ->
      template = '<table dummy="" st-table="rowCollection">' + '<thead>' + '<tr><th>name</th>' + '<th st-skip-natural="true" st-multi-sort="firstname">firstname</th>' + '<th>age</th>' + '</tr>' + '</thead>' + '<tbody>' + '<tr class="test-row" ng-repeat="row in rowCollection">' + '<td>{{row.name}}</td>' + '<td>{{row.firstname}}</td>' + '<td>{{row.age}}</td>' + '</tr>' + '</tbody>' + '</table>'
      element = $compile(template)(scope)
      scope.$apply()
      ths = element.find('th')
      th1 = angular.element(ths[1])
      th1.triggerHandler 'click'
      th1.triggerHandler 'click'
      th1.triggerHandler 'click'
      scope.$apply()
      actual = trToModel(element.find('tr.test-row'))
      expect(hasClass(ths[1], 'st-sort-ascent')).to.equal true
      expect(hasClass(ths[1], 'st-sort-descent')).to.equal false
      expect(actual).to.deep.equal [
        {
          name: 'Faivre'
          firstname: 'Blandine'
          age: 44
        }
        {
          name: 'Leponge'
          firstname: 'Bob'
          age: 22
        }
        {
          name: 'Francoise'
          firstname: 'Frere'
          age: 99
        }
        {
          name: 'Renard'
          firstname: 'Laurent'
          age: 66
        }
        {
          name: 'Renard'
          firstname: 'Olivier'
          age: 33
        }
      ]
      return
    )
    return
  return

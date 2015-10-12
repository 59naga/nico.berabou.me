# Dependencies
app= angular.module process.env.APP

# Private
app.filter 'selectGenres',($rootScope)->
  (items)->
    services= (service for service,enable of $rootScope.$storage.services when enable)

    for item in items when item.type in services
      item

# Public
app.run ($window)->
  $window.scrollTo 0,0 # infinity-scrollの誤作動防止

app.controller 'top',(
  nicovideo
  nicovideoServices
  found

  $timeout
  CountUp

  $rootScope
  $state
  $stateParams
  $mdDialog
)->
  found.all.items.sort (a,b)->
    (new Date b.start_time).getTime() - (new Date a.start_time).getTime()

  $rootScope.details= found.services

  @items?= []
  $rootScope.busy= yes
  $timeout =>
    $rootScope.title= $stateParams.query
    countup= new CountUp (document.querySelector '#countup'),0,found.all.total
    countup.start()

    @items.push item for item in found.all.items

    $timeout =>
      $rootScope.busy= no if found.all.items.length
    ,500

  page= ~~($stateParams.page)
  @next= ->
    return if $rootScope.busy
    $rootScope.busy= yes

    $stateParams.page= ~~($stateParams.page) + 1
    $state.transitionTo $state.current.name,$stateParams,{notify:false,reload:false}

    nicovideo.fetchAll $stateParams.query,$stateParams.page
    .then ({all})=>
      return if all.items.length is 0

      all.items.sort (a,b)->
        (new Date b.start_time).getTime() - (new Date a.start_time).getTime()

      @items.push item for item in all.items

    .then =>
      $timeout =>
        $rootScope.busy= no
      ,500

  @preview= (event,item)->
    $mdDialog.show 
      parent: angular.element document.body
      targetEvent: event

      locals: item
      bindToController: yes
      controllerAs: 'vm'
      controller: ($scope,$state,$mdDialog)->
        $scope.cancel= ->
          $mdDialog.hide()

        return

      template: require './preview.jade'

      clickOutsideToClose: yes
      focusOnOpen: yes

  # http://codepen.io/59naga/pen/LpLzOO
  @getScale= (i,viewport)->
    switch viewport
      when 'small'
        switch i % 25
          when 0 then 2
          when 14 then 3
          else 1

      when 'medium'
        # return 2 if i is 1681 # adjust for 1700 (same below)
        # return 1 if i > 1680
        switch i % 75
          when 0 then 3
          when 13 then 2
          when 31 then 4
          when 60 then 2
          else 1

      when 'large'
        # return 3 if i is 1645
        # return 3 if i is 1667
        # return 1 if i > 1645
        switch i % 193
          when 0 then 4
          when 12 then 2
          when 47 then 3
          when 62 then 2
          when 88 then 2
          when 102 then 5
          when 154 then 2
          else 1

      when 'huge'
        # return 2 if i is 1683
        # return 1 if i > 1680
        switch i % 221
          when 0 then 5
          when 27 then 4
          when 61 then 2
          when 81 then 3
          when 98 then 4
          when 110 then 2
          when 135 then 4
          else 1

  return

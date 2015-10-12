# Environment
process.env.APP?= 'nico.berabou.me'
STEP= 100

# Boot
angular.element document
.ready ->
  angular.bootstrap document,[process.env.APP]

# Setup app
require './app'
require './app/root'
require './top'

app= angular.module process.env.APP

# Routes
app.config ($urlRouterProvider)->
  $urlRouterProvider.when '','/初音ミク'

app.config ($stateProvider)->
  $stateProvider.state 'root',
    url: ''

    template: (require './app/root.jade')()
    controller: 'root'
    controllerAs: 'root'

app.factory 'nicovideo',(Promise,$rootScope,$nicovideo,$sce)->
  fetchAll: (query,page)->
    all=
      total: 0
      items: []

    promises=
      for name,enable of $rootScope.$storage.services when $nicovideo[name]
        do (name)->
          options= {}
          options.from= STEP* ~~(page)
          options.size= STEP
          if not options.filters? and name is 'live'
            options.filters= []
            options.filters.push
              type: 'range'
              field: 'start_time'
              to: moment().format('YYYY-MM-DD HH:hh:ss')
              include_lower: yes

          $nicovideo[name] query,options
          .then ({total,items})->
            all.total+= ~~total

            useCache= name in ['manga']
            for item in items
              all.items.push item

              delete item.thumbnail_url if item.thumbnail_url is false
              item.type= name
              item.useCache= useCache
              item.title= item.title.replace /&amp;/g,'&' if item.title
              item.description= angular.element('<div>'+item.description+'</div>').text()
              item.description= $sce.trustAsHtml item.description

            {name,total,items}

          .catch console.error

    Promise.settle promises
    .then (promiseInspections)->
      services=
        for promiseInspection in promiseInspections
          if promiseInspection.isFulfilled()
            promiseInspection.value()
          else
            promiseInspection.reason()

      {all,services}

app.config ($stateProvider)->
  $stateProvider.state 'root.top',
    url: '/:query?page'
    template: (require './top/index.jade')()
    controller: 'top'
    controllerAs: 'vm'
    resolve:
      found: ($stateParams,nicovideo)->
        if $stateParams.query.length <= 0
          $stateParams.query= '初音ミク'

        nicovideo.fetchAll $stateParams.query,$stateParams.page

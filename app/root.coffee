# Dependencies
app= angular.module process.env.APP

app.controller 'root',(
  $state

  $mdUtil
  $mdSidenav
)->
  @query= $state.params.query
  @find= ->
    $state.go 'root.top',{query:@query,page:0},{reload:yes}

  @toggle= $mdUtil.debounce ->
    $mdSidenav 'left'
      .toggle()
      .then ->
        null
  ,200

  return

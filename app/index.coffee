# Dependencies
Promise= require 'bluebird'

app= angular.module process.env.APP,[
  'ui.router'
  'ngMaterial'
  'ngAnimate'
  'cfp.loadingBar'
  'angularMoment'

  'ngLoadingSpinner'
  'infinite-scroll'

  'ngStorage'
]

# Environment
app.constant 'nicovideoServices',[
  'video'
  'illust'
  'manga'
  'book'
  'live'
  'channel'
  'news'
]
app.run ($rootScope,$localStorage,nicovideoServices,$state)->
  nicovideo= {}
  nicovideo.services= {}
  nicovideo.services[service]= on for service in nicovideoServices

  $rootScope.$storage= $localStorage.$default({nicovideo}).nicovideo

app.config ($mdThemingProvider)->
  $mdThemingProvider.theme 'light'
  .primaryPalette 'teal'
  .accentPalette 'grey'
  
  $mdThemingProvider.theme 'default'
  .primaryPalette 'teal'
  .accentPalette 'grey'
  .dark()

  $mdThemingProvider.theme 'dark'
  .primaryPalette 'teal'
  .accentPalette 'grey'
  .dark()
  return

# Disable debug for produciton
app.config ($logProvider)->
  $logProvider.debugEnabled process.env.NODE_ENV isnt 'production'

# Add DIs
app.constant '$nicovideo',nicovideo
app.constant 'CountUp',CountUp
app.constant 'Promise',Promise

# Add directives
app.directive 'fetchThumbnailUrl',($window,$http)->
  scope:
    item: '=fetchThumbnailUrl'

  link: (scope,element,attrs)->
    url= scope.item.thumbnail_url or scope.item.community_icon or 'http://icon.nimg.jp/404.jpg'

    unless scope.item.thumbnail_url and scope.item.useCache
      if attrs.fetchThumbnailType is 'src'
        element.attr 'src',url

      else
        element.text """
          #item_#{scope.item.cmsid}::after{
            background-image: url(#{url})
          }
        """

      return

    api= $window.location.origin+'/fetch-thumbnail-url/'

    $http.get api+scope.item.url
    .catch -> {data:url}
    .then (response)->
      if attrs.fetchThumbnailType is 'src'
        element.attr 'src',response.data

      else
        element.text """
          #item_#{scope.item.cmsid}::after{
            background-image: url(#{response.data})
          }
        """

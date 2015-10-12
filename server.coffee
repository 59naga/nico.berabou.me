# Dependencies
bluebird= require 'bluebird'
express= require 'express'
dhs= require 'difficult-http-server'
request= bluebird.promisify(require 'request')
cheerio= require 'cheerio'
lowdb= require 'lowdb'

# Environment
process.env.APP?= 'nico.berabou.me'
process.env.PORT?= 59798
cwd= __dirname

if process.env.NODE_ENV is 'production'
  lowdb.stringify= (obj)-> JSON.stringify obj
db= lowdb 'db.json'

# Setup express
app= express()
app.use dhs {cwd,bundleExternal:yes}
app.use '/fetch-thumbnail-url/',(req,res)->
  # eg. http://localhost:59798/fetch-thumbnail-url/http://seiga.nicovideo.jp/comic/18156
  uri= req.url.slice 1

  cache= db('cache').find {id:uri}
  return res.end cache.url if cache

  request uri
  .spread (response,body)->
    $= cheerio.load body
    url= ($ '.main_visual img').attr 'src'
    url?= ($ '.thumbnail img').attr 'src'
    throw new Error 'no thumbnail url found at '+uri unless url

    db('cache').push {id:uri,url}
    res.end url

  .catch (error)->
    res.status(404).end error.message

# Boot
app.listen process.env.PORT,->
  console.log 'Server running at http://localhost:%s',process.env.PORT

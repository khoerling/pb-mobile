require 'LiveScript'

global.cl = console.log
global.cw = console.warn
global.db = require \./db
global.React = require \react/addons
global.ReactRouter = require \react-router-component
global.ReactAsync = require \react-async
global <<< db
global <<< require \prelude-ls
global.Promise = require \bookshelf/node_modules/bluebird
global.moment = require \moment
global.routes = require '../shared/routes'

global.reload = (m) ->
  paths = require.resolve m
  if is-type \String, paths
    delete require.cache[paths]
  else
    paths.for-each (p) -> delete require.cache[p]
  require m

# vim:fdm=indent

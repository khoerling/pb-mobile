global <<< require \prelude-ls
global.React = require \react/addons
global.ReactRouter = require \react-router-component
global.ReactAsync = require \react-async
global.moment = require \moment

require! {
  express
  \pretty-error
  connect: 'express/node_modules/connect'
  \./app/server/mw
  \./app/server/api-v1
  \./app/server/pages
  \./app/server/logs
}

pe = new pretty-error!

app = express!
app.use connect.logger(immediate: false, format: logs.dev-format)
app.use express.static "#__dirname/public"
app.use \/api/v1, api-v1
app.use pages

app.use (err, req, res, next) ->
  console.error(pe.render err) # format express exceptions
  res.send 500, err.message

@start-server = (port, path, cb) ->
  <~ pe.start # format uncaught exceptions
  app.listen port
  cb null

not-first-time = 0
process.on \SIGUSR2, ->
  if not-first-time++
    console.warn '[restarting]'
    process.exit 0

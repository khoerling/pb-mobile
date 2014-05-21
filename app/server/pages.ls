require! {
  \express
  \./db
  \./mw
  '../shared/routes'
}

{r,rn} = routes

app = module.exports = express!

app.set 'view engine', 'jade'
app.set 'views', 'app/views'


app.get \/favicon.ico, (req, res) -> res.send 404

app.get r(\Homepage),
  mw.common-locals,
  ((req, res, next) ->
    res.locals.title = 'Forward ideas.  Simple tools.  Groundbreaking software. '
    res.locals.count = 1
    next!),
  mw.react-or-json


# vim:fdm=indent

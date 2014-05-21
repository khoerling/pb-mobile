require! {
  \express
  \express/node_modules/connect
  \./db
  \pretty-error
  \sprintf
  \change-case
  Promise: \bluebird
}

pe = new pretty-error!

# https://github.com/senchalabs/connect/wiki/Connect-3.0
urlencoded = connect.urlencoded!
json       = connect.json!

app = module.exports = express!

app.set 'view engine', 'jade'
app.set 'views', 'app/views'

get-one-fn = (Model) ->
  (req, res, next) ->
    id = req.param \id
    m  = new Model {id}

    # reset relations at every request & add any extras
    rel = keys db.__relations[db.util.class-name Model::table-name]
    if extra = req.param \relations
      if typeof! extra is \Array
        rel = rel ++ extra
      else
        rel.push extra
    m.fetch with-related: rel .then((r) ->
      if r
        res.json m.to-JSON!
      else
        res.json 404, {}
    ).catch((err) ->
      console.warn err.stack
      res.json 404, {errors:["#{Model::table-name} #id not found"]}
    )

# URL Query Parameters
#
# limit=N
# offset=M
# orderBy=field
#   This may be repeated multiple times to do a multilevel sort.
#   If the sort field has a "-" at the end of it, it is interpreted to mean DESCending order.
#
# Example:
#   curl --user ICE:ice,ice,baby7 'http://localhost:3333/api/v1/servers?limit=2&offset=0&orderBy=name-&orderBy=id&orderBy=monthly_cost-'
#
# Becomes:
#   select `Server`.* from `Server` order by `name` DESC, `id` asc, `monthly_cost` DESC limit 2 offset 0
get-many-fn = (Model) ->
  var collection
  relations = keys db.__relations[db.util.class-name Model::table-name]
  (req, res, next) ->
    collection := Model.collection! # start with a fresh collection object every request
    collection.query((query) ->
      if req.query.limit
        query.limit req.query.limit
      if req.query.offset
        query.offset req.query.offset
      if order-by = req.query.order-by
        if typeof! order-by is \String then order-by = [ order-by ]
        order-by
        |> map -> if it.match /-$/ then [it.replace(/-$/, ''), \DESC] else [it]
        |> each ->
          query.order-by ...it
      else
        query.order-by \id
    ).fetch(with-related: relations).then((collection) ->
      res.json collection.toJSON!
    ).catch(-> # failure
      console.error(pe.render it)
      res.json 400, {errors:["Unable to list #{Model::table-name}"]}
    )

post-fn = (Model) ->
  (req, res, next) ->
    check-existence = (id, cb) ->
      if not id then return cb null
      m = new Model {id}
      m.fetch!done cb
    exists <- check-existence req.body.id
    if exists
      return res.json 400, {errors:["#{Model::table-name} #{req.body.id} already exists."]}
    m = new Model
    m.set req.body
    rel = keys db.__relations[Model::table-name]
    m.load rel .then(~>
      m.validate-async!
    ).then((errors) ~>
      if errors
        throw errors
      else
        m.save!
    ).then(~>
      res.json 201, m.to-JSON!
    ).catch((errors) ~>
      if errors instanceof Error
        console.error(pe.render errors)
      else
        console.error errors
      res.json 400, errors: flatten values(errors)
    )

put-fn = (Model) ->
  (req, res, next) ->
    id = req.param \id
    m = new Model {id}
    <- m.fetch!then
    m.set req.body
    m.validate-async!then((errors) ~>
      if errors
        throw errors
      else
        m.save!
    ).then(~>
      res.json 202, m.to-JSON!
    ).catch((errors) ~>
      if errors instanceof Error
        console.error(pe.render errors)
      else
        console.error errors
      res.json 400, errors: flatten values(errors)
    )

delete-fn = (Model) ->
  (req, res, next) ->
    id = req.param \id
    m = new Model {id}
    m.destroy!then(-> # success
      res.json 202, m.to-JSON!
    ).catch(-> # failure
      console.error(pe.render it)
      res.json 400, {errors:['Unable to delete']}
    )

app.resource-fns = (Model) ->
  {
    get-one  : get-one-fn Model
    get-many : get-many-fn Model
    post     : post-fn Model
    put      : put-fn Model
    delete   : delete-fn Model
  }

app.resource = (Model, middlewares=[]) ->
  for method, fn of app.resource-fns(Model)
    switch method
    | \getOne   => app.get     "/#{db.util.route-name Model::table-name}/:id", [...middlewares, fn]
    | \getMany  => app.get     "/#{db.util.route-name Model::table-name}",     [...middlewares, fn]
    | \post     => app.post    "/#{db.util.route-name Model::table-name}",     [urlencoded, json, ...middlewares, fn]
    | otherwise => app[method] "/#{db.util.route-name Model::table-name}/:id", [urlencoded, json, ...middlewares, fn]

for Model in db.__tables |> values |> map (-> db[db.util.class-name it])
  if not Model::table-name.match /2/
    app.resource Model

## Custom Routes
app.get '/forums/:id/threads', (req, res, next) ->
  id = req.param \id
  forum = new db.Forum {id}
  forum.threads!then((threads) ->
    res.json threads.toJSON!
  )

## Helper FNs

# vim:fdm=indent

window <<< lsrequire \prelude-ls
window.storage = {} <<< # to better use local storage
  del: (k)    -> local-storage.remove-item k
  get: (k)    -> try local-storage.get-item k |> JSON.parse
  has: (k)    -> local-storage.has-own-property k
  set: (k, v) -> local-storage.set-item k, JSON.stringify v

require! \../shared/react/App

# get part just starting with /
function abs-uri href
  parser = document.create-element \a
  parser <<< {href}
  parser.pathname + parser.search

function update-layout locals
  $ '.header .title' .html locals.title
  $ \.nav # update nav
    ..find \.active .remove-class \active
    ..find ".#{locals.type}" .add-class \active

# intialize App on client-side
$(->
  window.app = React.render-component App({ path: window.location.pathname, locals: window.locals }), ($ \#react).0
  update-layout locals

  # hijack surf clicks (for now)
  $ document .on \click, \.surf, (ev) ->
    ev.prevent-default!
    window.app.navigate ($ ev.current-target .attr \href), {}
)

# vim:fdm=indent

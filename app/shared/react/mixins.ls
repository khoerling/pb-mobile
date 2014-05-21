export FormHelpers =
  update: (ev, id) -> # update state
    if id?index-of(\.) > -1 # id is a path, so go one level deep
      [key, elm] = id.split \.
      new-state = {"#key":{}} <<< @state    # default
      new-state[key][elm] = ev.target.value # update
      @set-state new-state
    else
      @set-state "#id": ev.target.value

  update-fn: (id) ->
    (ev) ~>
      @update ev, id

  on-enter: (cb) ->
    (ev) ~>
      if ev.native-event.key-code is 13
        cb ev

  report-error: (jqxhr, status, error) ->
    add = $.gritter.add

    try # parse json
      res = JSON.parse jqxhr.response-text
    catch
      add title: e.message, text: e.stack

    if status is \error # consolidate
      add title: 'Try Again!', text: if res?errors?length then res.errors.join \<br> else 'Double-check all form inputs'
      console.warn res?errors
    else
      res?errors |> each -> add title: \Error, text: it


export InitialStateAsync =
  get-initial-state-async: (cb) ->
    path = "#{window.location.pathname}#{if window.location.search then "?#{window.location.search}" else ''}"
    $.ajax(
      data-type: \json
      accepts:
        json: \application/json
      url: path
      success: (locals) ->
        #console.log \get-initial-state-async, locals
        $ 'head title' .html "#{locals.title} | ICEmail"
        cb null, locals
      error: (jqxhr, status, error) ->
        $.gritter.add title: status, text: "Could not load '#path'"
        cb error
    )

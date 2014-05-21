## https://github.com/petehunt/react-jqueryui
## ported to livescript

wrap-widget = (long-name) ->
  display-name = "React#long-name"
  name = long-name.to-lower-case!

  React.create-class {
    display-name,

    render: ->
      @props.children.0

    component-did-update: (prev-props) ->
      if not (prev-props === @props)
        @_runPlugin!

    component-did-mount: ->
      @_runPlugin!

    _runPlugin: ->
      $node = $(@getDOMNode!)
      after = delete @props.after
      $node[name](@props)
      if after then after($node)
      @$ = $node;
  }

widgets = <[
  Accordion
  Autocomplete
  Button
  DatePicker
  Draggable
  Droppable
  Menu
  ProgressBar
  Resizable
  Selectable
  Sortable
  Slider
  Spinner
  Tabs
  Tooltip
]>

module.exports = { [name, wrap-widget(name)] for name in widgets }

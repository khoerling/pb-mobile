{a, img, h1, h2, h3, header, div, span, footer} = React.DOM
{Link} = ReactRouter

require! {
  \./mixins
}

module.exports = React.create-class {
  display-name: \Homepage

  mixins: [ ReactAsync.Mixin, mixins.InitialStateAsync ]

  tick: ->
    @set-state count: @state.count + 1

  component-did-mount: ->
    @int = set-interval @tick, 1000ms

  component-will-unmount: ->
    clear-interval @int

  render: ->
    h1 void [ a {title: 'Dimension Software Consulting', href: '/'} 'Dimension Software Consulting' ]
    h2 void [ a {title: 'Dimension Software Consulting', href: '/'} 'Forward ideas.  Simple tools.  Groundbreaking software.' ]
    header void, [
      a {title: 'Dimension Software Consulting Home', href: '/'}, 'Home'
      a {title: 'Dimension Software Consulting Support', href: 'https://community.powerbulletin.com'}, 'Support'
      a {title: 'Dimension Software Consulting Contact', href: 'mailto:hello@dimensionsoftware.com'}, 'Contact Us'
    ],
    h3 void, 'On page for ', [
      span { key: \count }, [ " ", @state.count, ' seconds' ]
    ]
}

# vim:fdm=indent

require! {
  \./famous/core/Engine
  \./famous/core/Scene
  \./famous/core/Context
  \./famous/core/Surface
  \./famous/core/Transform
  \./famous/core/View
  \./famous/physics/PhysicsEngine
  \./famous/physics/bodies/Particle
  \./famous/physics/forces/Spring
  \./famous/physics/forces/VectorField
  \./famous/math/Vector
  \./famous/surfaces/ImageSurface
  \./famous/surfaces/ContainerSurface
  \./famous/transitions/Easing
  \./famous/transitions/Transitionable
  \./famous/transitions/SpringTransition
  \./famous/transitions/WallTransition
  \./famous/transitions/SnapTransition
  \./famous/views/GridLayout
  \./famous/views/HeaderFooterLayout
  \./famous/views/Lightbox
  \./famous/views/Scrollview
  \./famous/modifiers/StateModifier
}

# famo.us entry point
PE = new PhysicsEngine!
Transitionable.registerMethod \spring, SpringTransition
Transitionable.registerMethod \wall, WallTransition
Transitionable.registerMethod \snap, SnapTransition

main-context = Engine.create-context!
  ..set-perspective 5000

# image assets {{{
icon = new ImageSurface {
  properties: {cursor: \pointer}
  content: \/images/pb_icon_logo.png
  size:    [81px, 89px]
}
#}}}

class AppView extends View
  ->
    super arguments

spring = { method: \spring, period: 260ms, damping-ratio: 0.5 }
sharp  = { method: \wall, period: 200ms }

# fetch thread data
dfd = $.Deferred!
$.get \/api/v1/forums/2/threads, (data) -> dfd.resolve data
pfd = dfd.promise!

# root scene
scene = new Scene {
  id:      \root
  opacity: 1
  target:  [
    { # intro page
      target: {id: \thread}
      origin: [0, 0]
    },
    { # geek page
      opacity: 0
      target: {id: \forum}
      transform: [
        {rotate-z: Math.PI/4}, # radians
        #{scale:    [0.5, 0.5, 1]}
      ],
      origin: [0.5, 0.5]
    }
  ]
}
main-context.add scene

# initial page
# ---------
# build-in intro scene w/ icon
icon
  ..particle = new Particle { mass: 1, position: [0, 0, 0], velocity: [0, 0, 0] }
  ..state    = new StateModifier { origin: [0.5, 0], opacity: 1 }
  ..spring   = new Spring { anchor: [0, 0, 0], length: 0, method: \spring, period: 450ms, dampening-ratio: 0.2 }
  ..on \click ->
    icon.particle.apply-force (new Vector(0, 0, -0.6))
# attach physics to icon
PE.add-body icon.particle
layout = new HeaderFooterLayout header-size: 150px, footer-size: 100px
scene.id.thread.add layout
layout.header.add icon.state .add icon.particle .add icon
<~ icon.state.set-transform Transform.translate(0, 210px, 1700), { method: \spring, period: 500ms, dampening-ratio: 1 }
thread-data <~ $.when pfd .then

lightbox = new Lightbox
window.lightbox = lightbox
window.thread-list = thread-list

# yield, then-- snap thread list in place
PE.attach icon.spring, icon.particle
icon.state
  ..set-transform Transform.translate(0, -100px, 0), sharp
  ..set-opacity 0, duration: 180ms

threads = []
thread-list = new Scrollview!
  ..sequence-from threads

thread-data.for-each (e,i) ~>
  s = new Surface {
    content: e.title
    size: [void, 100]
    classes: [\thread]
    properties:
      text-transform: \capitalize
      margin: \auto
      line-height: \100px
      text-align: \center
  }

  id = e.id

  ### click handler for thread {{{
  s.on \click, (ev) ->
    thread-container = new ContainerSurface size: [500, 500], properties: { background-color: \#f00, overflow: \hidden }
    posts = []
    post-list = new Scrollview(size: [500, 500])
      ..sequence-from posts

    post-list.on \click, -> lightbox.hide!

    $.get "/api/v1/posts/#{id}/flattened", (r) ->
      r.for-each (e, i) ->
        post-surface = new Surface {
          content: e.html
          size: [300, 300]
          origin: [0.5, 0.5]
          properties:
            background-color: \#ccc
            margin: \auto
            z-index: 5
        }
        post-surface.pipe post-list
        posts.push post-surface
      lightbox.show(thread-container)
  ### }}}

  s.pipe thread-list
  threads.push s

clip = new ContainerSurface properties: { overflow: \hidden }
  ..add thread-list
layout.content.add clip
layout.content.add lightbox

#layout.header
#layout.content.add (new StateModifier { origin: [0.5, 0.85] }) .add grid

<~ set-timeout _, 800ms
$ \body .add-class \loaded



# TODO forum page
# ---------
#scene.id.forum.add keith-on

# vim:fdm=marker

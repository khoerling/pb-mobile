require! {
  \./famous/core/Engine
  \./famous/core/Scene
  \./famous/core/Context
  \./famous/core/Transform
  \./famous/core/Surface
  \./famous/physics/PhysicsEngine
  \./famous/physics/bodies/Particle
  \./famous/physics/forces/Spring
  \./famous/physics/forces/VectorField
  \./famous/math/Vector
  \./famous/surfaces/ImageSurface
  \./famous/transitions/Easing
  \./famous/transitions/Transitionable
  \./famous/transitions/SpringTransition
  \./famous/transitions/WallTransition
  \./famous/transitions/SnapTransition
  \./famous/views/GridLayout
  \./famous/views/HeaderFooterLayout
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
layout = new HeaderFooterLayout header-size: 360px, footer-size: 100px
scene.id.thread.add layout
layout.header.add icon.state .add icon.particle .add icon
<~ icon.state.set-transform Transform.translate(0, 210px, 1700), { method: \spring, period: 500ms, dampening-ratio: 1 }
thread-data <~ $.when pfd .then

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
    size: [void, 200]
    properties:
      background-color: "hsl(#{i*360/40}, 100%, 50%)"
      text-align: \center
  }
  s.pipe thread-list
  threads.push s
layout.content.add thread-list

#layout.header
#layout.content.add (new StateModifier { origin: [0.5, 0.85] }) .add grid

<~ set-timeout _, 800ms
$ \body .add-class \loaded



# TODO forum page
# ---------
#scene.id.forum.add keith-on

# vim:fdm=marker

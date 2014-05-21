require! {
  \./famous/core/Engine
  \./famous/core/Scene
  \./famous/core/Context
  \./famous/core/Transform
  \./famous/physics/PhysicsEngine
  \./famous/physics/bodies/Particle
  \./famous/physics/bodies/Circle
  \./famous/physics/constraints/Wall
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
  \./famous/modifiers/StateModifier

  \./BoxSection
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
  content: \/images/dimension_icon.png
  size:    [100px, 115px]
}
dimension = new ImageSurface {
  content: \/images/dimension_logo_text.png
  size:    [337px, 41px]
}
top-left-splatter = new ImageSurface {
  content: \/images/top_left_corner_splatter.png
  size:    [207px, 169px]
  classes: [\splatter]
}
tagline = new ImageSurface {
  content: \/images/tagline.png
  size:    [649px, 24px]
}
keith-off = new ImageSurface {
  content: \/images/keith0.png
  size:    [154px, 154px]
}
keith-on = new ImageSurface {
  content: \/images/keith1.png
  size:    [154px, 154px]
}
#}}}

spring = { method: \spring, period: 260ms, damping-ratio: 0.5 }
sharp  = { method: \wall, period: 200ms }

# root scene
scene = new Scene {
  id:      \root
  opacity: 1
  target:  [
    { # intro page
      target: {id: \intro}
      origin: [0, 0]
    },
    { # geek page
      opacity: 0
      target: {id: \geeks}
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
#Wall.ON_CONTACT.REFLECT = 1
#wall = new Wall normal: [1,0,0], distance: 0
#PE.attach wall, [icon.particle]
PE.add-body icon.particle
layout = new HeaderFooterLayout header-size: 360px, footer-size: 100px
scene.id.intro.add layout
layout.header.add icon.state .add icon.particle .add icon
<~ icon.state.set-transform Transform.translate(0, 210px, 1700), { method: \spring, period: 500ms, dampening-ratio: 1 }

# yield, then-- snap everything else in place
top-left-splatter.state = new StateModifier origin: [0, 0]
  ..set-transform Transform.scale(3, 1.8)
  ..set-transform Transform.scale(1, 1), duration: 150ms
dimension.state = new StateModifier { origin: [0.5, 0], opacity: 0 }
  ..set-opacity 1, duration: 400ms
  ..set-transform Transform.translate(70px, 120px, 0), spring
tagline.state = new StateModifier { origin: [0.5, 0], opacity: 0 }

PE.attach icon.spring, icon.particle
icon.state.set-transform Transform.translate(-175px, 80px, 0), sharp
tagline.state
  ..set-transform Transform.translate(0, 230px, 0), sharp
  ..set-opacity 1, duration: 350ms

layout.header
  ..add top-left-splatter.state .add top-left-splatter
  ..add dimension.state .add dimension
  ..add tagline.state .add tagline
grid = new GridLayout dimensions: [3, 1]
  ..sequence-from [
    new BoxSection \geeks, classes: [\blue]
    new BoxSection \software, size: [281px, 114px], classes: [\green]
    new BoxSection \talk, size: [213px, 165px], classes: [\orange]
  ]
layout.content.add (new StateModifier { origin: [0.5, 0.85] }) .add grid

<~ set-timeout _, 800ms
$ \body .add-class \loaded



# TODO geek page
# ---------
scene.id.geeks.add keith-on

# vim:fdm=marker

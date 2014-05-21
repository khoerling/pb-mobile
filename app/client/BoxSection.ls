require! {
  \./famous/core/Modifier
  \./famous/core/View
  \./famous/core/Transform
  \./famous/surfaces/ImageSurface
  \./famous/surfaces/ContainerSurface
  \./famous/transitions/Transitionable
  \./famous/transitions/SpringTransition
  \./famous/transitions/SnapTransition
}

Transitionable.registerMethod \spring, SpringTransition
Transitionable.registerMethod \snap, SnapTransition
snap   = { method: \snap  , period: 100ms, damping-ratio: 0.9 }
Transitionable.registerMethod \snap, SnapTransition

module.exports =
  class BoxSection extends View
    asset:   void
    classes: void
    opts:    void

    (asset, opts={}) ->
      super opts
      @asset   = asset or ''
      @opts    = opts
      @classes = (opts.classes or []) ++ [asset]
      damping = -> r = Math.random!; if r < 0.3 then 0.3 else r; r - 0.15

      center = new Modifier origin: [0.5, 0.5], transform: Transform.rotate-z(Math.PI/5)
      @add (new ContainerSurface classes:[\BoxSection]
        ..add center
          ..add new ImageSurface { # square patch bg pattern
            content: "/images/pattern_square_#{@asset}.png",
            classes: @classes ++ [\pattern]
            size:    [void, void]
          }
          ..add new ImageSurface { # shadow of text (behind)
            content: "/images/shadow_#{@asset}_big.png",
            classes: @classes ++ [\title]
            size:    @opts.size or [172px, 233px],
          }
          ..add new ImageSurface { # text (front)
            content: "/images/#{@asset}_big.png",
            classes: [\shadow]
            size:    @opts.size or [172px, 233px],
          })
      spring = { method: \spring, period: (Math.random!*300ms), damping-ratio: damping! }
      center.set-transform Transform.rotate-z(0), spring


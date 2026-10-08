module Plotting

export trplot, tranimate, tranimate_move, trscene, trframes_gui

"""
    trplot(T; scale=1.0, linewidth=2)

Draw the axes of a 4×4 homogeneous transform (a 3×3 SE(2) transform is embedded
with `Se3` first). Load `GLMakie`, `WGLMakie` or `CairoMakie` first.
"""
function trplot(args...; kwargs...)
    error("Load GLMakie or CairoMakie before calling trplot.")
end

"""
    tranimate(targets; starts=nothing, mode=:simultaneous, nframes=90, fps=30,
              scale=1.0, labels=nothing, trail=true, ease=true, autoplay=false,
              record=nothing, figsize=(1000, 800), title="")

Animate N reference frames from `starts` (default: identity) to `targets`.
`targets` is one pose or a vector of poses (4×4, or 3×3 for SE(2)).

Without `record` it returns a `Figure` with a slider and a ▶ button; it works in
GLMakie and in WGLMakie inside Pluto. With `record="anim.mp4"` (or `.gif`) it
writes the video and returns the path.

`mode` is `:simultaneous`, `:rot_then_trans` or `:trans_then_rot`, see [`Trinterp`](@ref).

Load `GLMakie`, `WGLMakie` or `CairoMakie` first (`CairoMakie` only supports `record`).
"""
function tranimate(args...; kwargs...)
    error("Load GLMakie or WGLMakie before calling tranimate.")
end

"""
    tranimate_move(starts, moves; frame=:body, order=:trans_then_rot,
                   schedule=:sequential, ease=true, scale=1.0, labels=nothing,
                   nframes=90, fps=30, trail=true, autoplay=false, record=nothing,
                   figsize=(1000, 800), title="")

Animate a RELATIVE motion applied to one or N poses, composing the translation and the
rotation in an explicit order. `starts` is one pose or a vector of poses; `moves` is one
`(d, R)` tuple or a vector of them (`d` = 3-vector translation, `R` = 3×3 rotation).

`frame=:body` post-multiplies (`T * Dt * Dr`), `frame=:world` pre-multiplies
(`Dr * Dt * T`); `order` is `:trans_then_rot` or `:rot_then_trans`. See [`Trmove`](@ref)
for the four resulting formulas. Returns a `Figure` (slider + ▶) or, with `record=`,
the path of the video.

    tranimate_move(Se3(1,0,0,0,0,90; deg=true), ([1,2,0], Rotz(90; deg=true));
                   frame=:world, order=:trans_then_rot)
"""
function tranimate_move(args...; kwargs...)
    error("Load GLMakie or WGLMakie before calling tranimate_move.")
end

"""
    trscene(starts; labels=nothing, scale=1.0, limit=nothing, scale_exponent=0.75,
            trail=false, figsize=(900, 700), title="") -> (; fig, update!, set_limit!)

Persistent 3D scene with one reference frame per pose in `starts` (plus `{0}`), meant
for Pluto: build it ONCE and push new poses with `update!`, so a slider does not rebuild
the figure (no camera reset, no flicker).

    S = trscene([T0, T0]; labels=["T*M", "M*T"], trail=true, limit=6)
    S.fig                                             # shows the figure
    S.update!([Trmove(T0, d, Q, s; frame=:body),      # one pose per body
               Trmove(T0, d, Q, s; frame=:world)];
              trails=[[...poses...], [...poses...]])  # optional, needs trail=true
    S.set_limit!(10)                                  # change the axis cube (frames rescale)

The frame length is `scale * (limit / limit0)^scale_exponent`: `scale_exponent=1`
keeps the same look at any zoom, `0` keeps a fixed length. Load `WGLMakie` (Pluto)
or `GLMakie` first.
"""
function trscene(args...; kwargs...)
    error("Load GLMakie or WGLMakie before calling trscene.")
end

"""
    trframes_gui(; scale=1.0, fps=60, figsize=(1400, 860), limit=2.5, scale_exponent=0.75)

Interactive window (returns a `Figure`) to add N bodies, type the desired
translation `(x, y, z)` and rotation `(roll, pitch, yaw)` in degrees
(`R = Rz·Ry·Rx`) and animate the homogeneous transform. Each animation starts
from the body's current pose. Load `GLMakie` or `WGLMakie` first.

    using GLMakie, Talos
    wait(display(trframes_gui()))
"""
function trframes_gui(args...; kwargs...)
    error("Load GLMakie or WGLMakie before calling trframes_gui.")
end

end

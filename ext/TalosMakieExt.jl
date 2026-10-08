module TalosMakieExt

using Talos
using LinearAlgebra
using StaticArrays
using Makie

const Hom = SMatrix{4,4,Float64,16}
const PoseOrPoses = Union{AbstractMatrix{<:Real},AbstractVector{<:AbstractMatrix{<:Real}}}

# ─────────────────────────────────────────────────────────────────────────────
# trplot
# ─────────────────────────────────────────────────────────────────────────────
function Talos.Plotting.trplot(T::AbstractMatrix{<:Real}; scale=1.0, linewidth=2)
    T = Se3(T)   # 4×4 as is; 3×3 (SE(2)) embedded; other sizes throw ArgumentError
    o = T[1:3, 4]
    axes = ntuple(i -> o .+ scale .* T[1:3, i], 3)
    colors = (:red, :green, :blue)

    fig = Figure()
    ax = Axis3(fig[1, 1]; xlabel="X", ylabel="Y", zlabel="Z", aspect=:data)
    for (tip, color) in zip(axes, colors)
        lines!(ax, [o[1], tip[1]], [o[2], tip[2]], [o[3], tip[3]]; color, linewidth)
    end
    scatter!(ax, [o[1]], [o[2]], [o[3]]; color=:black, markersize=8)
    return fig
end

# ─────────────────────────────────────────────────────────────────────────────
# Dibujo de marcos con Observables
# ─────────────────────────────────────────────────────────────────────────────
const AXCOLORS = [RGBf(0.9, 0.1, 0.1), RGBf(0.9, 0.1, 0.1),
                  RGBf(0.1, 0.7, 0.1), RGBf(0.1, 0.7, 0.1),
                  RGBf(0.1, 0.3, 0.9), RGBf(0.1, 0.3, 0.9)]

struct FrameArtist
    pose::Observable{Hom}
    trail::Observable{Vector{Point3f}}
    usetrail::Bool
    label::Observable{String}
end

_org(H) = Point3f(H[1, 4], H[2, 4], H[3, 4])

function _frame_points(H, L)
    o = _org(H)
    pts = Point3f[]
    for i in 1:3
        push!(pts, o, o + Point3f(L * H[1, i], L * H[2, i], L * H[3, i]))
    end
    return pts
end

# `L` (largo de los ejes) y `label` pueden ser números/strings o Observables:
# si son Observables, cambiarlos redibuja el marco sin volver a crearlo.
function draw_frame!(ax, H0, L; label="", color=:gray, trail=true, linewidth=4)
    H0 = Hom(H0)
    Lobs = L isa Observable ? L : Observable(float(L))
    labobs = label isa Observable ? label : Observable{String}(string(label))
    pose = Observable{Hom}(H0)
    tpts = Observable(Point3f[_org(H0), _org(H0)])
    linesegments!(ax, lift((h, l) -> _frame_points(h, l), pose, Lobs); color=AXCOLORS, linewidth)
    labpos = lift((h, l) -> _org(h) + Point3f(0.1l, 0.1l, 0.1l), pose, Lobs)
    text!(ax, labpos; text=labobs, fontsize=14, color)
    trail && lines!(ax, tpts; color, linestyle=:dash, linewidth=2)
    return FrameArtist(pose, tpts, trail, labobs)
end

set_pose!(fa::FrameArtist, H) = (fa.pose[] = Hom(H))
set_trail!(fa::FrameArtist, pts) = (fa.usetrail && (fa.trail[] = pts))
function push_trail!(fa::FrameArtist, H)
    fa.usetrail || return
    push!(fa.trail[], _org(H))
    notify(fa.trail)
end
function reset_frame!(fa::FrameArtist, H)
    fa.trail[] = Point3f[_org(H), _org(H)]
    fa.pose[] = Hom(H)
end

function set_cube!(ax, c, r)
    lx, ly, lz = (c[1] - r, c[1] + r), (c[2] - r, c[2] + r), (c[3] - r, c[3] + r)
    try
        xlims!(ax, lx...)
        ylims!(ax, ly...)
        zlims!(ax, lz...)
    catch
        ax.limits = (lx, ly, lz)      # respaldo si esta versión de Makie no tiene xlims! para Axis3
    end
end

# Caja cúbica que encierra todos los puntos, con poco margen (así el dibujo llena la ventana).
function set_cube_limits!(ax, pts, L)
    lo = [minimum(p[i] for p in pts) for i in 1:3]
    hi = [maximum(p[i] for p in pts) for i in 1:3]
    c = (lo .+ hi) ./ 2
    r = max(maximum(hi .- lo) / 2 * 1.05 + 0.15L, 0.75L)
    set_cube!(ax, c, r)
end

# ─────────────────────────────────────────────────────────────────────────────
# Núcleo de animación (compartido por tranimate y tranimate_move)
# ─────────────────────────────────────────────────────────────────────────────
# `posefun(k, s)` devuelve la pose del cuerpo k en el instante s ∈ [0, 1].
# Con eso el dibujo no sabe (ni le importa) cómo se calcula el movimiento.
function animate_core(T0::Vector{Hom}, posefun, labs; L, nframes, fps, trail, autoplay, record, figsize, title)
    n = length(T0)
    n > 0 || throw(ArgumentError("at least one pose is required"))
    nframes >= 2 || throw(ArgumentError("nframes must be at least 2"))
    fps > 0 || throw(ArgumentError("fps must be positive"))
    L > 0 || throw(ArgumentError("scale must be positive"))

    # Evaluate the trajectory once up front. This catches invalid transforms before
    # the GUI is displayed and also lets us choose a useful visual axis length.
    samples = [posefun(k, s) for k in 1:n for s in range(0, 1; length=41)]
    allpts = Point3f[Point3f(0, 0, 0)]
    for H in samples
        append!(allpts, _frame_points(H, float(L)))
    end

    # Keep the requested scale as a minimum, but enlarge the drawn axes when the
    # motion covers a large area. Otherwise a translation of (say) 20 units would
    # make unit-length axes almost invisible.
    lo = [minimum(p[i] for p in allpts) for i in 1:3]
    hi = [maximum(p[i] for p in allpts) for i in 1:3]
    span = maximum(hi .- lo)
    Lvis = max(float(L), 0.12 * max(span, float(L)))

    # Recompute the points with the final visual axis length.
    pts = Point3f[Point3f(0, 0, 0),
                  Point3f(Lvis, 0, 0),
                  Point3f(0, Lvis, 0), 
                  Point3f(0, 0, Lvis)]
    for k in 1:n, s in range(0, 1; length=41)
        append!(pts, _frame_points(posefun(k, s), Lvis))
    end

    fig = Figure(size=figsize)
    ax = Axis3(fig[1, 1];     aspect=:equal, viewmode=:fitzoom, xlabel="x", ylabel="y", zlabel="z", title)
    draw_frame!(ax, Hom(I), Lvis; label="{0}", color=:black, trail=false, linewidth=3)
    set_cube_limits!(ax, pts, Lvis)

    art = [draw_frame!(ax, T0[k], Lvis; label=labs[k], color=Makie.wong_colors()[mod1(k, 7)], trail) for k in 1:n]

    function apply!(s)
        for k in 1:n
            H = posefun(k, s)
            set_pose!(art[k], H)
            if trail
                ss = range(0, s; length=max(2, round(Int, 60 * s)))
                set_trail!(art[k], Point3f[_org(posefun(k, q)) for q in ss])
            end
        end
    end
    apply!(0.0)

    if record === nothing
        sl  = Slider(fig[2, 1]; range=0:0.001:1, startvalue=0, tellwidth=false)
        btn = Button(fig[3, 1]; label="▶  Reproducir", tellwidth=false)
        on(sl.value) do s
            apply!(s)
        end
        playing = Ref(false)
        function play()
            playing[] && return
            playing[] = true
            @async try
                for s in range(0, 1; length=nframes)
                    set_close_to!(sl, s)
                    sleep(1 / fps)
                end
            catch err
                @error "tranimate: playback failed" exception = (err, catch_backtrace())
            finally
                playing[] = false
            end
        end
        on(_ -> play(), btn.clicks)
        autoplay && play()
        return fig
    else
        Makie.record(fig, record, range(0, 1; length=nframes); framerate=fps) do s
            apply!(s)
        end
        return record
    end
end

function as_hom_vector(x)
    xs = x isa AbstractMatrix ? (x,) : collect(x)
    isempty(xs) && throw(ArgumentError("at least one pose is required"))
    return Hom[Se3(T) for T in xs]
end

# ─────────────────────────────────────────────────────────────────────────────
# tranimate: hacia una pose ABSOLUTA (Trinterp)
# ─────────────────────────────────────────────────────────────────────────────
function Talos.Plotting.tranimate(targets::PoseOrPoses; starts=nothing,
                                  mode::Symbol=:simultaneous, nframes::Int=90, fps::Int=30,
                                  scale=1.0, labels=nothing, trail::Bool=true, ease::Bool=true,
                                  autoplay::Bool=false, record=nothing,
                                  figsize=(1000, 800), title="")
    T1 = as_hom_vector(targets)
    n = length(T1)
    T0 = starts === nothing ? fill(Hom(I), n) : as_hom_vector(starts)
    length(T0) == n || throw(ArgumentError("`starts` and `targets` must have the same length"))
    labs = labels === nothing ? ["{$i}" for i in 1:n] : string.(labels)
    posefun = (k, s) -> Trinterp(T0[k], T1[k], s; mode, ease)
    return animate_core(T0, posefun, labs; L=scale, nframes, fps, trail, autoplay,
                        record, figsize, title)
end

# ─────────────────────────────────────────────────────────────────────────────
# tranimate_move: movimiento RELATIVO con orden de composición explícito (Trmove)
# ─────────────────────────────────────────────────────────────────────────────
function Talos.Plotting.tranimate_move(starts::PoseOrPoses, moves;
                                       frame::Symbol=:body, order::Symbol=:trans_then_rot,
                                       schedule::Symbol=:sequential, ease::Bool=true,
                                       nframes::Int=90, fps::Int=30, scale=1.0, labels=nothing,
                                       trail::Bool=true, autoplay::Bool=false, record=nothing,
                                       figsize=(1000, 800), title="")
    T0 = as_hom_vector(starts)
    n = length(T0)
    mv = (moves isa Tuple || moves isa NamedTuple) && length(moves) == 2 ? [moves] : collect(moves)
    length(mv) == n || throw(ArgumentError("`moves` must have one (d, R) per pose in `starts`"))
    all(length(m) == 2 for m in mv) ||
        throw(ArgumentError("each move must be a `(d, R)` pair"))
    ds = [collect(Float64, m[1]) for m in mv]
    Rs = [Matrix{Float64}(m[2]) for m in mv]
    all(length(d) == 3 for d in ds) ||
        throw(ArgumentError("each translation `d` must have length 3"))
    all(size(R) == (3, 3) for R in Rs) ||
        throw(ArgumentError("each rotation `R` must be 3×3"))
    labs = labels === nothing ? ["{$i}" for i in 1:n] : string.(labels)
    posefun = (k, s) -> Trmove(T0[k], ds[k], Rs[k], s; frame, order, schedule, ease)
    return animate_core(T0, posefun, labs; L=scale, nframes, fps, trail, autoplay,
                        record, figsize, title)
end

# ─────────────────────────────────────────────────────────────────────────────
# trscene: escena persistente + update!  (pensada para Pluto con @bind)
# ─────────────────────────────────────────────────────────────────────────────
# Se crea UNA vez; después se le empujan poses nuevas con `update!`. Así un slider de
# PlutoUI no reconstruye la figura (la cámara no se reinicia y no hay parpadeo).
function Talos.Plotting.trscene(starts::PoseOrPoses; labels=nothing, scale=1.0,
                                limit=nothing, scale_exponent=0.75, trail::Bool=false,
                                figsize=(900, 700), title="")
    T0 = as_hom_vector(starts)
    n = length(T0)
    labs = labels === nothing ? ["{$i}" for i in 1:n] : string.(labels)
    length(labs) == n || throw(ArgumentError("`labels` must have one name per pose"))
    L = float(scale)
    L > 0 || throw(ArgumentError("scale must be positive"))

    pmax = maximum(maximum(abs, (H[1, 4], H[2, 4], H[3, 4])) for H in T0)
    lim0 = float(limit === nothing ? max(2.5, 1.5L + pmax) : limit)
    lim = Observable(lim0)
    Lobs = lift(l -> L * (l / lim0)^scale_exponent, lim)

    fig = Figure(size=figsize)
    ax = Axis3(fig[1, 1]; aspect=:data, viewmode=:fitzoom,
               xlabel="x", ylabel="y", zlabel="z", title)
    draw_frame!(ax, Hom(I), Lobs; label="{0}", color=:black, trail=false, linewidth=3)
    set_cube!(ax, (0.0, 0.0, 0.0), lim0)
    on(lim) do l
        set_cube!(ax, (0.0, 0.0, 0.0), l)
    end
    art = [draw_frame!(ax, T0[k], Lobs; label=labs[k],
                       color=Makie.wong_colors()[mod1(k, 7)], trail) for k in 1:n]

    # poses: una pose (o una por cuerpo). trails: por cuerpo, una lista de poses cuyo
    # origen se dibuja como estela.
    function update_poses!(poses; trails=nothing)
        P = as_hom_vector(poses)
        length(P) == n || throw(ArgumentError("expected $n poses, got $(length(P))"))
        for k in 1:n
            set_pose!(art[k], P[k])
            if trail && trails !== nothing
                set_trail!(art[k], Point3f[_org(Hom(Se3(H))) for H in trails[k]])
            end
        end
        return nothing
    end
    set_limit!(l) = (lim[] = float(l); nothing)

    return (; fig, update! = update_poses!, set_limit! = set_limit!)
end

# ─────────────────────────────────────────────────────────────────────────────
# trframes_gui
# ─────────────────────────────────────────────────────────────────────────────
mutable struct Body
    name::String
    init::Vector{Float64}      # x y z roll pitch yaw (grados): pose INICIAL (a la que vuelve "Reiniciar")
    target::Vector{Float64}    # x y z roll pitch yaw (grados): destino o movimiento M
    art::FrameArtist
end

init_hom(v) = Hom(Se3(v...; deg=true))

function parse_num(s)
    s === nothing && return 0.0
    v = tryparse(Float64, s)
    return v === nothing ? 0.0 : v
end

fmt(v) = lpad(string(round(v; digits=3) + 0.0), 8)   # `+ 0.0` evita "-0.0"

# Texto que explica qué matriz se está calculando con las opciones elegidas.
function formula_text(frame, order)
    frame === :absolute && return "T nuevo = pose objetivo dada en {0}\n(solo cambia la trayectoria, no la pose final)"
    tr_rot = order === :trans_then_rot
    if frame === :body
        return tr_rot ? "T nuevo = T * Transl(d) * Rot(Q)\nejes del propio cuerpo (postmultiplicar)" :
                        "T nuevo = T * Rot(Q) * Transl(d)\nse traslada por los ejes YA girados"
    else
        return tr_rot ? "T nuevo = Rot(Q) * Transl(d) * T\nla rotacion gira alrededor del ORIGEN del mundo" :
                        "T nuevo = Transl(d) * Rot(Q) * T\nejes del mundo (premultiplicar)"
    end
end

function Talos.Plotting.trframes_gui(; scale=1.0, fps::Int=60, figsize=(1400, 860),
                                     limit=2.5, scale_exponent=0.75)
    L = float(scale)
    lim0 = float(limit)
    lim = Observable(lim0)                                   # semilado del cubo de ejes (observable)
    Lobs = lift(l -> L * (l / lim0)^scale_exponent, lim)     # largo de los marcos: crece "un poco" con lim

    fig = Figure(size=figsize)
    ax = Axis3(fig[1, 1]; aspect=:data, viewmode=:fitzoom, xlabel="x", ylabel="y", zlabel="z")
    draw_frame!(ax, Hom(I), Lobs; label="{0}", color=:black, trail=false, linewidth=3)
    set_cube!(ax, (0.0, 0.0, 0.0), lim0)
    on(lim) do l
        set_cube!(ax, (0.0, 0.0, 0.0), l)
    end

    panel = fig[1, 2] = GridLayout()
    colsize!(fig.layout, 2, Fixed(470))
    colsize!(panel, 1, Fixed(118))

    # ── ayudantes de interfaz ────────────────────────────────────────────────
    lab(pos, txt; kw...) = Label(pos, txt; halign=:right, fontsize=12, kw...)
    function textbox(pos, ph, init="0")
        tb = Textbox(pos; placeholder=ph, validator=Float64, width=95, fontsize=12)
        Makie.set!(tb, string(init))
        return tb
    end
    # seis cajas: x y z en la fila `row`, roll pitch yaw en `row+1`
    function six_boxes(row, vals)
        tbs = Textbox[]
        for (j, nm) in enumerate(("x", "y", "z"))
            push!(tbs, textbox(panel[row, 1 + j], nm, vals[j]))
        end
        for (j, nm) in enumerate(("roll", "pitch", "yaw"))
            push!(tbs, textbox(panel[row + 1, 1 + j], nm, vals[3 + j]))
        end
        return tbs
    end

    # ── cuerpos ──────────────────────────────────────────────────────────────
    Label(panel[1, 1:4], "Marcos de referencia"; fontsize=20, font=:bold, halign=:left)
    lab(panel[2, 1], "Cuerpo")
    menu = Menu(panel[2, 2:4]; options=["{1}"], default="{1}", searchable=false,
                fontsize=12, width=300)
    lab(panel[3, 1], "Nombre")
    name_tb = Textbox(panel[3, 2:4]; placeholder="nombre del cuerpo", width=300, fontsize=12)
    Makie.set!(name_tb, "{1}")

    lab(panel[4, 1], "Inicial: x y z")
    lab(panel[5, 1], "Inicial: grados")
    init_tbs = six_boxes(4, zeros(6))

    btn_add = Button(panel[6, 1:2]; label="+ Añadir cuerpo", fontsize=13, tellwidth=false)
    btn_upd = Button(panel[6, 3:4]; label="Actualizar cuerpo", fontsize=13, tellwidth=false)
    Label(panel[7, 1:4], "Añadir: crea un cuerpo con el nombre y la pose inicial de arriba.\n" *
          "Actualizar: aplica nombre y pose inicial al cuerpo elegido."; fontsize=11,
          color=:gray40, halign=:left, justification=:left, tellwidth=false)

    # ── movimiento ───────────────────────────────────────────────────────────
    lab(panel[8, 1], "Mover: x y z")
    lab(panel[9, 1], "Mover: grados")
    move_tbs = six_boxes(8, zeros(6))

    lab(panel[10, 1], "Interpretar")
    frame_menu = Menu(panel[10, 2:4]; options=["pose absoluta en {0}" => :absolute,
                                               "relativo CUERPO: T*M" => :body,
                                               "relativo MUNDO: M*T" => :world],
                      fontsize=12, width=300)
    lab(panel[11, 1], "Orden")
    order_menu = Menu(panel[11, 2:4]; options=["trasladar y luego rotar" => :trans_then_rot,
                                               "rotar y luego trasladar" => :rot_then_trans],
                      fontsize=12, width=300)
    lab(panel[12, 1], "Ejecución")
    sched_menu = Menu(panel[12, 2:4]; options=["secuencial" => :sequential,
                                               "a la vez" => :simultaneous],
                      fontsize=12, width=300)

    lab(panel[13, 1], "Duración (s)")
    dur_tb = textbox(panel[13, 2], "s", "2.0")
    lab(panel[13, 3], "Ejes ±")
    lim_tb = textbox(panel[13, 4], "límite", string(lim0))
    on(lim_tb.displayed_string) do s
        v = parse_num(s)
        (v > 0 && abs(v - lim[]) > 1e-9) && (lim[] = v)
    end

    formula = Observable(formula_text(:absolute, :trans_then_rot))
    Label(panel[14, 1:4]; text=formula, fontsize=12, justification=:left, halign=:left, tellwidth=false)
    menu_value(x) = x isa Pair ? last(x) : x
    onany(frame_menu.selection, order_menu.selection) do fr, od
        formula[] = formula_text(menu_value(fr), menu_value(od))
    end

    btn_go    = Button(panel[15, 1:4]; label="▶  Animar cuerpo seleccionado", fontsize=13, tellwidth=false)
    btn_all   = Button(panel[16, 1:2]; label="▶▶  Animar todos", fontsize=13, tellwidth=false)
    btn_reset = Button(panel[16, 3:4]; label="Reiniciar a la inicial", fontsize=13, tellwidth=false)

    readout = Observable("")
    Label(panel[17, 1:4]; text=readout, fontsize=12, justification=:left, halign=:left, tellwidth=false)
    rowgap!(panel, 6)

    # ── estado ───────────────────────────────────────────────────────────────
    bodies = Body[]
    animating = Ref(false)
    selected_index() = isempty(bodies) ? 0 : clamp(menu.i_selected[], 1, length(bodies))

    function refresh_readout!(header="")
        isempty(bodies) && return
        b = bodies[selected_index()]
        H = b.art.pose[]
        rows = [join((fmt(H[i, j]) for j in 1:4), " ") for i in 1:4]
        readout[] = header * "T de $(b.name) respecto a {0}:\n" * join(rows, "\n")
    end

    # Las cajas numéricas escriben EN VIVO en el cuerpo seleccionado (sin pulsar Enter).
    function bind_boxes!(tbs, field::Symbol)
        for (j, tb) in enumerate(tbs)
            on(tb.displayed_string) do s
                isempty(bodies) && return
                getfield(bodies[selected_index()], field)[j] = parse_num(s)
            end
        end
    end
    bind_boxes!(init_tbs, :init)
    bind_boxes!(move_tbs, :target)

    function load_boxes!()
        isempty(bodies) && return
        b = bodies[selected_index()]
        Makie.set!(name_tb, b.name)
        for (tb, v) in zip(init_tbs, copy(b.init))
            Makie.set!(tb, string(v))
        end
        for (tb, v) in zip(move_tbs, copy(b.target))
            Makie.set!(tb, string(v))
        end
        refresh_readout!()
    end
    on(menu.i_selected) do _
        load_boxes!()
    end

    function refresh_menu!(sel)
        menu.options[] = [b.name for b in bodies]
        menu.i_selected[] = sel
        notify(menu.i_selected)
    end

    box_values(tbs) = [parse_num(tb.displayed_string[]) for tb in tbs]
    function box_name(default)
        nm = strip(name_tb.displayed_string[])
        return isempty(nm) ? default : String(nm)
    end

    function add_body!()
        animating[] && return
        k = length(bodies) + 1
        nm = box_name("{$k}")
        init = box_values(init_tbs)
        tgt = box_values(move_tbs)
        art = draw_frame!(ax, init_hom(init), Lobs; label=nm,
                          color=Makie.wong_colors()[mod1(k, 7)])
        push!(bodies, Body(nm, init, tgt, art))
        refresh_menu!(k)
        refresh_readout!("Cuerpo añadido en su pose inicial.\n")
    end

    function update_body!()
        (animating[] || isempty(bodies)) && return
        i = selected_index()
        b = bodies[i]
        b.name = box_name("{$i}")
        b.art.label[] = b.name
        b.init .= box_values(init_tbs)
        reset_frame!(b.art, init_hom(b.init))
        refresh_menu!(i)
        refresh_readout!("Cuerpo actualizado (nombre y pose inicial).\n")
    end

    function animate!(idxs)
        (animating[] || isempty(idxs)) && return
        valid_idxs = [i for i in idxs if 1 <= i <= length(bodies)]
        isempty(valid_idxs) && return

        frame = menu_value(frame_menu.selection[])
        order = menu_value(order_menu.selection[])
        sched = menu_value(sched_menu.selection[])
        dur = max(0.2, parse_num(dur_tb.displayed_string[]))
        n = max(2, round(Int, dur * fps))

        try
            T0 = [bodies[i].art.pose[] for i in valid_idxs]
            tgt = [copy(bodies[i].target) for i in valid_idxs]

            posefun = if frame === :absolute
                # Destino fijo (R1, p1): rotación y posición se interpolan por separado.
                T1 = [Se3(t...; deg=true) for t in tgt]
                tmode = sched === :simultaneous ? :simultaneous : order
                (j, s) -> Trinterp(T0[j], T1[j], s; mode=tmode, ease=true)
            else
                # Movimiento M = (d, Q) compuesto con T en el marco y el orden elegidos.
                ds = [t[1:3] for t in tgt]
                Qs = [Se3(0, 0, 0, t[4], t[5], t[6]; deg=true)[1:3, 1:3] for t in tgt]
                (j, s) -> Trmove(T0[j], ds[j], Qs[j], s;
                                 frame=frame, order=order, schedule=sched, ease=true)
            end

            # Evalúa ya los extremos: si algo es inválido, se informa aquí y no a mitad de animación.
            starts_ = [posefun(j, 0.0) for j in eachindex(valid_idxs)]
            ends_ = [posefun(j, 1.0) for j in eachindex(valid_idxs)]
            if all(isapprox(starts_[j], ends_[j]; atol=1e-9) for j in eachindex(valid_idxs))
                readout[] = "Movimiento nulo: el destino coincide con la pose actual.\n" *
                            "Cambia x, y, z, roll, pitch, yaw (o pulsa Reiniciar)."
                return
            end

            # Si el recorrido se sale del cubo, se agranda (y se actualiza la casilla "Ejes ±").
            pos_max = maximum(maximum(abs, posefun(j, s)[1:3, 4])
                              for j in eachindex(valid_idxs), s in range(0, 1; length=21))
            need = ceil(1.2 * pos_max + 0.5; digits=1)
            if need > lim[]
                lim[] = need
                Makie.set!(lim_tb, string(need))
            end

            animating[] = true
            readout[] = "Animando $(length(valid_idxs)) marco(s)…"

            @async try
                for step in 1:n
                    s = step / n
                    for (j, i) in enumerate(valid_idxs)
                        H = posefun(j, s)
                        set_pose!(bodies[i].art, H)
                        push_trail!(bodies[i].art, H)
                    end
                    refresh_readout!()
                    sleep(1 / fps)
                end
            catch err
                readout[] = "Error de animación:\n" * sprint(showerror, err)
                @error "trframes_gui: animation failed" exception = (err, catch_backtrace())
            finally
                animating[] = false
            end
        catch err
            animating[] = false
            readout[] = "No se pudo iniciar:\n" * sprint(showerror, err)
            @error "trframes_gui: could not start the animation" exception = (err, catch_backtrace())
        end
    end

    on(_ -> add_body!(), btn_add.clicks)
    on(_ -> update_body!(), btn_upd.clicks)
    on(_ -> selected_index() == 0 || animate!([selected_index()]), btn_go.clicks)
    on(_ -> animate!(collect(1:length(bodies))), btn_all.clicks)
    on(btn_reset.clicks) do _
        animating[] && return
        for b in bodies
            reset_frame!(b.art, init_hom(b.init))      # cada cuerpo vuelve a SU pose inicial
        end
        refresh_readout!("Todos los cuerpos vuelven a su pose inicial.\n")
    end

    add_body!()
    bodies[1].target .= [2.0, 1.0, 0.0, 0.0, 0.0, 90.0]   # valor de ejemplo
    load_boxes!()
    return fig
end

end

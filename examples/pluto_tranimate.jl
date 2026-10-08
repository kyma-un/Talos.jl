### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 5a1c0001-0000-4000-8000-000000000001
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.develop(path=joinpath(@__DIR__, ".."))     # este clon de Talos.jl
    Pkg.add(["WGLMakie", "PlutoUI"])
    using Talos, WGLMakie, PlutoUI
    WGLMakie.activate!()
end

# ╔═╡ 5a1c0002-0000-4000-8000-000000000002
md"""
# Talos.jl — marcos de referencia animados

`tranimate` es el `trplot` con movimiento: recibe una pose (o un vector de N poses) y anima
la transformación homogénea desde `{0}` (o desde `starts`) hasta cada objetivo.
"""

# ╔═╡ 5a1c0003-0000-4000-8000-000000000003
begin
    Ta = Se3(2.0, 0.0, 0.0, 0, 0, 90.0; deg=true)   # x y z roll pitch yaw
    Tb = Se3(0.0, 2.0, 1.0, 45.0, 0, 0; deg=true)
    Tc = Se2(-1.5, 1.0, π / 3)                        # SE(2): se embebe con Se3
    Ta
end

# ╔═╡ 5a1c0004-0000-4000-8000-000000000004
# Slider + botón ▶ dentro de la celda (interactivo con WGLMakie)
tranimate([Ta, Tb, Tc]; labels=["A", "B", "C"], mode=:rot_then_trans)

# ╔═╡ 5a1c0005-0000-4000-8000-000000000005
md"""
### Alternativa reactiva de Pluto
Un `@bind` con la fracción `s` y `Trinterp` + `trplot` (no hace falta ningún estado dentro de la figura).

`s =` $(@bind s Slider(0:0.01:1, default=0.0, show_value=true))
"""

# ╔═╡ 5a1c0006-0000-4000-8000-000000000006
trplot(Trinterp(Ta, Tb, s; mode=:simultaneous), scale=1.0)

# ╔═╡ 5a1c0007-0000-4000-8000-000000000007
md"""
### Vídeo (no depende de la sesión)
`record=` graba un `.mp4` / `.gif` y devuelve la ruta.
"""

# ╔═╡ 5a1c0008-0000-4000-8000-000000000008
begin
    path = tranimate([Ta, Tb, Tc]; record=joinpath(mktempdir(), "tranimate.mp4"), nframes=90)
    PlutoUI.LocalResource(path)
end

# ╔═╡ Cell order:
# ╟─5a1c0002-0000-4000-8000-000000000002
# ╠═5a1c0001-0000-4000-8000-000000000001
# ╠═5a1c0003-0000-4000-8000-000000000003
# ╠═5a1c0004-0000-4000-8000-000000000004
# ╟─5a1c0005-0000-4000-8000-000000000005
# ╠═5a1c0006-0000-4000-8000-000000000006
# ╟─5a1c0007-0000-4000-8000-000000000007
# ╠═5a1c0008-0000-4000-8000-000000000008

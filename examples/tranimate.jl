# Animación de N marcos sin interfaz gráfica (estilo trplot).
# Requiere un backend de Makie:  ] add GLMakie   (o WGLMakie / CairoMakie)
using GLMakie
using Talos

# Tres cuerpos, cada uno con su transformación homogénea objetivo (desde {0}).
Ta = Se3(2.0, 0.0, 0.0, 0, 0, 90.0; deg=true)     # x y z roll pitch yaw
Tb = Se3(0.0, 2.0, 1.0, 45.0, 0, 0; deg=true)
Tc = Se2(-1.5, 1.0, π / 3)                          # SE(2): se embebe con Se3

# Figura con slider + botón ▶ (se ve igual en Pluto con WGLMakie)
fig = tranimate([Ta, Tb, Tc]; labels=["A", "B", "C"], mode=:rot_then_trans)
display(fig)

# Grabar el vídeo (sirve con CairoMakie también):
# tranimate([Ta, Tb, Tc]; record="tranimate.mp4")

# Trayectoria entre dos poses arbitrarias:
# tranimate(Tb; starts=Ta, mode=:simultaneous)
# Pose intermedia sin dibujar:  Trinterp(Ta, Tb, 0.3; mode=:simultaneous)

# ── Orden de composición: pre- vs post-multiplicación ────────────────────────
# Mismo movimiento M (trasladar d y rotar Q), cuatro formas de componerlo con T0.
# Cada una termina en una pose DISTINTA porque el producto de matrices no conmuta.
# M = ([1.0, 2.0, 0.0], Rotz(90; deg=true))
# tranimate_move(Ta, M; frame=:body,  order=:trans_then_rot)   # Ta * Transl(d) * Rot(Q)
# tranimate_move(Ta, M; frame=:body,  order=:rot_then_trans)   # Ta * Rot(Q) * Transl(d)
# tranimate_move(Ta, M; frame=:world, order=:trans_then_rot)   # Rot(Q) * Transl(d) * Ta
# tranimate_move(Ta, M; frame=:world, order=:rot_then_trans)   # Transl(d) * Rot(Q) * Ta

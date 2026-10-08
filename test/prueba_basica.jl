# ═════════════════════════════════════════════════════════════════════════════
#  prueba_basica.jl — un programa sencillo para probar Talos.jl paso a paso
# ═════════════════════════════════════════════════════════════════════════════
#
#  Cómo correrlo (entorno recomendado, para no ensuciar el Project.toml de Talos):
#
#     julia> ]
#     pkg> activate --temp
#     pkg> dev /ruta/a/Talos.jl-main
#     pkg> add GLMakie                (solo si quieres ver las gráficas)
#     julia> include("/ruta/a/Talos.jl-main/test/prueba_basica.jl")
#
#  Solo hay 6 pasos. Cada uno: (1) qué es, (2) el código, (3) una comprobación ✔/✘.
# ═════════════════════════════════════════════════════════════════════════════

# ── Opciones (cámbialas a mano) ──────────────────────────────────────────────
MOSTRAR_GRAFICAS = true     # false = solo cálculos, sin ventanas
ABRIR_GUI        = false    # true  = al final abre la interfaz gráfica de marcos

# ── Paquetes ─────────────────────────────────────────────────────────────────
using Talos            # nuestra librería: Se2, Se3, Rotz, Transl, Trinterp, ...
using StaticArrays     # SVector: un vector pequeño de tamaño fijo, p. ej. [1.0, 2.0]

# Intentamos cargar GLMakie (la librería de gráficas). Si no está instalada,
# el programa sigue funcionando pero sin dibujar nada.
# OJO: esto va en su propia línea, ANTES de usar las gráficas. Cargar GLMakie y
# llamar a tranimate dentro del mismo bloque `if` da error de "world age".
HAY_GRAFICAS = try
    @eval using GLMakie
    true
catch
    println("(GLMakie no está instalado: se omiten las gráficas)")
    false
end

# ── Dos funciones de ayuda para que la salida sea fácil de leer ─────────────
RESULTADOS = Bool[]                       # aquí guardamos cada ✔ (true) o ✘ (false)

function comprobar(nombre, condicion)
    push!(RESULTADOS, condicion)
    println(condicion ? "   ✔ " : "   ✘ ", nombre)
end

# Los computadores redondean (0.1+0.2 no es exactamente 0.3), así que comparamos
# "casi iguales" en vez de "exactamente iguales".
cerca(a, b) = isapprox(a, b; atol=1e-9)


# ═════════════════════════════════════════════════════════════════════════════
println("\n1) ROTACIÓN — Rotz")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Una matriz 3×3 que gira vectores alrededor del eje z.
#           (Rotx y Roty giran alrededor de x e y; Rot2 es la versión 2D.)
# En robótica: la orientación de un eslabón. Cada articulación rotativa de un
#           brazo que gira sobre z es un Rotz(q), con q = ángulo de la articulación.

R = Rotz(90; deg=true)          # gira 90 grados (deg=true = "está en grados")
v = SVector(1.0, 0.0, 0.0)      # un vector apuntando en x
println("   El vector (1,0,0) girado 90° queda en: ", R * v)
comprobar("girar 90° lleva x hacia y  →  (0,1,0)", cerca(R * v, [0.0, 1.0, 0.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n2) TRASLACIÓN — Transl")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Una matriz 4×4 que solo desplaza un objeto (x, y, z), sin girarlo.
#           Transl(T) al revés: saca el vector posición de una matriz 4×4.
# En robótica: un eslabón recto de longitud L, o "la cámara está 10 cm delante".

T = Transl(1.0, 2.0, 3.0)
println("   Posición guardada en T: ", Transl(T))
comprobar("Transl(T) devuelve (1,2,3)", cerca(Transl(T), [1.0, 2.0, 3.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n3) POSE 2D DE UN ROBOT MÓVIL — Se2")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Se2(x, y, θ): posición (x,y) y hacia dónde mira (θ), en una matriz 3×3.
# En robótica: dónde está un carrito y hacia dónde apunta. Multiplicar la matriz por
#           un punto convierte de "coordenadas del robot" a "coordenadas del mundo".

robot = Se2(1.0, 2.0, 90.0; deg=true)   # está en (1,2) y mira hacia +y
obstaculo_robot = SVector(1.0, 0.0, 1.0)  # a 1 m delante de él (el "1" final es obligatorio)
obstaculo_mundo = robot * obstaculo_robot
println("   El obstáculo, visto desde el mundo, está en: ", obstaculo_mundo[1:2])
comprobar("obstáculo en (1,3)", cerca(obstaculo_mundo[1:2], [1.0, 3.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n4) POSE 3D — Se3")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Se3(x, y, z, roll, pitch, yaw): posición + orientación en 3D, matriz 4×4.
#           roll = giro sobre x, pitch = giro sobre y, yaw = giro sobre z.
# En robótica: la POSE de cualquier cosa: base, herramienta, cámara, objeto.
#           Las 3 primeras columnas de la matriz son los ejes x, y, z del objeto.

pose = Se3(1.0, 2.0, 3.0, 0.0, 0.0, 90.0; deg=true)   # yaw de 90°
eje_x_del_objeto = pose[1:3, 1]                        # primera columna
println("   El eje x del objeto apunta hacia: ", eje_x_del_objeto)
comprobar("con yaw=90° el eje x del objeto apunta a +y", cerca(eje_x_del_objeto, [0.0, 1.0, 0.0]))
comprobar("la posición es (1,2,3)", cerca(Transl(pose), [1.0, 2.0, 3.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n5) MULTIPLICAR MATRICES = ENCADENAR MOVIMIENTOS (brazo de 2 eslabones)")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Multiplicar poses las une, de la base hacia la punta.
# En robótica: esto ES la cinemática directa: con los ángulos de las articulaciones,
#           ¿dónde queda la punta del brazo?
#
#   base ──[gira q1]──[eslabón 1: 1.0 m]──[gira q2]──[eslabón 2: 0.5 m]── punta

# Una articulación que gira q alrededor de z, escrita como matriz 4×4:
articulacion(q) = Se3(Rotz(q), [0.0, 0.0, 0.0])

q1, q2 = 90.0, -90.0                 # ángulos en grados
punta = articulacion(deg2rad(q1)) * Transl(1.0, 0.0, 0.0) *
        articulacion(deg2rad(q2)) * Transl(0.5, 0.0, 0.0)
println("   Con q1=90° y q2=-90°, la punta está en: ", Transl(punta))
# Sube 1 m (eslabón 1 apunta a +y) y luego el eslabón 2 apunta a +x 0.5 m → (0.5, 1, 0)
comprobar("la punta está en (0.5, 1, 0)", cerca(Transl(punta), [0.5, 1.0, 0.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n6) INTERPOLAR ENTRE DOS POSES — Trinterp")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Trinterp(T0, T1, s) da la pose "a mitad de camino" entre T0 y T1.
#           s = 0 → T0,   s = 0.5 → la mitad,   s = 1 → T1.
#           La posición avanza en línea recta y la orientación gira de forma pareja.
# En robótica: mover la herramienta de un punto A a un punto B en línea recta
#           (movimiento lineal "MoveL"), calculando muchas poses intermedias.

inicio = Se3(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)                # en el origen, sin girar
final  = Se3(2.0, 0.0, 0.0, 0.0, 0.0, 90.0; deg=true)     # 2 m en x, girado 90°

mitad = Trinterp(inicio, final, 0.5)
println("   A la mitad del camino, la posición es: ", Transl(mitad))
comprobar("a la mitad: posición (1,0,0)",  cerca(Transl(mitad), [1.0, 0.0, 0.0]))
comprobar("a la mitad: girado 45°",        cerca(mitad[1:3, 1:3], Rotz(45; deg=true)))
comprobar("s=0 devuelve el inicio",        cerca(Trinterp(inicio, final, 0.0), inicio))
comprobar("s=1 devuelve el final",         cerca(Trinterp(inicio, final, 1.0), final))

# Modo: primero girar, luego trasladar (en vez de las dos cosas a la vez)
girado = Trinterp(inicio, final, 0.5; mode=:rot_then_trans)
comprobar("modo :rot_then_trans a la mitad: ya giró 90° y aún no se movió",
          cerca(girado[1:3, 1:3], Rotz(90; deg=true)) && cerca(Transl(girado), [0.0, 0.0, 0.0]))


# ═════════════════════════════════════════════════════════════════════════════
println("\n7) EL ORDEN IMPORTA — Trmove (pre- y post-multiplicación)")
# ═════════════════════════════════════════════════════════════════════════════
# ¿Qué es?  Un movimiento M = "trasladar d y rotar Q" se puede aplicar a una pose T de
#           cuatro maneras. El producto de matrices NO conmuta, así que cada una termina
#           en un lugar distinto:
#             frame=:body  (post-multiplicar, T*M):  usa los ejes del PROPIO cuerpo
#             frame=:world (pre-multiplicar,  M*T):  usa los ejes del MUNDO
#             order=:trans_then_rot / :rot_then_trans: qué se hace primero
# En robótica: "avanza 10 cm por el eje de la herramienta" (cuerpo) no es lo mismo que
#           "sube 10 cm en el eje z de la base" (mundo). Rotar en el marco del mundo
#           hace que el cuerpo GIRE ALREDEDOR DEL ORIGEN DEL MUNDO (órbita).

T0 = Se3(1.0, 0.0, 0.0, 0.0, 0.0, 90.0; deg=true)   # en (1,0,0), mirando a +y
d  = [1.0, 2.0, 0.0]                                 # trasladar
Q  = Rotz(90; deg=true)                              # rotar 90°

for frame in (:body, :world), order in (:trans_then_rot, :rot_then_trans)
    Tf = Trmove(T0, d, Q, 1.0; frame, order)
    println("   ", rpad(string(frame), 6), rpad(string(order), 16), " posición final = ", round.(Transl(Tf); digits=3))
end
comprobar("cuerpo, trasladar y luego rotar:  T0*Transl(d)*Rot(Q)  → (-1, 1, 0)",
          cerca(Transl(Trmove(T0, d, Q, 1.0; frame=:body, order=:trans_then_rot)), [-1.0, 1.0, 0.0]))
comprobar("mundo, trasladar y luego rotar:  Rot(Q)*Transl(d)*T0  → (-2, 2, 0)",
          cerca(Transl(Trmove(T0, d, Q, 1.0; frame=:world, order=:trans_then_rot)), [-2.0, 2.0, 0.0]))
comprobar("las cuatro poses finales son distintas",
          length(unique([round.(Transl(Trmove(T0, d, Q, 1.0; frame, order)); digits=6)
                         for frame in (:body, :world), order in (:trans_then_rot, :rot_then_trans)])) == 4)


# ═════════════════════════════════════════════════════════════════════════════
println("\nRESULTADO: ", count(RESULTADOS), " de ", length(RESULTADOS), " comprobaciones correctas")
# ═════════════════════════════════════════════════════════════════════════════


# ═════════════════════════════════════════════════════════════════════════════
#  GRÁFICAS (opcional)
# ═════════════════════════════════════════════════════════════════════════════
# trplot(T)        → dibuja UN marco de referencia (ejes x rojo, y verde, z azul).
# tranimate([...]) → anima N marcos desde el origen hasta sus poses objetivo.
#                    Trae un slider (para avanzar a mano) y un botón ▶.
# trframes_gui()   → ventana interactiva: tú escribes posición y ángulos y se anima.
#
# Cada figura se abre en una ventana; `wait(display(fig))` espera a que la cierres
# antes de pasar a la siguiente.

if MOSTRAR_GRAFICAS && HAY_GRAFICAS
    println("\nGráficas: cierra cada ventana para ver la siguiente.")
    try
        # (a) Un solo marco
        println("   a) trplot: la pose del paso 4")
        wait(display(trplot(pose; scale=0.5)))

        # (b) Tres cuerpos animados: A, B (3D) y C (2D, se convierte solo a 3D)
        println("   b) tranimate: 3 cuerpos. Usa el slider o el botón ▶")
        A = Se3(2.0, 0.0, 0.0, 0.0, 0.0, 90.0; deg=true)
        B = Se3(0.0, 2.0, 1.0, 45.0, 0.0, 0.0; deg=true)
        C = Se2(-1.5, 1.0, π / 3)
        wait(display(tranimate([A, B, C]; labels=["A", "B", "C"])))

        # (b2) El mismo movimiento relativo, componiendo en el marco del MUNDO (pre-multiplicar)
        println("   b2) tranimate_move: Rot(Q)*Transl(d)*T0 (la pose órbita el origen)")
        wait(display(tranimate_move(T0, (d, Q); frame=:world, order=:trans_then_rot)))

        # (c) La interfaz gráfica
        if ABRIR_GUI
            println("   c) trframes_gui: pulsa «+ Añadir cuerpo», escribe valores y «▶ Animar»")
            wait(display(trframes_gui()))
        end
    catch e
        # Si algo falla, lo mostramos completo (cópialo si necesitas pedir ayuda)
        println("\n✘ Error en las gráficas:")
        showerror(stdout, e, catch_backtrace())
        println()
    end
end

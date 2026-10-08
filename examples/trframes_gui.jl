# Interfaz gráfica: añade cuerpos, escribe traslación y rotación deseadas y anima.
using GLMakie
using Talos

fig = trframes_gui()          # trframes_gui(scale=1.5, fps=60)
screen = display(fig)
wait(screen)                  # mantiene la ventana abierta al ejecutar como script

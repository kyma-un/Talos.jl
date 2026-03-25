using LinearAlgebra
using RoboticsToolbox
using Rotations

# Definición de Rotaciones
RPY  = RotZYX(π, π/4, π/2)                                  
q_raw = [0.6, 1.0, 0.8, 0.2];
q = QuatRotation(q_raw / norm(q_raw))                       
AA_raw = [π/6, 0.0, 3.0, 5.0];
AA = AngleAxis(AA_raw[1], (AA_raw[2:4] / norm(AA_raw[2:4]))...)  
e = RotZYZ(π/3, π/4, π/6)     
function medir(f, repeticiones)
    f();  # Error de Inicio
    t0 = time_ns()
    for _ in 1:repeticiones
        f()
    end
    t1 = time_ns()
    return ((t1 - t0) / repeticiones )/ 1000  
end

N = 10000;   # repeticiones 

# RotMatrix 
tiempos_RotMatrix = Float64[];
push!(tiempos_RotMatrix, medir(() -> QuatRotation(RPY),N));
push!(tiempos_RotMatrix, medir(() -> AngleAxis(RPY),N));  
push!(tiempos_RotMatrix, medir(() -> RotZYZ(RPY),N)) 
 
# QuatRotation 
tiempos_QuatRotation = Float64[];
push!(tiempos_QuatRotation, medir(() -> RotZYX(q),N));
push!(tiempos_QuatRotation, medir(() -> AngleAxis(q),N)); 
push!(tiempos_QuatRotation, medir(() -> RotZYZ(q),N))  
 
# AngleAxis
tiempos_AngleAxis = Float64[];
push!(tiempos_AngleAxis, medir(() -> RotMatrix(AA),N));  
push!(tiempos_AngleAxis, medir(() -> QuatRotation(AA),N));  
push!(tiempos_AngleAxis, medir(() -> RotZYZ(AA),N));  
 
# RotZYZ 
tiempos_RotZYZ = Float64[];
push!(tiempos_RotZYZ, medir(() -> RotMatrix(e),N));  
push!(tiempos_RotZYZ, medir(() -> QuatRotation(e),N));
push!(tiempos_RotZYZ, medir(() -> AngleAxis(e),N));  
# Cargar tiempos desde el archivo txt
function cargar_tiempos(filename)
    tiempos = Float64[]
    open(filename, "r") do f
        for linea in eachline(f)
            # Buscar la línea con los números (la que tiene el vector)
            nums = split(strip(linea))
            for n in nums
                val = tryparse(Float64, n)
                if val !== nothing
                    push!(tiempos, val)
                end
            end
        end
    end
    return tiempos
end

# Cargar cada archivo
tiempos_MatrizRotacion = cargar_tiempos("tiempos_transformaciones.txt")[1:3];
tiempos_Quaternion     = cargar_tiempos("tiempos_transformaciones.txt")[4:6];
tiempos_AngleAxis      = cargar_tiempos("tiempos_transformaciones.txt")[7:9];
tiempos_ZYZ            = cargar_tiempos("tiempos_transformaciones.txt")[10:12];
# Diferencia entre tiempos de Julia y MATLAB

tmMb = [tiempos_MatrizRotacion; tiempos_Quaternion; tiempos_AngleAxis; tiempos_ZYZ];
tmJa = [tiempos_RotMatrix; tiempos_QuatRotation; tiempos_AngleAxis; tiempos_RotZYZ];
vdt=[];
rap=[];
for i in 1:length(tmMb)
    dt=tmJa[i] - (tmMb[i]*10^6)
    push!(vdt,abs(round(dt, sigdigits=4)));
    if dt > 0
        push!(rap, "Julia");
    else
        push!(rap, "Matlab");
    end
end
# Títulos de columnas 
titulos = ["Transformacion","Julia","Matlab","Error","Más Rápido"];
conversions = ["RPY_to_Quat","RPY_to_AA","RPY_to_ZYZ","Quat_to_RPY","Quat_to_AA","Quat_to_ZYZ","AA_to_RPY","AA_to_Quat","AA_to_ZYZ","ZYZ_to_RPY","ZYZ_to_Quat","ZYZ_to_AA"]  
# Armar matriz con tiempos 
matriz = Matrix{Any}(undef, length(titulos), length(tmMb));
matriz[1, :] = conversions;
matriz[2, :] = tmJa;
matriz[3, :] = tmMb;
matriz[4, :] = vdt;
matriz[5, :] = rap;

genTable(titulos, matriz,1)


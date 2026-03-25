using StaticArrays
using Rotations
using RoboticsToolbox
## Comprobacion de tiempos de conversión entre representaciones 
#  Rotaciones de prueba 
R  = rand(RotMatrix{3, Float64})
q  = rand(QuatRotation{Float64})
aa = rand(AngleAxis{Float64})
e  = rand(RotXYZ{Float64})

N = 10000;   # repeticiones 

function medir(f, repeticiones)
    f();  # Error de Inicio
    t0 = time_ns()
    for _ in 1:repeticiones
        f()
    end
    t1 = time_ns()
    return ((t1 - t0) / repeticiones )/ 1000  
end
 
 
# RotMatrix 
tiempos_RotMatrix = Float64[];
push!(tiempos_RotMatrix,0.0);
push!(tiempos_RotMatrix, medir(() -> QuatRotation(R),N));
push!(tiempos_RotMatrix, medir(() -> AngleAxis(R),N));  
push!(tiempos_RotMatrix, medir(() -> RotXYZ(R),N)) 
 
# QuatRotation 
tiempos_QuatRotation = Float64[];
push!(tiempos_QuatRotation, medir(() -> RotMatrix(q),N));
push!(tiempos_QuatRotation, 0.0);    
push!(tiempos_QuatRotation, medir(() -> AngleAxis(q),N)); 
push!(tiempos_QuatRotation, medir(() -> RotXYZ(q),N))  
 
# AngleAxis
tiempos_AngleAxis = Float64[];
push!(tiempos_AngleAxis, medir(() -> RotMatrix(aa),N));  
push!(tiempos_AngleAxis, medir(() -> QuatRotation(aa),N));  
push!(tiempos_AngleAxis, 0.0);    
push!(tiempos_AngleAxis, medir(() -> RotXYZ(aa),N));  
 
# RotXYZ 
tiempos_RotXYZ = Float64[];
push!(tiempos_RotXYZ, medir(() -> RotMatrix(e),N));  
push!(tiempos_RotXYZ, medir(() -> QuatRotation(e),N));
push!(tiempos_RotXYZ, medir(() -> AngleAxis(e),N));  
push!(tiempos_RotXYZ, 0.0); 


# Títulos de columnas 
titulos = ["Origen/Destino", "RotMatrix", "QuatRotation", "AngleAxis", "RotXYZ"];

# Armar matriz con tiempos 
matriz = Matrix{Any}(undef, 5, 4);
matriz[1, :] = titulos[2:end];
matriz[2, :] = tiempos_RotMatrix;
matriz[3, :] = tiempos_QuatRotation;
matriz[4, :] = tiempos_AngleAxis;
matriz[5, :] = tiempos_RotXYZ;

genTable(titulos, matriz,1)




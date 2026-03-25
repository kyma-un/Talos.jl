using LinearAlgebra
using RoboticsToolbox
using Rotations

# Definición de Rotaciones
RPY  = RotZYX(π, π/4, π/2)                                  
q_raw = [0.6, 1.0, 0.8, 0.2]
q = QuatRotation(q_raw / norm(q_raw))                       
AA_raw = [π/6, 0.0, 3.0, 5.0]
AA = AngleAxis(AA_raw[1], (AA_raw[2:4] / norm(AA_raw[2:4]))...)  
e = RotZYZ(π/3, π/4, π/6)     
# Funciones para obtener valores 
extract_RPY(r)  = [RotZYX(r).theta1, RotZYX(r).theta2, RotZYX(r).theta3]
extract_Quat(r) = let q = QuatRotation(r); [q.w, q.x, q.y, q.z] end
extract_AA(r) = let a = AngleAxis(r); [a.theta, a.axis_x, a.axis_y, a.axis_z] end
extract_ZYZ(r)  = [RotZYZ(r).theta1, RotZYZ(r).theta2, RotZYZ(r).theta3]

# Desde RPY
println("=== Desde RPY ===")
RPY_to_Quat = extract_Quat(RPY);  
println("RPY → Quat [w,x,y,z]:       ", RPY_to_Quat)
RPY_to_AA   = extract_AA(RPY);   
println("RPY → AA   [θ,rx,ry,rz]:    ", RPY_to_AA)
RPY_to_ZYZ  = extract_ZYZ(RPY);   
println("RPY → ZYZ  [α,β,γ]:         ", RPY_to_ZYZ)

# Desde Quaternion 
println("\n=== Desde Quaternion ===")
Quat_to_RPY = extract_RPY(q);    
println("Quat → RPY [ψ,θ,φ]:         ", Quat_to_RPY)
Quat_to_AA  = extract_AA(q);     
println("Quat → AA  [θ,rx,ry,rz]:    ", Quat_to_AA)
Quat_to_ZYZ = extract_ZYZ(q);    println("Quat → ZYZ [α,β,γ]:         ", Quat_to_ZYZ)

# Desde AngleAxis 
println("\n=== Desde AngleAxis ===")
AA_to_RPY  = extract_RPY(AA);    
println("AA → RPY  [ψ,θ,φ]:          ", AA_to_RPY)
AA_to_Quat = extract_Quat(AA);   
println("AA → Quat [w,x,y,z]:        ", AA_to_Quat)
AA_to_ZYZ  = extract_ZYZ(AA);    
println("AA → ZYZ  [α,β,γ]:          ", AA_to_ZYZ)

# Desde Euler ZYZ 
println("\n=== Desde ZYZ ===")
ZYZ_to_RPY  = extract_RPY(e);   
println("ZYZ → RPY  [ψ,θ,φ]:         ", ZYZ_to_RPY)
ZYZ_to_Quat = extract_Quat(e);   
println("ZYZ → Quat [w,x,y,z]:       ", ZYZ_to_Quat)
ZYZ_to_AA   = extract_AA(e);     
println("ZYZ → AA   [θ,rx,ry,rz]:    ", ZYZ_to_AA)

# Comparar valores con MATLAB 
function cargar_txt(filename)
    datos = Dict{String, Vector{Float64}}()
    open(filename, "r") do f
        for linea in eachline(f)
            partes = split(strip(linea))
            label  = String(partes[1][1:end-1])
            valores = parse.(Float64, partes[2:end])
            datos[label] = valores
        end
    end
    return datos
end

matlab_RPY  = cargar_txt("desde_RPY.txt")
matlab_Quat = cargar_txt("desde_Quat.txt")
matlab_AA   = cargar_txt("desde_AA.txt")
matlab_ZYZ  = cargar_txt("desde_ZYZ.txt")

julia_vals = Dict(
    "RPY_to_Quat"  => extract_Quat(RPY),
    "RPY_to_AA"    => extract_AA(RPY),
    "RPY_to_ZYZ"   => extract_ZYZ(RPY),
    "Quat_to_RPY"  => extract_RPY(q),
    "Quat_to_AA"   => extract_AA(q),
    "Quat_to_ZYZ"  => extract_ZYZ(q),
    "AA_to_RPY"    => extract_RPY(AA),
    "AA_to_Quat"   => extract_Quat(AA),
    "AA_to_ZYZ"    => extract_ZYZ(AA),
    "ZYZ_to_RPY"   => extract_RPY(e),
    "ZYZ_to_Quat"  => extract_Quat(e),
    "ZYZ_to_AA"    => extract_AA(e),
)

matlab_vals = merge(matlab_RPY, matlab_Quat, matlab_AA, matlab_ZYZ)

# Construcción de tabla 
headers     = ["Conversión", "Error máx", "¿Coinciden?"]
conversions = String[]
errores     = Float64[]
estados     = String[]

for key in sort(collect(keys(julia_vals)))
    j   = julia_vals[key]
    m   = matlab_vals[key]
    err = maximum(abs.(j .- m))
    push!(conversions, key)
    push!(errores,     round(err, sigdigits=4))
    #push!(estados,     err < 1e-6 ? "✓" : "✗ DIFERENCIA")
    push!(estados,     err < 1e-6 ? "Si" : "No")
end

# Armar matriz  con datos
matriz = Matrix{Any}(undef, 3, length(conversions));
matriz[1, :] = conversions;
matriz[2, :] = errores;
matriz[3, :] = estados;

genTable(headers, matriz)


using Talos
using Test

@testset "Talos" begin
    include("test_se2.jl")
    include("test_se3.jl")
    include("test_transl.jl")
    include("test_transl2.jl")
    include("test_rot2.jl")
    include("test_rotx.jl")
    include("test_roty.jl")
    include("test_rotz.jl")
    include("test_common.jl")
end

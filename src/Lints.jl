__precompile__(false)
module Lints
const libint2_au_to_bohr = 0.529177210903
export @lints
using CxxWrap
using libint_jll
@wrapmodule(joinpath(dirname(pathof(Lints)),"../deps/lib/libLints"),:Libint2)
function __init__()
    @initcxx
end
ENV["LIBINT_DATA_PATH"] = joinpath(dirname(pathof(Lints)),"../deps/lib/")
include("make_ND.jl")
include("projection.jl")

function Molecule(Z::Array{Int,1}, pos::Array{Array{Float64,1}})

    if length(Z) != size(pos,1) 
        throw(DimensionMismatch("The length of the atomic number vector (Z) and position vectors do not match"))
    end

    # Geometry is converted to a linear vector: [x; y; ...] -> [x₁, x₂, x₃, y₁, y₂, y₃, ...]
    posvec = vcat(pos...)

    # Convert geometry to Bohrs
    posvec ./= 0.529177210903
    Molecule(Z, posvec)
end

"""
    Lints.@lints

Inserte the wrapped code in between `Lints.libint2_init()` and `Lints.libint2_finalize()`. It guarentees the proper
initialization and finalization of Lints. 

# Example
```
@lints begin
    mol = Lints.Molecule([8,1,1],[[0.0,0.0,0.0],
                                  [1.0,0.0,0.0],
                                  [0.0,1.0,0.0]])
    bas = Lints.BasisSet("cc-pVDZ", mol)
    S = Lints.make_S(bas)
end
```
"""
macro lints(expr)
    quote
        Lints.libint2_init()
        $(esc(expr))
        Lints.libint2_finalize()
    end
end

end # module

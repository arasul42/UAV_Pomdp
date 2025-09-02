module Generators

using Random
using Combinatorics: combinations   # <-- add this

export all_valid_maps, uniform_initial_support

function all_valid_maps(H::Int, W::Int; n_lz::Int=1, n_obstacles::Int=3)
    N = H*W
    maps = Tuple[]
    for lz_cells in combinations(1:N, n_lz)
        remaining = setdiff(1:N, lz_cells)
        for ob_cells in combinations(remaining, n_obstacles)
            m = fill(:empty, N)
            for i in lz_cells; m[i] = :landing_zone; end
            for i in ob_cells; m[i] = :obstacle; end
            push!(maps, Tuple(m))
        end
    end
    maps
end

function uniform_initial_support(H::Int, W::Int, pos0::Tuple{Int,Int}, valid_maps)
    [(pos0, m) for m in valid_maps]
end
end # module

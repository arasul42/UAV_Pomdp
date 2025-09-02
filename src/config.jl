module Config
using Parameters: @with_kw
@with_kw struct GridConfig
    H::Int = 3
    W::Int = 3
    pos0::Tuple{Int,Int} = (2,2)
    n_obstacles::Int = 3
    n_lz::Int = 1
end
@with_kw struct RewardConfig
    step_cost::Float64 = -0.10
    r_land_correct::Float64 = 10.0
    r_land_obstacle::Float64 = -100.0
    r_land_empty::Float64 = -50.0
    γ::Float64 = 0.95
end
@with_kw struct ObsConfig
    pE::NTuple{3,Float64} = (0.8, 0.1, 0.1)
    pL::NTuple{3,Float64} = (0.1, 0.8, 0.1)
    pO::NTuple{3,Float64} = (0.1, 0.1, 0.8)
end
@with_kw struct RunConfig
    seed::Int = 42
    max_steps::Int = 100
    draw_every::Int = 1
    make_gif::Bool = true
    show_tree::Bool = false
    fixed_true_state::Union{Nothing,Any} = nothing
end
@with_kw struct PlanConfig
    kind::Symbol = :pomcp
    tree_queries::Int = 5_000
    max_depth::Int = 25
    c::Float64 = 10.0
end
end # module

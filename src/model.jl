module Model

using POMDPTools: SparseCat
using QuickPOMDPs, Distributions
using ..Config: GridConfig, RewardConfig, ObsConfig
using ..Types: UAVAction, Move, Inspect, Land, Obs, obs_label
using ..Generators: all_valid_maps, uniform_initial_support
export build_pomdp, build_pomdp_explicit
idx(r,c,W) = (r-1)*W + c
function move_clamped(p::Tuple{Int,Int}, dir::Symbol, H::Int, W::Int)
    d = Dict(:N=>(-1,0), :S=>(1,0), :E=>(0,1), :W=>(0,-1))[dir]
    rr, cc = p[1]+d[1], p[2]+d[2]
    return (1<=rr<=H && 1<=cc<=W) ? (rr,cc) : p
end
function obs_categorical(true_cls::Symbol, obs_cfg::ObsConfig)::Categorical
    p = true_cls === :landing_zone ? obs_cfg.pL :
        true_cls === :obstacle     ? obs_cfg.pO :
                                     obs_cfg.pE
    return Categorical(collect(p))
end
function build_pomdp(grid::GridConfig, rew::RewardConfig, obs_cfg::ObsConfig)
    H,W = grid.H, grid.W
    valid_maps = all_valid_maps(H,W; n_lz=grid.n_lz, n_obstacles=grid.n_obstacles)
    positions = [(r,c) for r in 1:H for c in 1:W]
    states = [(p, m) for p in positions for m in valid_maps]
    actions = vcat([Inspect(i) for i in 1:(H*W)], [Move(:N),Move(:S),Move(:E),Move(:W)], [Land()])
    support = uniform_initial_support(H, W, grid.pos0, valid_maps)
    weights = fill(1.0/length(support), length(support))
    initial = SparseCat(support, weights)   # discrete uniform over the support
    
    observations = 1:3
    transition(s, a) = begin
        p, m = s
        if a isa Move
            QuickPOMDPs.Deterministic((move_clamped(p, a.dir, H,W), m))
        else
            QuickPOMDPs.Deterministic(s)
        end
    end
# replace the old 3-arg observation(s, a, sp) with this:
    observation(a, sp) = begin
        if a isa Inspect
            cls = sp[2][a.cell]                 # look up true class in the NEXT state
            obs_categorical(cls, obs_cfg)       # returns Categorical over 1:3
        else
            QuickPOMDPs.Deterministic(1)        # non-inspect actions always observe 1 (:empty)
        end
    end

    reward(s, a) = begin
        r = rew.step_cost
        if a isa Land
            pos, m = s
            cell = idx(pos[1], pos[2], W)
            r += (m[cell] === :landing_zone ? rew.r_land_correct :
                  m[cell] === :obstacle     ? rew.r_land_obstacle :
                                              rew.r_land_empty)
        end
        r
    end
    meta = (H=H, W=W, idx=(r,c)->idx(r,c,W), obs_label=obs_label)
    pomdp = QuickPOMDPs.QuickPOMDP(
        states=states,
        actions=actions,
        observations=observations,
        discount=rew.γ,
        transition=transition,
        observation=observation,
        reward=reward,
        initialstate=initial,
    )
    return pomdp, meta
end
function build_pomdp_explicit(grid::GridConfig, rew::RewardConfig, obs_cfg::ObsConfig)
    return build_pomdp(grid, rew, obs_cfg)
end
end # module

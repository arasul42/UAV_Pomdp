module Rollout
using Random
using POMDPs
using POMDPTools
using Plots
import POMDPTools: action_info
import POMDPs: initialize_belief, update
using ..Types: Land
using ..Config: GridConfig, RewardConfig, ObsConfig, RunConfig, PlanConfig
using ..Model: build_pomdp
using ..Solvers: make_planner, is_offline
using ..Viz: draw_belief_heat, save_gif

export run_episode, compare_all

function run_episode(grid::GridConfig, rew::RewardConfig, obs::ObsConfig,
                     plan::PlanConfig, run::RunConfig; label_override=nothing,collect_frames::Bool=false)
    rng = MersenneTwister(run.seed)
    pomdp, meta = build_pomdp(grid, rew, obs)

    solver  = make_planner(plan.kind, plan; rng=rng)
    offline = is_offline(plan.kind)

    updater = DiscreteUpdater(pomdp)
    if offline
        policy = solve(solver, pomdp)           # OFFLINE once
        mode   = "OFFLINE ($(plan.kind))"
    else
        planner = solve(solver, pomdp)          # ONLINE replanning
        mode    = "ONLINE ($(plan.kind))"
    end
    @info "Running episode in $mode"

    s = run.fixed_true_state === nothing ? rand(rng, initialstate(pomdp)) : run.fixed_true_state
    b = initialize_belief(updater, initialstate(pomdp))

    # truth overlays (for plotting H/O)
    pos0, map0 = s
    lz_index = findfirst(==( :landing_zone), map0)
    ob_idx   = findall(==( :obstacle),      map0)

    anim  = Animation()
    frames_out = Plots.Plot[]
    cum_r = 0.0

    for t in 1:run.max_steps
        a = offline ? action(policy, b) : first(action_info(planner, b))
        r = reward(pomdp, s, a); cum_r += r
        sp = rand(rng, transition(pomdp, s, a))
        o  = rand(rng, observation(pomdp, a, sp))   # <- 2-arg observation(a, sp) for SARSOP
        s  = sp
        b  = update(updater, b, a, o)

        if run.draw_every > 0 && t % run.draw_every == 0
            lbl = label_override === nothing ? String(plan.kind) : label_override
            ttl = "$(lbl)  t=$(t), a=$(a), cum=$(round(cum_r, digits=2))"
            plt = draw_belief_heat(b, pomdp, meta; state=s, title=ttl,
                                   lz_index=lz_index, ob_indices=ob_idx)
            frame(anim, plt)
            if collect_frames                    # <-- added
                push!(frames_out, plt)
            end
        end
        a isa Land && break
    end

    run.make_gif && save_gif(anim, "uav_$(plan.kind).gif")
    return collect_frames ? frames_out : nothing     # <-- changed
end


# helper: safe frame access
frame_at(fr, i) = i <= length(fr) ? fr[i] : last(fr)

function compare_all(grid::GridConfig, rew::RewardConfig, obs::ObsConfig, run::RunConfig;
                     planA=PlanConfig(kind=:pomcp),
                     planB=PlanConfig(kind=:pomcpow),
                     planC=PlanConfig(kind=:sarsop))

    rng = MersenneTwister(run.seed)
    pomdp, _ = build_pomdp(grid, rew, obs)
    s0 = rand(rng, initialstate(pomdp))

    # same hidden start state for fairness
    run′ = RunConfig(
        seed = run.seed,
        max_steps = run.max_steps,
        draw_every = run.draw_every,
        make_gif = run.make_gif,
        show_tree = run.show_tree,
        fixed_true_state = s0,
    )

    # run all three; keep frames to compose a panel GIF
    fA = run_episode(grid, rew, obs, planA, run′; label_override="POMCP",   collect_frames=true)
    fB = run_episode(grid, rew, obs, planB, run′; label_override="POMCPOW", collect_frames=true)
    fC = run_episode(grid, rew, obs, planC, run′; label_override="SARSOP",  collect_frames=true)

    # stitch into a single wide GIF
    n = maximum((length(fA), length(fB), length(fC)))
    comp = Animation()
    for i in 1:n
        plt = plot(frame_at(fA, i), frame_at(fB, i), frame_at(fC, i),
                   layout=(1,3), size=(1260,460))
        frame(comp, plt)
    end
    save_gif(comp, "uav_compare_seed$(run.seed).gif")  # writes the combined GIF

    return nothing
end

end # module

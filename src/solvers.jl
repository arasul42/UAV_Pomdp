module Solvers
using Random, POMDPTools, BasicPOMCP, POMCPOW, SARSOP
using ..Config: PlanConfig
export make_planner, is_offline
is_offline(kind::Symbol) = kind in (:sarsop,)
function make_planner(kind::Symbol, plan::PlanConfig; rng=MersenneTwister(1))
    if kind === :pomcp
        return BasicPOMCP.POMCPSolver(tree_queries=plan.tree_queries, c=plan.c,
                                      max_depth=plan.max_depth, rng=rng)
    elseif kind === :pomcpow
        return POMCPOW.POMCPOWSolver(tree_queries=plan.tree_queries, max_depth=plan.max_depth,
                                     criterion=POMCPOW.MaxUCB(5), rng=rng)
    elseif kind === :sarsop
        return SARSOP.SARSOPSolver(precision=1e-3, timeout=10.0)
    else
        error("Unknown solver: $kind")
    end
end
end # module

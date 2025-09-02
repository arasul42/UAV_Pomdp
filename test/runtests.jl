using Test
using UAVLandingSim
let
    grid = UAVLandingSim.Config.GridConfig()
    rew  = UAVLandingSim.Config.RewardConfig()
    obs  = UAVLandingSim.Config.ObsConfig()
    pomdp, meta = UAVLandingSim.Model.build_pomdp(grid, rew, obs)
    @test length(POMDPs.states(pomdp)) > 0
    @test POMDPs.discount(pomdp) == rew.γ
    s = first(POMDPs.states(pomdp))
    a = UAVLandingSim.Types.Inspect(1)
    sp = s
    d = POMDPs.observation(pomdp, s, a, sp)
    @test isapprox(sum(d.p), 1.0; atol=1e-8)
    aN = UAVLandingSim.Types.Move(:N)
    spN = POMDPs.transition(pomdp, s, aN)
    @test !isempty(spN)
end

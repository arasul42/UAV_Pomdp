#!/usr/bin/env julia

using Pkg
# activate local environment in current folder
Pkg.activate(".")
Pkg.precompile()

using UAVLandingSim

# convenience alias
const C = UAVLandingSim.Config

# configuration
grid = C.GridConfig()   # 3×3 grid, start at (2,2), 1 landing zone, 3 obstacles
rew  = C.RewardConfig() # step cost, landing rewards/penalties
obs  = C.ObsConfig()    # observation noise model
run  = C.RunConfig(seed=5, max_steps=100, draw_every=1, make_gif=true)

# run all three solvers (POMCP, POMCPOW, SARSOP)
UAVLandingSim.Rollout.compare_all(grid, rew, obs, run)

println("All solvers completed. GIFs saved in current directory.")

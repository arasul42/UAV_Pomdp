# UAVLandingSim (modular)
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using UAVLandingSim
const C = UAVLandingSim.Config
grid = C.GridConfig(H=3, W=3, pos0=(2,2), n_obstacles=3, n_lz=1)
rew  = C.RewardConfig()
obs  = C.ObsConfig()
run  = C.RunConfig(seed=1, max_steps=40, draw_every=1, make_gif=true)

UAVLandingSim.Rollout.compare_all(grid, rew, obs, run)
```

module Viz

using Plots
using ColorTypes: RGB
using POMDPs

export cellwise_class_belief, draw_belief_heat, save_gif

"Compute per-cell class probabilities from a discrete belief."
function cellwise_class_belief(belief, pomdp, meta)
    H, W, idx = meta.H, meta.W, meta.idx
    grid = [Dict(:empty=>0.0, :landing_zone=>0.0, :obstacle=>0.0) for _ in 1:H*W]
    all_states = POMDPs.states(pomdp)
    @inbounds for (i, p) in enumerate(belief.b)
        p == 0.0 && continue
        (_, m) = all_states[i]
        for r in 1:H, c in 1:W
            k = idx(r, c)
            grid[k][m[k]] += p
        end
    end
    grid
end

# "Draw RGB heatmap: red=obstacle, green=landing_zone, blue=empty. Marks UAV with '+'."
# "Draw RGB heatmap: red=obstacle, green=landing_zone, blue=empty.
#  Marks UAV with '+'. Optionally overlays true map: H (LZ) and O (obstacles)."
function draw_belief_heat(belief, pomdp, meta;
                          state=nothing, title="UAV", size=(420,460),
                          lz_index=nothing, ob_indices::Vector{Int}=Int[])
    cell_bel = cellwise_class_belief(belief, pomdp, meta)
    colors = [RGB(cell_bel[i][:obstacle], cell_bel[i][:landing_zone], cell_bel[i][:empty])
              for i in 1:(meta.H*meta.W)]
    plt = heatmap(reshape(colors, (meta.W, meta.H))';
                  yflip=true, axis=false, size=size, title=title)

    # overlay ground truth if provided
    if lz_index !== nothing
        rr = (lz_index-1) ÷ meta.W + 1
        cc = (lz_index-1) % meta.W + 1
        annotate!(cc, rr, text("H", :black, :bold, 16))
    end
    for k in ob_indices
        rro = (k-1) ÷ meta.W + 1
        cco = (k-1) % meta.W + 1
        annotate!(cco, rro, text("O", :black, :bold, 16))
    end

    # UAV position
    if state !== nothing
        ur, uc = state[1]
        annotate!(uc, ur, text("+", :white, :bold, 40))
    end
    return plt
end


save_gif(anim, path::AbstractString; fps=2) = gif(anim, path, fps=fps)

end # module

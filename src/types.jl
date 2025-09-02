module Types
export UAVAction, Move, Inspect, Land, Obs, obs_label
abstract type UAVAction end
struct Move    <: UAVAction; dir::Symbol; end
struct Inspect <: UAVAction; cell::Int; end
struct Land    <: UAVAction; end
Base.show(io::IO, a::Move)    = print(io, Symbol(a.dir))
Base.show(io::IO, a::Inspect) = print(io, "Inspect(", a.cell, ")")
Base.show(io::IO, ::Land)     = print(io, "Land")
const Obs = Int
obs_label(o::Obs) = (o==1 ? :empty : o==2 ? :landing_zone : :obstacle)
end # module

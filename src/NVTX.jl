__precompile__()

module NVTX

const ext = joinpath(dirname(@__DIR__), "deps", "ext.jl")
isfile(ext) || error("NVTX.jl has not been built, please run Pkg.build(\"NVTX\").")
include(ext)
if !configured
    # default (non-functional) values for critical variables,
    # making it possible to _load_ the package at all times.
    const libnvtx = nothing
end


const active = Ref{Bool}(true)

"""
    start()
    stop()

Controls whether calls to NVTX.jl effectively generate profiling data (enabled by default).
This is a feature of NVTX.jl, useful in combination with nvprof's `--profile-from-start off`
to narrow down the region where profiling data is collected.

See also: [`@activate`](@ref)
""" 
start() = (active[] = true)

stop()  = (active[] = false)
@doc (@doc start) stop

"""
    @activate ex

Runs the expressions with the NVTX API activated. Requires a manual call to [`stop`](@ref)
to disable the API beforehand.
"""
macro activate(ex)
    quote
        start()
        local ret = $(esc(ex))
        stop()
        ret
    end
end


include("markers.jl")
include("ranges.jl")
# TODO: domains
# TODO: CUDA API


end

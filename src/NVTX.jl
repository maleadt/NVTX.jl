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


const active = Ref{Bool}(false)

"""
    start()
    stop()

Controls whether calls to NVTX.jl effectively generate profiling data (disabled by default).
This is a feature of NVTX.jl, useful in combination with nvprof's `--profile-from-start off`
to narrow down the region where profiling data is collected.

See also: [`@activate`](@ref)
""" 
start() = (active[] = true)

stop()  = (active[] = false)
@doc (@doc start) stop

"""
    @activate ex

Runs the expressions with the NVTX API activated.
"""
macro activate(ex)
    quote
        start()
        local ret = $(esc(ex))
        stop()
        ret
    end
end


include("domains.jl")
include("markers.jl")
include("ranges.jl")
# TODO: CUDA API


end

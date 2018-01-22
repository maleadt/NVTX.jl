## low-level API

const nvtxRangeId_t = UInt64
function start_range(msg::String)
    active[] && ccall((:nvtxRangeStartA, libnvtx), nvtxRangeId_t, (Cstring,), msg)
end
function end_range(id::nvtxRangeId_t)
    active[] && ccall((:nvtxRangeEnd, libnvtx), Void, (nvtxRangeId_t,), id)
end

function push_range(msg::String)
    if active[]
        rv = ccall((:nvtxRangePushA, libnvtx), Cint, (Cstring,), msg)
        if rv < 0
            warn("Could not push a new range")
        end
    end
end
function pop_range()
    if active[]
        rv = ccall((:nvtxRangePop, libnvtx), Cint, ())
        if rv < 0
            warn("Could not pop a new range")
        end
    end
end

## high-level API

struct Range
    id::nvtxRangeId_t
end

"""
    range(msg)

Create and start a new range. The range is not automatically ended, use
[`end(::Range)`](@ref) for that.

Use this API if you need overlapping ranges, for scope-based use [`@range`](@ref) instead.
"""
function range(msg)
    Range(start_range(msg))
end

end(r::Range) = end_range(r.id)

"""
    @range "msg" ex

Create a new range and execute `ex`. The range is popped automatically afterwards.

See also: [`range`](@ref)
"""
macro range(msg, ex)
    quote
        push_range($(esc(msg)))
        local ret = $(esc(ex))
        pop_range()
        ret
    end
end

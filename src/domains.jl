## low-level API

const nvtxDomainHandle_t = Ptr{Cvoid}

struct Domain
    handle::nvtxDomainHandle_t

    function Domain(name::String)
        info("Creating domain $name")
        handle = ccall((:nvtxDomainCreateA, libnvtx), nvtxDomainHandle_t, (Cstring,), name)
        new(handle)
    end
end

Base.unsafe_convert(::Type{nvtxDomainHandle_t}, dom::Domain) = dom.handle

unsafe_destroy!(dom::Domain) =
    ccall((:nvtxDomainDestroy, libnvtx), Nothing, (nvtxDomainHandle_t,), dom)


## high-level API

function domain(f::Function, name::String)
    dom = Domain(name)
    f(dom)
    unsafe_destroy!(dom)
end

# TODO: support for ex mark/range, with domain argument
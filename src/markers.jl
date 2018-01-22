function mark(msg::String)
    active[] && ccall((:nvtxMarkA, libnvtx), Cvoid, (Cstring,), msg)
end

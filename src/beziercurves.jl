using Makie.GeometryBasics
using Makie.GeometryBasics.StaticArrays
using LinearAlgebra: normalize, ⋅

####
#### Type definitions
####

abstract type PathCommand{PT<:AbstractPoint} end

struct BezierPath{PT}
    commands::Vector{PathCommand{PT}}
end

struct MoveTo{PT} <: PathCommand{PT}
    p::PT
end

struct LineTo{PT} <: PathCommand{PT}
    p::PT
end

struct CurveTo{PT} <: PathCommand{PT}
    c1::PT
    c2::PT
    p::PT
end

ptype(::Union{BezierPath{PT}, Type{BezierPath{PT}}}) where {PT} = PT


####
#### Helper functions to work with bezier pathes
####

"""
    interpolate(c::PathCommand, p0, t)

Returns positions along the path `c` starting from `p0` in range `t ∈ [0, 1]`.
"""
interpolate(c::LineTo{PT}, p0, t) where {PT} = p0 + t*(c.p - p0) |> PT
function interpolate(c::CurveTo{PT}, p0, t) where {PT}
    p1, p2, p3 = c.c1, c.c2, c.p
    (1 - t)^3 * p0 + 3(t - 2t^2 + t^3) * p1 + 3(t^2 -t^3) * p2 + t^3 * p3 |> PT
end

"""
    tangent(c::PathCommand, p0, t)

Returns tanget vector along the path `c` starting from `p0` in range `t ∈ [0, 1]`.
"""
tangent(c::LineTo, p0, _) = normalize(c.p - p0)
function tangent(c::CurveTo{PT}, p0, t) where PT
    p1, p2, p3 = c.c1, c.c2, c.p
    normalize(-3(1 - t)^2 * p0 + 3(1 - 4t + 3t^2) * p1 + 3(2t -3t^2) * p2 + 3t^2 * p3) |> PT
end

"""
    discretize!(v::Vector{AbstractPint}, c::PathCommand)

Append interpolated points of path `c` to pos vector `v`
"""
discretize!(v::Vector{<:AbstractPoint}, c::Union{MoveTo, LineTo}) = push!(v, c.p)
function discretize!(v::Vector{<:AbstractPoint}, c::CurveTo)
    N0 = length(v)
    p0 = v[end]
    N = 60 # TODO: magic number for discrtization
    resize!(v, N0 + N)
    dt = 1.0/N
    for (i, t) in enumerate(dt:dt:1.0)
        v[N0 + i] = interpolate(c, p0, t)
    end
end

"""
    discretize(path::BezierPath)

Return vector of points which represent the given `path`.
"""
function discretize(path::BezierPath{T}) where {T}
    v = Vector{T}()
    for c in path.commands
        discretize!(v, c)
    end
    return v
end

"""
    interpolate(p::BezierPath, t)

Parametrize path `p` from `t ∈ [0, 1]`. Return postion at `t`.

TODO: Points are not necessarily evenly spaced!
"""
function interpolate(p::BezierPath{PT}, t) where PT
    @assert p.commands[begin] isa MoveTo
    N = length(p.commands) - 1

    tn = N*t
    seg = min(floor(Int, tn), N-1)
    tseg = tn - seg

    p0 = p.commands[seg+1].p
    return interpolate(p.commands[seg+2], p0, tseg)
end

"""
    tangent(p::BezierPath, t)

Parametrize path `p` from `t ∈ [0, 1]`. Return tangent at `t`.
"""
function tangent(p::BezierPath, t)
    @assert p.commands[begin] isa MoveTo
    N = length(p.commands) - 1

    tn = N*t
    seg = min(floor(Int, tn), N-1)
    tseg = tn - seg

    p0 = p.commands[seg+1].p
    return tangent(p.commands[seg+2], p0, tseg)
end

"""
    waypoints(p::BezierPath)

Returns all the characteristic points of the path. For debug reasons.
"""
function waypoints(p::BezierPath{PT}) where {PT}
    v = PT[]
    for c in p.commands
        if c isa CurveTo
            push!(v, c.c1)
            push!(v, c.c2)
        end
        push!(v, c.p)
    end
    return v
end


####
#### Special constructors to create bezier pathes
####

"""
    BezierPath(P::Vararg{PT, N}; tangents, tfactor=.5) where {PT<:AbstractPoint, N}

Create a bezier path by natural cubic spline interpolation of the points `P`.
If there are only to points and no tangents return a straight line.

The `tangets` kw allows you pass two vectors as tangents for the first and the
last point. The `tfactor` affects the curvature on the start and end given some
tangents.
"""
function BezierPath(P::Vararg{PT, N}; tangents=nothing, tfactor=.5) where {PT<:AbstractPoint, N}
    @assert N>2

    # cubic_spline will work for each dimension separatly
    pxyz = cubic_spline(map(p -> p[1], P)) # get first dimension
    for i in 2:length(PT) # append all other dims
        pxyz = hcat(pxyz, cubic_spline(map(p -> p[i], P)))
    end

    # create waypoints from waypoints in separat dementions
    WP = SVector{length(P)-1, PT}(PT(p) for p in eachrow(pxyz))

    commands = Vector{PathCommand{PT}}(undef, N)
    commands[1] = MoveTo(P[1])

    # first command, recalculate WP if tangent is given
    first_wp = WP[1]
    if tangents !== nothing
        p1, p2, t = P[1], P[2], normalize(tangents[1])
        dir = p2 - p1
        d = tfactor * norm(dir ⋅ t)
        first_wp = PT(p1+d*t)
    end
    commands[2] = CurveTo(first_wp,
                          2*P[2] - WP[2],
                          P[2])
    # middle commands
    for i in 3:(N-1)
        commands[i] = CurveTo(WP[i-1],
                              2*P[i] - WP[i],
                              P[i])
    end
    # last command, recalculate last WP if tangent is given
    last_wp = (P[N] + WP[N-1])/2
    if tangents !== nothing
        p1, p2, t = P[N-1], P[N], normalize(tangents[2])
        dir = p2 - p1
        d = tfactor * norm(dir ⋅ t)
        last_wp = PT(p2-d*t)
    end
    commands[N] = CurveTo(WP[N-1],
                          last_wp,
                          P[N])

    BezierPath(commands)
end

function BezierPath(P::Vararg{PT, 2}; tangents=nothing, tfactor=.5) where {PT<:AbstractPoint}
    p1, p2 = P
    if tangents === nothing
        return BezierPath([MoveTo(p1),
                           LineTo(p2)])
    else
        t1, t2 = normalize(tangents[1]), normalize(tangents[2])
        dir = p2 - p1
        d1 = tfactor * norm(dir ⋅ t1)
        d2 = tfactor * norm(dir ⋅ t2)
        return BezierPath([MoveTo(p1),
                           CurveTo(PT(p1+d1*t1),
                                   PT(p2-d2*t2),
                                   p2)])
    end
end

"""
    cubic_spline(p)

Given a number of points in one dimension calculate waypoints between them.

    cubic_spline(x1, x2, x3)

Will return the x coordinates of the waypoints `wp1` and `wp2`.
Those are the first waypoints between in the cubic bezier sense.
"""
function cubic_spline(p)
    N = length(p) - 1

    M = SMatrix{N,N}(if i==j # diagonal
                         if i==1; 2; elseif i==N; 7; else 4 end
                     elseif i==j+1 # lower
                         if i==N; 2; else 1 end
                     elseif i==j-1 # upper
                         1
                     else
                         0
                     end for i in 1:N, j in 1:N)

    b = SVector{N}(if i == 1
                       p[i] + 2p[i+1]
                   elseif i == N
                       8p[i] + p[i+1]
                   else
                       4p[i] + 2p[i+1]
                   end for i in 1:N)
    return M \ b
end
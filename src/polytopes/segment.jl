# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Segment(p1, p2)

An oriented line segment with end points `p1`, `p2`.
The segment can be called as `s(t)` with `t` between
`0` and `1` to interpolate linearly between its endpoints.

See also [`Rope`](@ref), [`Ring`](@ref), [`Line`](@ref).
"""
@polytope Segment 1 2

nvertices(::Type{<:Segment}) = 2

Base.minimum(s::Segment) = s.vertices[1]

Base.maximum(s::Segment) = s.vertices[2]

Base.extrema(s::Segment) = s.vertices[1], s.vertices[2]

measure(s::Segment) = norm(s.vertices[2] - s.vertices[1])

boundary(s::Segment) = PointSet(pointify(s))

center(s::Segment{Dim,T}) where {Dim,T} = s(T(0.5))

==(s1::Segment, s2::Segment) = s1.vertices == s2.vertices

Base.isapprox(s1::Segment, s2::Segment; kwargs...) =
  all(isapprox(v1, v2; kwargs...) for (v1, v2) in zip(s1.vertices, s2.vertices))

function (s::Segment)(t)
  if t < 0 || t > 1
    throw(DomainError(t, "s(t) is not defined for t outside [0, 1]."))
  end
  a, b = s.vertices
  a + t * (b - a)
end

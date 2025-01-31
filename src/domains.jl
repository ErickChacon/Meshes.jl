# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Domain

A domain is an indexable collection of geometries (e.g. mesh).
"""
abstract type Domain{Dim,T} end

"""
    element(domain, ind)

Return the `ind`-th element in the `domain`.
"""
element(domain::Domain, ind::Int)

"""
    nelements(domain)

Return the number of elements in the `domain`.
"""
function nelements end

# ----------
# FALLBACKS
# ----------

==(d1::Domain, d2::Domain) = nelements(d1) == nelements(d2) && all(d1[i] == d2[i] for i in 1:nelements(d1))

Base.isapprox(d1::Domain, d2::Domain) = nelements(d1) == nelements(d2) && all(d1[i] ≈ d2[i] for i in 1:nelements(d1))

Base.getindex(d::Domain, ind::Int) = element(d, ind)

Base.getindex(d::Domain, inds::AbstractVector) = [element(d, ind) for ind in inds]

Base.firstindex(d::Domain) = 1

Base.lastindex(d::Domain) = nelements(d)

Base.length(d::Domain) = nelements(d)

Base.iterate(d::Domain, state=1) = state > nelements(d) ? nothing : (d[state], state + 1)

Base.eltype(d::Domain) = eltype([d[i] for i in 1:nelements(d)])

Base.keys(d::Domain) = 1:nelements(d)

Base.parent(d::Domain) = d

Base.parentindices(d::Domain) = 1:nelements(d)

Base.vcat(d1::Domain, d2::Domain) = GeometrySet(vcat(collect(d1), collect(d2)))

Base.vcat(ds::Domain...) = reduce(vcat, ds)

"""
    embeddim(domain)

Return the number of dimensions of the space where the `domain` is embedded.
"""
embeddim(::Type{<:Domain{Dim,T}}) where {Dim,T} = Dim
embeddim(d::Domain) = embeddim(typeof(d))

"""
    paramdim(domain)

Return the number of parametric dimensions of the `domain` as the number of
parametric dimensions of its elements.
"""
paramdim(d::Domain) = paramdim(first(d))

"""
    coordtype(domain)

Return the machine type of each coordinate used to describe the `domain`.
"""
coordtype(::Type{<:Domain{Dim,T}}) where {Dim,T} = T
coordtype(d::Domain) = coordtype(typeof(d))

"""
    centroid(domain, ind)

Return the centroid of the `ind`-th element in the `domain`.
"""
centroid(d::Domain, ind::Int) = centroid(d[ind])

"""
    centroid(domain)

Return the centroid of the `domain`, i.e. the centroid of all
its element's centroids.
"""
function centroid(d::Domain{Dim,T}) where {Dim,T}
  coords(i) = coordinates(centroid(d, i))
  volume(i) = measure(element(d, i))
  n = nelements(d)
  x = coords.(1:n)
  w = volume.(1:n)
  all(iszero, w) && (w = ones(T, n))
  Point(sum(w .* x) / sum(w))
end

"""
    extrema(domain)

Return the top left and bottom right corners of the
bounding box of the `domain`.
"""
Base.extrema(d::Domain) = extrema(boundingbox(d))

"""
    topology(domain)

Return the topological structure of the `domain`.
"""
topology(d::Domain) = d.topology

# -----------
# IO METHODS
# -----------

function Base.summary(io::IO, d::Domain{Dim,T}) where {Dim,T}
  nelm = nelements(d)
  name = prettyname(d)
  print(io, "$nelm $name{$Dim,$T}")
end

Base.show(io::IO, d::Domain) = summary(io, d)

function Base.show(io::IO, ::MIME"text/plain", d::Domain)
  summary(io, d)
  println(io)
  printelms(io, d)
end

# ----------------
# IMPLEMENTATIONS
# ----------------

include("sets.jl")
include("mesh.jl")
include("trajectories.jl")

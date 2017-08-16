## AlmostBandedMatrix



struct AlmostBandedMatrix{T} <: AbstractMatrix{T}
    bands::BandedMatrix{T}
    fill::LowRankMatrix{T}
    function AlmostBandedMatrix{T}(bands::BandedMatrix{T},fill::LowRankMatrix{T}) where T
        if size(bands) ≠ size(fill)
            error("Data and fill must be compatible size")
        end
        new{T}(bands,fill)
    end
end

AlmostBandedMatrix(bands::BandedMatrix,fill::LowRankMatrix) =
    AlmostBandedMatrix{promote_type(eltype(bands),eltype(fill))}(bands,fill)

AlmostBandedMatrix(::Type{T},n::Integer,m::Integer,l::Integer,u::Integer,r::Integer) where {T} =
    AlmostBandedMatrix(BandedMatrix(T,n,m,l,u),LowRankMatrix(T,n,m,r))


abzeros(::Type{T},n::Integer,m::Integer,l::Integer,u::Integer,r::Integer) where {T} =
    AlmostBandedMatrix(bzeros(T,n,m,l,u),lrzeros(T,n,m,r))


for MAT in (:AlmostBandedMatrix, :AbstractMatrix, :AbstractArray)
    @eval convert(::Type{$MAT{T}},A::AlmostBandedMatrix) where {T} =
        AlmostBandedMatrix(AbstractMatrix{T}(A.bands),AbstractMatrix{T}(A.fill))
end


Base.size(A::AlmostBandedMatrix) = size(A.bands)
Base.IndexStyle(::Type{ABM}) where {ABM<:AlmostBandedMatrix} =
    IndexCartesian()


function getindex(B::AlmostBandedMatrix,k::Integer,j::Integer)
    if j > k + bandwidth(B.bands,2)
        B.fill[k,j]
    else
        B.bands[k,j]
    end
end

# can only change the bands, not the fill
function Base.setindex!(B::AlmostBandedMatrix,v,k::Integer,j::Integer)
        B.bands[k,j] = v
end


function pad!(B::AlmostBandedMatrix,n::Integer,m::Integer)
    pad!(B.bands,n,m)
    pad!(B.fill,n,m)
    B
end

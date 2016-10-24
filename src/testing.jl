## Testing
# These routines are for the unit tests

using Base.Test


## Spaces Tests


function testspace(S::Space;minpoints=1)
    # transform tests
    v = rand(max(minpoints,min(100,ApproxFun.dimension(S))))
    plan = plan_transform(S,v)
    @test transform(S,v)  == transform(S,v,plan)

    iplan = plan_itransform(S,v)
    @test itransform(S,v)  == itransform(S,v,iplan)

    for k=max(1,minpoints):min(5,dimension(S))
        v = [zeros(k-1);1.0]
        @test_approx_eq transform(S,itransform(S,v)) v
    end

    @test_approx_eq transform(S,itransform(S,v)) v
    @test_approx_eq itransform(S,transform(S,v)) v
end





## Operator Tests

function backend_functionaltest(A)
    @test rowstart(A,1) == 1
    @test colstop(A,1) == 1
    B=A[1:10]
    eltype(B) == eltype(A)
    for k=1:5
        @test_approx_eq B[k] A[k]
        @test isa(A[k],eltype(A))
    end
    @test B.' == A[1,1:10]
    @test B[3:10] == A[3:10]
    @test B == [A[k] for k=1:10]



    co=cache(A)
    @test co[1:10] == A[1:10]
    @test co[1:10] == A[1:10]
    @test co[20:30] == A[1:30][20:30] == A[20:30]
end

# Check that the tests pass after conversion as well
function functionaltest{T<:Real}(A::Operator{T})
    backend_functionaltest(A)
    backend_functionaltest(Operator{Float64}(A))
    backend_functionaltest(Operator{Float32}(A))
    backend_functionaltest(Operator{Complex128}(A))
end

function functionaltest{T<:Complex}(A::Operator{T})
    backend_functionaltest(A)
    backend_functionaltest(Operator{Complex64}(A))
    backend_functionaltest(Operator{Complex128}(A))
end

function backend_infoperatortest(A)
    @test isinf(size(A,1))
    @test isinf(size(A,2))
    B=A[1:5,1:5]
    eltype(B) == eltype(A)

    for k=1:5,j=1:5
        @test_approx_eq B[k,j] A[k,j]
        @test isa(A[k,j],eltype(A))
    end

    @test_approx_eq A[1:5,1:5][2:5,1:5] A[2:5,1:5]
    @test_approx_eq A[1:5,2:5] A[1:5,1:5][:,2:end]
    @test_approx_eq A[1:10,1:10][5:10,5:10] [A[k,j] for k=5:10,j=5:10]
    @test_approx_eq A[1:10,1:10][5:10,5:10] A[5:10,5:10]
    @test_approx_eq A[1:30,1:30][20:30,20:30] A[20:30,20:30]

    for k=1:10
        @test isfinite(colstart(A,k)) && colstart(A,k) > 0
        @test isfinite(rowstart(A,k)) && colstart(A,k) > 0
    end

    co=cache(A)
    @test_approx_eq co[1:10,1:10] A[1:10,1:10]
    @test_approx_eq co[1:10,1:10] A[1:10,1:10]
    @test_approx_eq co[20:30,20:30] A[1:30,1:30][20:30,20:30]

    let C=cache(A)
        resizedata!(C,5,35)
        resizedata!(C,10,35)
        @test_approx_eq C.data[1:10,1:C.datasize[2]] A[1:10,1:C.datasize[2]]
    end
end

# Check that the tests pass after conversion as well
function infoperatortest{T<:Real}(A::Operator{T})
    backend_infoperatortest(A)
    backend_infoperatortest(Operator{Float64}(A))
    backend_infoperatortest(Operator{Float32}(A))
    backend_infoperatortest(Operator{Complex128}(A))
end

function infoperatortest{T<:Complex}(A::Operator{T})
    backend_infoperatortest(A)
    backend_infoperatortest(Operator{Complex64}(A))
    backend_infoperatortest(Operator{Complex128}(A))
end

function raggedbelowoperatortest(A)
    @test israggedbelow(A)
    for k=1:20
        @test isfinite(colstop(A,k))
    end
    infoperatortest(A)
end

function bandedbelowoperatortest(A)
    @test isbandedbelow(A)
    @test isfinite(bandwidth(A,1))
    raggedbelowoperatortest(A)

    for k=1:10
        @test colstop(A,k) ≤ k + bandwidth(A,1)
    end
end


function almostbandedoperatortest(A)
    bandedbelowoperatortest(A)
end

function bandedoperatortest(A)
    @test isbanded(A)
    @test isfinite(bandwidth(A,2))
    almostbandedoperatortest(A)
    for k=1:10
        @test rowstop(A,k) ≤ k + bandwidth(A,2)
    end

    @test isa(A[1:10,1:10],BandedMatrix)
end


function bandedblockoperatortest(A)
    @test isbandedblock(A)
    raggedbelowoperatortest(A)
    @test isfinite(blockbandwidth(A,2))
    @test isfinite(blockbandwidth(A,1))

    for K=1:10
        @test K ≤ blockcolstop(A,K) ≤ K + blockbandwidth(A,1) < ∞
        @test K ≤ blockrowstop(A,K) ≤ K + blockbandwidth(A,2) < ∞
    end
end

function bandedblockbandedoperatortest(A)
    @test isbandedblockbanded(A)
    bandedblockoperatortest(A)
    @test isfinite(subblockbandwidth(A,1))
    @test isfinite(subblockbandwidth(A,2))

    @test isa(A[1:10,1:10],BandedBlockBandedMatrix)
end

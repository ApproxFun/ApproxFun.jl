export setplotter


plotter={:contour=>"PyPlot",
    :plot=>"PyPlot",
    :surf=>"PyPlot"}


function setplotter(key,val)    
    global plotter
    @assert val=="PyPlot" || val =="Gadfly" || val =="GLPlot"
    plotter[key]=val
end

function setplotter(str)
    if str=="PyPlot"
        setplotter(:contour,str)
        setplotter(:plot,str)
        setplotter(:surf,str)
    elseif str == "GLPlot"
        setplotter(:surf,str)        
    else
        setplotter(:contour,str)
        setplotter(:plot,str)
    end
end

if isdir(Pkg.dir("Gadfly"))
    include("Gadfly.jl")
    setplotter("Gadfly")
end
if isdir(Pkg.dir("GLPlot"))
    include("GLPlot.jl")
    setplotter("GLPlot")    
end
if isdir(Pkg.dir("PyPlot"))
    include("PyPlot.jl")
    setplotter("PyPlot")    
end


function plot(x,y::Vector;opts...)
    if plotter[:plot]=="Gadfly"
        gadflyplot(x,y;opts...)
    elseif plotter[:plot]=="PyPlot"
        pyplot(x,y;opts...)
    else
        error("Plotter " * plotter[:plot] * " not supported.")
    end
end

function contour(x,y::Vector,z::Array;opts...)
    if plotter[:contour]=="Gadfly"
        gadflycontour(x,y,z;opts...)
    elseif plotter[:contour]=="PyPlot"
        pycontour(x,y,z;opts...)
    else
        error("Plotter " * plotter[:contour] * " not supported.")
    end
end

function surf(x...;opts...)
    if plotter[:surf]=="GLPlot"
        glsurf(x...;opts...)
    elseif plotter[:surf]=="PyPlot"
        pysurf(x...;opts...)
    else
        error("Plotter " * plotter[:surf] * " not supported.")
    end
end



## Fun routines


function plot{S,T<:Real}(f::Fun{S,T};opts...)
    f=pad(f,3length(f)+50)
    plot(points(f),values(f);opts...)
end

function plot{S,T<:Complex}(f::Fun{S,T};opts...)
    f=pad(f,3length(f)+50)
    plot(points(f),values(f);opts...)
end


function plot{S}(r::Range,f::Fun{S,Float64};opts...)
    plot(r,f[[r]];opts...)
end

function complexplot{S}(f::Fun{S,Complex{Float64}};opts...) 
    f=pad(f,3length(f)+50)
    vals =values(f)

    plot(real(vals),imag(vals);opts...)
end


##FFun

# function plot(f::FFun;opts...) 
#     f=deepcopy(f)
#     
#     m=max(-firstindex(f.coefficients),lastindex(f.coefficients))
#     
#     f.coefficients=pad(f.coefficients,-m:m)
# 
#     pts = [points(f),fromcanonical(f,π)]
#     vals =[values(f),first(values(f))]
# 
#     plot(pts,vals;opts...)
# end
# 
# 
# function complexplot(f::FFun{Complex{Float64}};opts...) 
#     pts = [points(f),fromcanonical(f,π)]
#     vals =[values(f),first(values(f))]
# 
#     plot(real(vals),imag(vals);opts...)
# end


## SingFun

##TODO: reimplement
# function plot(f::SingFun;opts...) 
#     pf = pad(f,3length(f)+100)
#     
#     if f.α >= 0 && f.β >= 0
#         plot(points(pf),values(pf);opts...)
#     elseif f.α >= 0
#         plot(points(pf)[1:end-1],values(pf)[1:end-1];opts...)    
#     elseif f.β >= 0    
#         plot(points(pf)[2:end],values(pf)[2:end];opts...)    
#     else
#         plot(points(pf)[2:end-1],values(pf)[2:end-1];opts...)
#     end
# end



## Multivariate

function contour(f::MultivariateFun;opts...)
    f=chop(f,10e-10)
    #TODO: pad f
    contour(points(f,1),points(f,2),values(f);opts...)
end




## 3D plotting
# TODO: Use transform
function plot(xx::Range,yy::Range,f::MultivariateFun)
    vals      = evaluate(f,xx,yy)
    vals=[vals[:,1] vals vals[:,end]];
    vals=[vals[1,:]; vals; vals[end,:]]    
    surf(vals)    
end

function plot(xx::Range,yy::Range,f::MultivariateFun,obj,window)
    vals      = evaluate(f,xx,yy)
    vals=[vals[:,1] vals vals[:,end]];
    vals=[vals[1,:]; vals; vals[end,:]]    
    surf(vals,obj,window)    
end

function plot{S<:IntervalDomainSpace,V<:PeriodicDomainSpace}(f::AbstractProductFun{S,V})
    Px,Py=points(f)
    vals=values(f)
    surf([Px Px[:,1]], [Py Py[:,1]], [vals vals[:,1]])
end

plot(f::MultivariateFun)=surf(points(f,1),points(f,2),values(f))

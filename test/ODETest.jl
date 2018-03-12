using ApproxFun, Compat.Test
    import ApproxFun: Multiplication, testraggedbelowoperator, testbandedoperator, interlace

@testset "ODE" begin
    @testset "Airy" begin
        d=Interval(-10.,5.);
        S=Chebyshev(d)


        Bm=Evaluation(d,d.a);
        Bp=Evaluation(d,d.b);
        B=[Bm;Bp];
        D2=Derivative(d,2);
        X=Multiplication(Fun(x->x,d));

        testbandedoperator(D2-X)
        testraggedbelowoperator([B;D2-X])

        @time u=[B;D2-X]\[airyai(d.a),airyai(d.b),0.];
        @test Number.(Array(B*u)) ≈ [airyai(d.a),airyai(d.b)]

        @test ≈(u(0.),airyai(0.);atol=10ncoefficients(u)*eps())

        @time u=[Bm;D2-X;Bp]\[airyai(d.a),0.,airyai(d.b)];
        @test ≈(u(0.),airyai(0.);atol=10ncoefficients(u)*eps())

        @time u=[D2-X;Bm;Bp]\[0.,airyai(d.a),airyai(d.b)];
        @test ≈(u(0.),airyai(0.);atol=10ncoefficients(u)*eps())



        d=Interval(-1000.,5.);
        Bm=Evaluation(d,d.a);
        Bp=Evaluation(d,d.b);
        B=[Bm;Bp];
        D2=Derivative(d,2);
        X=Multiplication(Fun(x->x,d));

        u=[B;D2-X]\[airyai(d.a),airyai(d.b),0.];
        @test ≈(u(0.),airyai(0.);atol=10ncoefficients(u)*eps())



        B=Neumann(d);
        A=[B;D2-X];
        b=[[airyaiprime(d.a),airyaiprime(d.b)],0.];

        @time u=A\b;

        @test ≈(u(0.),airyai(0.);atol=10ncoefficients(u)*eps())

        ##) Neumann condition
    end


    f=Fun(x->x^2)
    D=Derivative(domain(f))
    @test norm(D*f-f')<100eps()


    ##Test versus exp

    f=Fun(x->-x^2)
    g=Fun(t->exp(-t^2))

    @test norm(Fun(t->exp(f(t)))-g)<= 100eps()

    fp=f';
    Bm=Evaluation(domain(f),domain(f).a);
    u=[Bm,Derivative(domain(f)) - fp]\[exp(f(domain(f).a)),0.];
    @test norm(u-g)<100eps()



    ## Oscillatory integral

    f=Fun(exp);
    D=Derivative(domain(f));
    w=10.;
    B=ApproxFun.SpaceOperator(BasisFunctional(floor(w)),Chebyshev(),ApproxFun.ConstantSpace(Float64));
    A=[B;D+1im*w*I];

    @time u = A\[0.,f];
    @test (u(1.)exp(1im*w)-u(-1.)exp(-1im*w)) ≈ (-0.18575766879136255 + 0.17863980562549928im)


    ## Bessel

    d=Interval()
    D=Derivative(d)
    x=Fun(identity,d)
    A=x^2*D^2+x*D+x^2
    testbandedoperator(x^2*D^2)
    testbandedoperator(ToeplitzOperator([0.5],[0.0,0.5]))
    testbandedoperator(HankelOperator(Float64[]))
    testbandedoperator(A)
    u=[ldirichlet(d);A]\[besselj(0,d.a),0.];



    @test u(0.1) ≈ besselj(0.,0.1)
    @test norm(A*u)<10eps()
    @test norm(Fun(A.ops[1]*u,d)-x.^2.*differentiate(u,2))<eps()
    @test norm(Fun(A.ops[2]*u,d)-x.*u') < eps()
    @test norm(Fun(A.ops[end]*u,d)-x.^2.*u) < eps()
    @test norm(x.^2.*u'' + x.*u' + x.^2.*u)<10eps()

<<<<<<< HEAD
d=ChebyshevInterval()
D=Derivative(d)
x=Fun(identity,d)
A=x^2*D^2+x*D+x^2
testbandedoperator(x^2*D^2)
testbandedoperator(ToeplitzOperator([0.5],[0.0,0.5]))
testbandedoperator(HankelOperator(Float64[]))
testbandedoperator(A)
u=[ldirichlet(d);A]\[besselj(0,d.a),0.];
=======
>>>>>>> abff326fa184c4021c60a8af5d7be726eccfbe54





    ## QR tests


    S=Chebyshev()
    B=Dirichlet(S)
    D=Derivative(S)

    Q,R=qr([B;D^2+I])
    @test Q[1,1] == -0.5773502691896257
    u=R\(Q'*[[cos(-1.0),cos(1.0)],0.0])


    @test u(0.) ≈ cos(0.0)


    S=Chebyshev()
    A=[Dirichlet(S);Derivative(S)^2 - I]
    QR=qrfact(A)
    @test (QR\[[1.,0],0])(0.0) ≈ 0.3240271368319427
    Q,R=qr(A)
    u=(R\(Q'*[[1.,0.0],0.0]))
    @test u(0.0)  ≈ 0.3240271368319427

    # check that matrix RHS works
    U = QR \ [[[1.,0.],0] [[0.,1.0],0.]]
    @test U[1,1] ≈ u

    x=Fun(S)
    A=[Dirichlet(S);Derivative(S)^2 - exp(im*x)]
    QR=qrfact(A)

    u=(QR\[[1.,0.0],0.0])
    @test u(0.0) ≈ (0.3329522068795961 + 0.024616008954634165im)

    # Union of intervals are constructed for now with \
    x=Fun(identity,Domain(-2..15) \ [-1,0])
    sp=space(x)


    B = [Dirichlet(sp);continuity(sp,0:1)]

<<<<<<< HEAD
# Union of intervals are constructed for now with \
x=Fun(identity,Domain(-2..15) \ Set([-1,0]))
sp=space(x)
=======
    # We don't want to concat piecewise space
    @test !(continuity(sp,0) isa ApproxFun.VectorInterlaceOperator)
    @test B isa ApproxFun.VectorInterlaceOperator
>>>>>>> abff326fa184c4021c60a8af5d7be726eccfbe54


    D=Derivative(sp)
    A=[B;D^2-x]

    ApproxFun.testraggedbelowoperator(A)
    QR=qrfact(A)

    @time u=QR\[[airyai(-2.),0.0],zeros(4),0.0]

    @test u(0.0) ≈ airyai(0.)


    ## Vector
    d=Interval()
    D=Derivative(d);
    B=ldirichlet();
    Bn=lneumann();

    f=Fun(x->[exp(x),cos(x)],d)

    A=[B 0;
       Bn 0;
       0 B;
       D^2-I 2.0I;
       0 D+I]

<<<<<<< HEAD
## Vector
d=ChebyshevInterval()
D=Derivative(d);
B=ldirichlet();
Bn=lneumann();
=======
    # makes sure ops are in right order
    @test A.ops[4,1] isa ApproxFun.PlusOperator
    QR=qrfact(A)
    v=Any[0.,0.,0.,f...]
    @test (QR\v)(0.0) ≈ [0.0826967758420519,0.5553968826533497]
>>>>>>> abff326fa184c4021c60a8af5d7be726eccfbe54


    Q,R=qr(A)
    v=Any[0.,0.,0.,f...]
    @test (QR\v)(0.0) ≈ [0.0826967758420519,0.5553968826533497]



    ## Auto-space


    t=Fun(identity,0..1000)
    L=𝒟^2+2I  # our differential operator, 𝒟 is equivalent to Derivative()

    u=[ivp();L]\[0.;0.;cos(100t)]
    @test ≈(u(1000.0),0.00018788162639452911;atol=1000eps())


    x=Fun(identity,1..2000)
    d=domain(x)
    B=Dirichlet()
    ν=100.
    L=(x^2*𝒟^2) + x*𝒟 + (x^2 - ν^2)   # our differential operator

    @time u=[B;L]\[[besselj(ν,first(d)),besselj(ν,last(d))],0.]


    @test ≈(u(1900.),besselj(ν,1900.);atol=1000eps())


    #) complex RHS for real operatorB=ldirichlet()
    D=Derivative(Chebyshev())
    B=ldirichlet()
    u1=[B;D]\[0.;Fun(exp)+0im]
    u2=[B;D]\[0.;Fun(exp)]
    @test u1(0.1) ≈ u2(0.1)
end

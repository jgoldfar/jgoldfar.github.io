---
title: "Interpolating Data in a Vector Space"
date: 2019-01-28T11:00:51
tags: ["Math", "Julia"]
draft: false
---


I'd like to show in this note that Julia's "official" interpolation package, [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl) can work natively with any type of object that allows some vector space operations over the field of real (or floating point) numbers.
That is, in order to interpolate between two values `y_1` and `y_2`, those values must have compatible, closed scalar multiplication and vector addition operations.

First, some preamble (to make sure we can load Interpolations in this workspace)

```julia
using Pkg
Pkg.activate(@__DIR__)
Pkg.add("Interpolations")
```

We'll define a type quite helpfully named `mayInterpolate`:

```julia
struct mayInterpolate{T<:Real}
    val::T
end
```

Though we "know" that this is a wrapper around some kind of real-number-like object, and hence can usually be interpreted as a member of a vector space, Julia knows nothing about this:


```julia
vTest = mayInterpolate(-1.0)
typeof(vTest) <: Real
```




    false



Nevertheless, by defining the appropriate methods to operate on `mayInterpolate` objects as though they were vectors, we can still use the interpolation routines defined by `Interpolations.jl`.
This follows naturally from Julia's multiple-dispatch strategy for choosing or compiling implementations of functions.

More involved and cleverly applied versions of this kind of trick enable trait-like systems to be implemented in Julia, and the integration of packages like [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl) and [Flux.jl](https://github.com/FluxML/Flux.jl) into [DiffEqFlux.jl](https://github.com/JuliaDiffEq/DiffEqFlux.jl).

```julia
import Base: *
function *(k::T, v::mayInterpolate) where {T<:Real}
    mayInterpolate(k*v.val)
end

import Base: +
function +(v1::mayInterpolate, v2::mayInterpolate)
    mayInterpolate(v1.val + v2.val)
end

# Interpolations.jl also assumes we can divide by scalars, and allows us to
# provide an "optimized" implementation if we please
import Base: /
function /(v::mayInterpolate, k::T) where {T<:Real}
    (1/k)*v
end
```

Let's create some data to interpolate:


```julia
xVals = range(0, stop=1, length=10)
yVals = [mayInterpolate(t+1) for t in xVals]
```

and create a linear interpolating function:

```julia
using Interpolations
yFn = LinearInterpolation(xVals, yVals)
```




    10-element extrapolate(scale(interpolate(::Array{mayInterpolate{Float64},1}, BSpline(Linear())), (0.0:0.1111111111111111:1.0,)), Throw()) with element type mayInterpolate{Float64}:
     mayInterpolate{Float64}(1.0)
     mayInterpolate{Float64}(1.1111111111111112)
     mayInterpolate{Float64}(1.2222222222222223)
     mayInterpolate{Float64}(1.3333333333333333)
     mayInterpolate{Float64}(1.4444444444444444)
     mayInterpolate{Float64}(1.5555555555555558)
     mayInterpolate{Float64}(1.6666666666666665)
     mayInterpolate{Float64}(1.7777777777777777)
     mayInterpolate{Float64}(1.8888888888888888)
     mayInterpolate{Float64}(2.0)



The weights are precomputed, so we would already know if we had failed here, but we can check that it works anyways:


```julia
for x in (0, 0.11, 1)
    @show yFn(x)
end
```

    yFn(x) = mayInterpolate{Float64}(1.0)
    yFn(x) = mayInterpolate{Float64}(1.11)
    yFn(x) = mayInterpolate{Float64}(2.0)

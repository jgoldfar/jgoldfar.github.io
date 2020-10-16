---
title: "Interpolating Data in a Vector Space"
date: 2019-01-28T11:00:51
tags: ["Math", "Julia"]
draft: false
---

In a vector space over a real field, given two points `y_1` and `y_2`, the process of finding an interpolating point actually requires relatively few arithmetic operations.
However, in a low-level language, you either have to worry about the representation of the vector in your usage of, for instance, an interpolation library, or write a bunch of custom code.

Julia is a high-level language that, among other things, uses a `multiple dispatch` paradigm - the types of all of the arguments are used to determine which implementation is used.
The type system in Julia is robust enough that you can encode many useful invariants in types, among other things.
But interpolation is one of those things you're always going to need to do.
This little demonstration of how Julia can easily work with custom objects in a fluent way may hopefully be useful for someone new to Julia.

I'd like to show in this note how nice some of Julia's "features" come together to allow the interpolation package [Interpolations](https://github.com/JuliaMath/Interpolations.jl) to work natively with any type of object that allows the vector space operations over the field of real (or floating point) numbers, just as one would expect mathematically.
That is, in order to interpolate between two values `y_1` and `y_2`, those values must only have compatible, closed scalar multiplication and vector addition operations.

The commands below should run in the Julia REPL; they were tested against a version of Julia pre-v1.0, but most everything here is still (roughly) true.

First, some preamble, in which we load the `Interpolations` package from the Julia package registry; this ensures that we can load `Interpolations` in this workspace.
Julia allows installing packages from a local registry, custom remote registries, and a central, Github-based repository.

```julia
using Pkg
Pkg.activate(@__DIR__)
Pkg.add("Interpolations")
```

We'll define a type quite helpfully named `mayInterpolate` that represents the minimal interface that `Interpolations` supports, and is (evidently) user-defined.
This type would perhaps more reasonably implemented as a [Trait](), but I wanted to keep this post to the point.

```julia
struct mayInterpolate{T<:Real}
    val::T
end
```

Though we "know" that this is a wrapper around some kind of vector-like object, and hence can usually be interpreted as a member of a vector space and hence gains all of the operations that space is equipped with, Julia knows nothing about this:


```julia
vTest = mayInterpolate(-1.0)
typeof(vTest) <: Real
```




    false



Nevertheless, by defining the appropriate methods to operate on `mayInterpolate` objects as though they were vectors, we can still use the interpolation routines defined by `Interpolations.jl`.
This follows naturally from Julia's multiple-dispatch strategy for choosing or compiling implementations of functions.



```julia
import Base: *
function *(k::T, v::mayInterpolate) where {T<:Real}
    mayInterpolate(k*v.val)
end

import Base: +
function +(v1::mayInterpolate, v2::mayInterpolate)
    mayInterpolate(v1.val + v2.val)
end
```

`Interpolations.jl` also assumes we can divide by scalars, and allows us to
provide an "optimized" implementation if we please. This one is simpler, though:
```
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


More involved and cleverly applied versions of this kind of trick enables trait-like systems to be implemented in Julia; this and architectural feats like the easy integration of large, special-purpose packages like [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl) and [Flux.jl](https://github.com/FluxML/Flux.jl) into [DiffEqFlux.jl](https://github.com/JuliaDiffEq/DiffEqFlux.jl) are enabled by leveraging the Julia type system and language.

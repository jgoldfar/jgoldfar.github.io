---
title: "Visualizing Attendance Data using Idiomatic Julia"
tags: ["OSS", "DataViz", "Julia-lang"]
date: 2018-11-04T12:30:00-04:00
draft: false
---

In [a previous post]({{< ref "/posts/vizualizing-attendance-data/index.md" >}}) I shared a quick-and-dirty code I wrote as part of a larger script that generates a bunch of reports.
This script dates back to when local environments/dependencies didn't have quite as nice a story as Julia v1.0 does, so I made sure to only use standard library packages.
But to make a fair comparison with the other codes in R and Python (in particular, to see how semantically clear one could make the code) one should use high-quality data analysis packages provided by the Julia ecosystem!

## Manage Packages (a One-Time Deal)

If you start julia from the command line using

```bash
julia --project="."
```

The package loading and management code will use a local environment, which will allow you to manage the explicit requirements for your script and track the versions and their dependencies like a `requirements.txt` file might.

The first time you run Julia in your project directory, you'll need to add the necessary packages:

```julia
using Pkg
for c in ["CSV", "DataFrames", "ImageMagick", "QuartzImageIO", "Makie"]
    Pkg.add(c)
end
```

This will build and install the dependencies for the script below, though you may need slightly different packages to support visualization on another platform (Makie will warn you if that's the case.)

After that, starting Julia with the above invocation, or, from any Julia session in your project directory, running

```julia
using Pkg
Pkg.activate(pwd())
Pkg.instantiate()
```

will bring those packages into your scripts's scope.
The latter is particularly useful when working with a `Project.toml` file in a Jupyter notebook.

## Loading the Data using CSV.jl and DataFrames.jl

First, we define the date format used in our data:

```julia
using Dates

const lineDateFormat = DateFormat("y-m-d H:M:S")
```

and then load the data; normalizing the names so they're Julia identifiers has no downside for us:

```julia
using CSV, DataFrames
swipeData = CSV.File("Swipes-Time-Only.csv", normalizenames = true, dateformat = lineDateFormat) |> DataFrame
```

We'll go ahead and add the hour the student came in as a new column:

```julia
swipeData.Hour_In = map(Dates.hour, swipeData.Time_In)
```

and aggregate it as we did before:

```julia
hourData = sort!(by(swipeData, :Hour_In, size), :Hour_In)
```

The rest of the vizualization can be completed [as in the previous post]({{< ref "/posts/vizualizing-attendance-data/index.md" >}}).

![Busy-Hours-Julia](/posts/vizualizing-attendance-data/Busy-Hours-Julia.png)

## Future Work

* We should be able to create the _exact_ same visualization as in our Python example by using `PyPlot.jl`, which would allow us to leverage our Julia processing codes while taking advantage of all of `matplotlib`'s niceties.
*Update*: The current viz steps use `PyPlot`.
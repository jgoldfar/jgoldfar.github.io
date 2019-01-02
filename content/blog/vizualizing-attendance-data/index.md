---
title: "Visualizing Attendance Data"
tags: ["OSS", "DataViz", "R-lang", "Julia-lang"]
date: 2018-11-03T14:57:00-04:00
draft: false
---

In this post I'm going to share some simple data munging and visualization techniques I use to analyze attendance data recorded from a card swipe machine in our tutoring lab, which I use to make sure we use our office hours (a human time resource!) as effectively as possible, and report that internally.
I've had this running on a regular basis since I was first asked to report this data some time back; in the past, Excel was used to prepare these charts, but it had to be done basically entirely "by hand" each time.
My implementation language of choice for the data processing codes (generating these graphs among many others) was Julia, but I've decided to go ahead and implement them in R and Python as an exercise.

## Data Format

The attendance data comes in CSV files following the data format

```
"FIT ID","TRACKS","First Name","Last Name","Email","Class","Context","Time In","Time Out","Total Time"
```

Assume this data is available in a file named `Swipes.csv`.
Due to how the app itself was implemented, there's quite a bit of noise in the data, but even so, clearly there's a lot that can be done with this information...
Today, I'm interested in reporting the busiest hours of the day in order to give a first approximation to the kind of schedule I should be deciding; the way this report has been generated in the past only included the time students arrived.
Though we could segment out the appropriate columns in nearly any language, I usually preprocess the data to a separate file, since I'll be running multiple analyses on the same collection of columns; <a name="awknote-source">`awk`</a><sup>[1](#awknote)</sup> supports this use-case with very little code:

```bash
awk 'BEGIN {FS=","} { print $8 ", " $9 }' Swipes.csv > Swipes-Time-Only.csv
```

We ensure that the field separator is a comma by setting `FS=","` in the `BEGIN` block, and then select only the 8th and 9th columns, which correspond to the time-in and time-out fields.

The file `Swipes-Time-Only.csv` will be used as input to the following codes.

## Julia Implementation

*Update* I've started updating this Q&D code with something much better, leveraging some of Julia's features; see [here for a better implementation]({{< ref "blog/vizualizing-attendance-data-julia-idiomatic.md" >}}).

We'll start by reading in the CSV-formatted data:

```julia
using DelimitedFiles
swipeData = readdlm("Swipes-Time-Only.csv", ',')
```

Awk leaves some cruft that the Julia CSV parser doesn't remove, so we'll remove that.
We'll go ahead and set the out time to the in time if it's missing at this step as well.

```julia
nr, nc = size(swipeData)
for i in 1:nr
    swipeData[i, 2] = strip(swipeData[i, 2], [' ', '"'])
    if isempty(swipeData[i, 2])
        swipeData[i, 2] = swipeData[i, 1]
    end
end
```

Julia provides a parser that will converts strings to native Date objects, which we can use to make the rest of the processing easier:

```julia
using Dates

const lineDateFormat = DateFormat("y-m-d H:M:S")

swipeInDates = [
    DateTime(swipeData[i, 1], lineDateFormat) for i in 2:nr
]
```

We'll divide the the day into 1 hour bins, and count all entries in a particular hour.
This requires a bit of care in case our data has any spurious or non-date entries:

```julia
hourBins = zeros(Int, 23)
hours = 1:23
for dateIndex in 2:nr
    try
      inDate = DateTime(strip(swipeData[dateIndex, 1], ['\"', ' ']), lineDateFormat)
      hourBins[hour(inDate)] += 1
    catch e
      @warn "Failed to parse $(swipeData[dateIndex, 1]) as a DateTime"
    end
end
```

[PyPlot](https://github.com/JuliaPy/PyPlot.jl) provides a Julia interface to [matplotlib.pyplot](https://matplotlib.org/api/_as_gen/matplotlib.pyplot.html); nearly the whole API translates over without modification.
I found it easiest to use my system Conda installation rather than use the PyPlot.jl managed one, which requires calling Julia with something like
```shell
PYTHON="`which python`" julia --project=. ...
```

In order to ensure things work across platforms in a consistent way, we'll set an explicit matplotlib backend.

```julia
using PyCall
pygui(:tk)
import PyPlot
const plt = PyPlot
```

We'll initialize a `Figure` object so we can adjust the size of the plot, as well as an Axes object, so we can set the axis labels.

```julia
const fig = plt.figure(figsize=(6.4, 6.4))

nonzeroHours = hours[hourBins .> 0]
minHour, maxHour = extrema(nonzeroHours)
hourDiff = maxHour - minHour

const caxes = plt.axes(
    xlabel="Hour",
    ylabel="Number of Visitors"
)
```

Then we simply create the plot and save it:

```julia
plt.bar(nonzeroHours, hourBins[hourBins .> 0], axes = caxes)

plt.savefig("Busy-Hours-Julia.png", quality=100, dpi=300)
```

which is reproduced below:

![Busy-Hours-Julia](/blog/vizualizing-attendance-data-images/Busy-Hours-Julia.png)

## R Implementation

Since R (and the tidyverse) have been around for so long, there are excellent tools that do most of the work I did "manually" above behind the scenes, so this implementation is quite a bit shorter.
This is more an indictment of my inexperience with the Julia data munging toolset than any actual issue, since I am admittedly more fluent with the linear algebra & ML subsets of Julia than the data analysis/viz subsets.
Anyways, we start by reading in the same CSV file:

```R
df <- read.csv("Swipes-Time-Only.csv", header=TRUE)
```

Load [`dplyr`](https://dplyr.tidyverse.org/) for general data manipulation and [`lubridate`](https://lubridate.tidyverse.org/) for some convenience functions related to datetime objects:

```R
library(lubridate)
library(dplyr)
```

Save the hour component of the time the student came in as a new column for possible future processing purposes:

```R
df$TimeInHour <- df$Time.In %>% ymd_hms %>% hour
```

and store the users entering in each hour to a new variable:

```R
UsersInEachHour <- df %>% count(TimeInHour)
```

Now, we'll load the venerable `ggplot2` graphing library and generate a nice looking output plot.
The x- and y-labels will be customized (the third line below) and we'll add the actual value as a label to each bar (the fourth line below) for good measure:

```R
library(ggplot2)
p<-ggplot(data=UsersInEachHour, aes(x=TimeInHour, y=n)) +
  geom_bar(stat="identity", fill="black")+
  xlab("Hour of Day") + ylab("Number of Visitors")+
  geom_text(aes(label=n), vjust=1.6, color="white", size=3.5)+
  theme_minimal()
```

This graphic can be exported using `ggsave` (I've modified the dimensions to match the plot above):

```R
ggsave("Busy-Hours-R.png", p, width=5.56, height=5.35, units="in", dpi="screen")
```

By way of comparison with the above output, the corresponding graphic is reproduced below:

![Busy-Hours-R](/blog/vizualizing-attendance-data-images/Busy-Hours-R.png)

## Python Implementation

Below I'll share a Python 3 implementation, though the relatively simple nature of this particular processing task implies the code would probably be portable to Python 2 with minimal changes.

We'll do the data analysis in [`pandas`](https://pandas.pydata.org/) and [`matplotlib`](https://matplotlib.org/) for visualization.

First, we'll load the data:

```python
import pandas
df = pandas.read_csv('Swipes-Time-Only.csv', sep=',', parse_dates=[0, 1])
```

The equivalent code to the R process above for saving the hour component of the time the student came in as a new column is

```python
df['TimeInHour'] = [v.hour for v in df["Time In"]]
```

Similarly, calculating thie histogram information for user entry times is simply

```python
NumberOfVisitors = df.groupby('TimeInHour').count()
```

This actually produces a dataframe with two, identical columns (since the original data had two columns), but we'll select out only one for our plot.

For the plotting step, let's load `matplotlib`:

```python
import matplotlib.pyplot as plt
```

and then generate the figure using the `index` and one column of the `values` of the dataframe we generated above:

```python
fig = plt.figure(figsize=(5.56, 5.35))
p = plt.bar(NumberOfVisitors.index, NumberOfVisitors.values[:, 1])
plt.ylabel('Number of Visitors')
plt.xlabel('Hour of Day')
plt.show()
```

This plot can be exported to an image file like we did with the other examples:

```python
fig.savefig('Busy-Hours-Python.png', dpi=72)
```

which is included below:

![Busy-Hours-Python](/blog/vizualizing-attendance-data-images/Busy-Hours-Python.png)

## Future Work

* I've run some other, rather more complicated processes on the data we collect on attendance in MAC that would be interesting to share some time.

* While we usually report this information internally, it might be good to produce charts like this on a regular basis and post them online, so I'll look at creating a regularly released "product" and work it into some kind of regular post.

* The bar chart we created here is a bit misleading, since it only reports the time the student comes in to the center, but students may stay for any amount of time.
More careful histogram creation, perhaps presented as a heatmap in continuous time, would make more sense.

* Experiment with isolating the dependencies using a [`conda`](https://docs.anaconda.com/anaconda/user-guide/tasks/use-r-language) or [`packrat`](http://rstudio.github.io/packrat/walkthrough.html) and `pipenv` environments.

* My code, particularly in Julia, is not particularly idiomatic (in particular, I don't use DataFrames, which are essential for larger tabular data.)
It would be good all around to update that code.

## Footnotes

<a name="awknote" href="#awknote-source">[1]</a> [GNU Awk](https://github.com/onetrueawk/awk) is one of the more interesting software tools, dating back to 1977.
The [AWK Programming Language](https://web.archive.org/web/20080410180555/http://www-db-out.research.bell-labs.com/cm/cs/awkbook) book (which I have read, but unfortunately do not own) is one of the clearest expositions on the development and uses of a programming language one can read.

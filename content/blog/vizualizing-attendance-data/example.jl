using Pkg
pkg"up; add AbstractPlotting#master GLMakie#master Makie#master"

using DelimitedFiles
swipeData = readdlm("Swipes-Time-Only.csv", ',', String) # Datafile name, delimiter, cell type
nr, nc = size(swipeData)

using Dates

const lineDateFormat = dateformat"Y-m-d H:M:S"

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

using Makie

scene = Scene(resolution = (500, 500))

nonzeroHours = hours[hourBins .> 0]
minHour = minimum(nonzeroHours)
hourDiff = maximum(nonzeroHours) - minHour
barplot!(scene, nonzeroHours, hourBins[hourBins .> 0], limits = FRect(minHour - 0.5, 0, hourDiff + 0.5, maximum(hourBins) + 10))

axis = scene[Axis]
axis[:names, :axisnames] = ("Hour", "Number of Visitors")

Makie.save("Busy-Hours-Julia.png", scene)

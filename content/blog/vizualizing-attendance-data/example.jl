using DelimitedFiles
const swipeData = readdlm("Swipes-Time-Only.csv", ',', String) # Datafile name, delimiter, cell type
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

using PyCall
pygui(:tk)
import PyPlot
const plt = PyPlot

const fig = plt.figure(figsize=(6.4, 6.4))

nonzeroHours = hours[hourBins .> 0]
minHour, maxHour = extrema(nonzeroHours)
hourDiff = maxHour - minHour

const caxes = plt.axes(
#    (minHour - 0.5, 0, hourDiff + 0.5, maxHour + 10),
    xlabel="Hour",
    ylabel="Number of Visitors"
)

plt.bar(nonzeroHours, hourBins[hourBins .> 0], axes = caxes)

plt.savefig("Busy-Hours-Julia.png", quality=100, dpi=300)

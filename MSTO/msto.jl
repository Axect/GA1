using Gadfly, DataFrames

# ==============================================================================
# Function
# ==============================================================================

function FindMSTO(A::DataFrame)::Tuple{Float64, Float64}
    X = A[:Mv]
    Y = A[:BV]
    # Find key
    key = 0
    val = minimum(Y)
    for (i, elem) in enumerate(Y)
        if elem == val
            key = i
            break;
        end
    end
    return Y[key], X[key]
end

# ==============================================================================
# Find MSTO
# ==============================================================================

dir = "data/"

MSTO = Array{Float64}(10,2)

for (i,subdir) in enumerate(readdir("data/"))
    Data = readcsv(dir*subdir)
    df = DataFrame(BV=Data[:,1], Mv=Data[:,2]);
    MSTO[i,1], MSTO[i,2] = FindMSTO(df)
end

# ==============================================================================
# Find Ratio
# ==============================================================================

println(MSTO)

Distance = Array{Float64}(9,3)
Ratio = Array{Float64}(8,3)

for i = 1:length(Distance[:,1])
    # Total
    Distance[i,1] = sqrt((MSTO[i+1,1] - MSTO[i,1])^2 + (MSTO[i+1,2]-MSTO[i,2])^2);
    # X
    Distance[i,2] = MSTO[i+1,1] - MSTO[i,1]
    #  = DataFrame(BV=MSTO[:,1], Mv=MSTO[:,2], index=["8gyr", "9gyr", "10gyr", "11gyr", "12gyr", "13gyr", "14gyr", "15gyr", "16gyr", "17gyr"])

# pl = plot(DF, x=:BV, y=:Mv, color=:index, Geom.point, Coord.Cartesian(yflip=true))
# draw(SVG("Fig/msto.svg", 1000px, 800px), pl)Y
    Distance[i,3] = MSTO[i+1,2] - MSTO[i,2]
end

for i = 1:length(Ratio[:,1])
    Ratio[i,1] = Distance[i+1,1]/Distance[i,1]
    Ratio[i,2] = Distance[i+1,2]/Distance[i,2]
    Ratio[i,3] = Distance[i+1,3]/Distance[i,3]
end

# Ratio ~= 0.9
println(Distance[1,3])
MSTO14 = MSTO[6,2] + Distance[5,3]*0.9
println("MSTO14: ", MSTO14)
println("MSTO15: 4.222")
MSTO16 = MSTO[8,2] + (MSTO[8,2] - 4.148)*0.9
println("MSTO16: ", MSTO16)

println()
println("M3: 4.053")
println("M13: 4.2595")
println()

# MSTO10 = 3.774
# MSTO11 = 3.882
# MSTO12 = 3.979
# MSTO13 = 4.068
# MSTO14 = 4.148 ~= 4.15
# MSTO15 = 4.222 ~= 4.22
# MSTO16 = 4.289 ~= 4.29
# M13fidu = 4.2595 ~=4.26

# ==============================================================================
# Show Ratio
# ==============================================================================
# println("Total Ratio")
# println(Ratio[:,1])
# println()
# println("X Ratio")
# println(Ratio[:,2])
# println()
# println("Y Ratio")
# println(Ratio[:,3])

# ==============================================================================
# Plot
# ==============================================================================

# DF = DataFrame(BV=MSTO[:,1], Mv=MSTO[:,2], index=["8gyr", "9gyr", "10gyr", "11gyr", "12gyr", "13gyr", "14gyr", "15gyr", "16gyr", "17gyr"])

# pl = plot(DF, x=:BV, y=:Mv, color=:index, Geom.point, Coord.Cartesian(yflip=true))
# draw(SVG("Fig/msto.svg", 1000px, 800px), pl)
# run(`inkscape -z msto.svg -e msto.png -d 300 --export-background=WHITE`)

# ==============================================================================
# IsoChrone
# ==============================================================================
Iso = Array{Float64}(2800, 2)

for (i,subdir) in enumerate(readdir("data/"))
    Data = readcsv(dir*subdir)
    start = 280*(i-1) + 1
    finish = 280*i
    for j = start : finish
        Iso[j,1] = Data[j-start+1,1]
        Iso[j,2] = Data[j-start+1,2]
    end
end

M13 = readcsv("../M13fidu.CSV")
BV13 = M13[:,2]
Mv13 = M13[:,1]

M3 = readcsv("../M3fidu.CSV")
BV3 = M3[:,2]
Mv3 = M3[:,1]


DDF = DataFrame(BV=Iso[:,1], Mv=Iso[:,2], index=repeat(["8gyr", "9gyr", "10gyr", "11gyr", "12gyr", "13gyr", "14gyr", "15gyr", "16gyr", "17gyr"], inner=[280]))
DDG = DataFrame(BV=vcat(BV3, BV13), Mv=vcat(Mv3, Mv13), index=vcat(repeat(["M3"], inner=[33]), repeat(["M13"], inner=[30])))

# pl2 = plot(
#     layer(DDF, x=:BV, y=:Mv, color=:index, Geom.line(preserve_order=true)),
#     layer(DDG, x=:BV, y=:Mv, color=:index, size=1:100, Geom.point),
#     Coord.Cartesian(xmin=0.32, xmax=0.5, ymin=5.8, ymax=2.5))
# draw(SVG("Fig/iso2.svg", 1000px, 1000px),pl2)
#run(`inkscape -z iso2.svg -e iso2.png -d 300 --export-background=WHITE`)
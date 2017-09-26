using DataFrames, Gadfly, Dierckx

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

# Isochrone

for (i,subdir) in enumerate(readdir("data/"))
    Data = readcsv(dir*subdir)
    df = DataFrame(BV=Data[:,1], Mv=Data[:,2]);
    MSTO[i,1], MSTO[i,2] = FindMSTO(df)
end

# ==============================================================================
# Total Data
# ==============================================================================

# Isochrone

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

# Fidu

M13 = readcsv("../M13fidu.CSV")
BV13 = M13[:,2]
Mv13 = M13[:,1]

M3 = readcsv("../M3fidu.CSV")
BV3 = M3[:,2]
Mv3 = M3[:,1]

# ==============================================================================
# Find 0.05
# ==============================================================================

# MSTO Data

MSTO_M3_BV = 0.412977
MSTO_M3_Mv = 4.053
MSTO_M13_BV = 0.430579
MSTO_M13_Mv = 4.2595

# + 0.05

MSTOp_M3_BV = MSTO_M3_BV + 0.05
MSTOp_M13_BV = MSTO_M13_BV + 0.05

MSTOp = Array{Float64}(10,2)

for i = 1:length(MSTO[:,1])
    MSTOp[i,1] = MSTO[i,1] + 0.05
end

# ==============================================================================
# Cubic Spline
# ==============================================================================

# 1. Minimum BV

min3, key3 = findmin(BV3)
min13, key13 = findmin(BV13)

# 2. Data Cutting

M3s = M3[key3:end, :]
M13s = M13[key13:end, :]

# 3. Cubic Spline

spl3 = Spline1D(M3s[:,2], M3s[:,1])
MSTOp_M3_Mv = spl3(MSTOp_M3_BV)

spl13 = Spline1D(M13s[2:end,2], M13s[2:end,1])
MSTOp_M13_Mv = spl13(MSTOp_M13_BV)

# ==============================================================================
# ISO : Error ~ 0.01
# ==============================================================================

MSTOp_ISO_Mv = Array{Float64}(10)

for i = 1:10
    start = 280*(i-1) + 1
    finish = 280*i
    for j = start : finish
        if abs(Iso[j,1] - MSTOp[i]) < 0.01
            MSTOp_ISO_Mv[i] = Iso[j,2]
            t = i + 7
            println("Find Iso$(t) Mv!")
            break;
        end
    end
end

# ==============================================================================
# Table
# ==============================================================================

# M3, M13
M3Data = [MSTO_M3_BV MSTO_M3_Mv; MSTOp_M3_BV MSTOp_M3_Mv]
writecsv("M3.csv", M3Data)
M13Data = [MSTO_M13_BV MSTO_M13_Mv; MSTOp_M13_BV MSTOp_M13_Mv]
writecsv("M13.csv", M13Data)

# Isochrone
IsoData = MSTO
writecsv("Iso.csv", IsoData)

IsoDatap = hcat(MSTOp, MSTOp_ISO_Mv)
writecsv("Isop.csv", IsoDatap)

# ==============================================================================
# Normalization
# ==============================================================================

# 1. M3, M13

# 1-1. Normalize
BV3temp = BV3 .- MSTO_M3_BV
Mv3temp = Mv3 .- MSTOp_M3_Mv

BV13temp = BV13 .- MSTO_M13_BV
Mv13temp = Mv13 .- MSTOp_M13_Mv

# 1-2. DataFrame
DM3 = DataFrame(BV=BV3temp, Mv=Mv3temp, index=repeat(["M3"], inner=[length(BV3temp)]))
DM13 = DataFrame(BV=BV13temp, Mv=Mv13temp, index=repeat(["M13"], inner=[length(BV13temp)]))

# 2. IsoChrone

ISOR = Array{Float64}(2800,2)
# 2-1. Normalize
for i = 1:10
    start = 280*(i-1) + 1
    finish = 280*i
    for j = start : finish
        BVtemp = Iso[start:finish, 1] .- MSTO[i,1]
        Mvtemp = Iso[start:finish, 2] .- MSTOp_ISO_Mv[i]
        ISOR[j,1] = BVtemp[j-start+1]
        ISOR[j,2] = Mvtemp[j-start+1]
    end
end

# 2-2. DataFrame
DISO = DataFrame(BV=ISOR[:,1], Mv=ISOR[:,2], index=repeat(["8gyr", "9gyr", "10gyr", "11gyr", "12gyr", "13gyr", "14gyr", "15gyr", "16gyr", "17gyr"], inner=[280]))

# ==============================================================================
# Plot
# ==============================================================================

pl = plot(
    layer(DISO, x=:BV, y=:Mv, color=:index, Geom.line(preserve_order=true)),
    layer(DM3, x=:BV, y=:Mv, color=:index, size=1:100, Geom.point),
    layer(DM13, x=:BV, y=:Mv, color=:index, size=1:100, Geom.point),
    Guide.title("Relative age"), Guide.XLabel("B-V"), Guide.YLabel("Mv"), Coord.Cartesian(xmin=0, xmax=0.5, ymin=0, ymax=-5)
)

draw(SVG("rel2.svg", 1000px, 800px), pl)

run(`inkscape -z rel2.svg -e rel2.png -d 300 --export-background=WHITE`)

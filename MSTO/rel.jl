using DataFrames, Gadfly

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

MSTO_M3_BV = 0.412977
MSTO_M3_Mv = 4.053
MSTO_M13_BV = 0.430579
MSTO_M3_Mv = 4.2595

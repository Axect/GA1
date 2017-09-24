using DataFrames, CurveFit, Gadfly

Data = readcsv("M13fidu.CSV");

Mv = Data[:,1];
red = Data[:,2];

val = minimum(red);

key = 0;

for (i,elem) in enumerate(red)
    if elem == val
        key = i
        break
    end
end

X = Mv[key-2:1:key+2]
Y = red[key-2:1:key+2]

m = Mv[key-2];
M = Mv[key+2];

P = collect(m:0.01:M);

fit = curve_fit(Poly, X, Y, 4)

println(fit)

Q = fit(P);

df = DataFrame(Mv=P, poly=Q, index=repeat(["Polyfit"], inner=[length(P)]));
dg = DataFrame(Mv=X, BV=Y, index=repeat(["Original"], inner=[length(X)]));

pl = plot(
    layer(dg, x=:Mv, y=:BV, color=:index, Geom.point),
    layer(df, x=:Mv, y=:poly, color=:index, Geom.line),
    Guide.title("Interpolation"), Guide.YLabel("B-V")
)

draw(SVG("Interpolation.svg", 1000px, 800px), pl);

run(`inkscape -z Interpolation.svg -e Interpolation.png -d 300 --export-background=WHITE`)

# Global Minimum : Mv = 4.2595
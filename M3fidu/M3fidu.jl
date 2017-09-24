using Gadfly, DataFrames

Data = readcsv("M3fidu.CSV")

x1 = Data[:, 1];
x2 = x1 .- 0.1;

x1 = sort(x1, rev=true);
x2 = sort(x2, rev=true);

y = Data[:,2]

df = DataFrame(Mv=x1, mag=x2, red=y);

pl = plot(df, x=:red, y=:Mv, Geom.point, Guide.title("M3fidu"), Guide.XLabel("B-V"));

draw(SVG("M3fidu.svg", 1000px, 800px), pl);


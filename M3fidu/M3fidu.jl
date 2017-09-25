using Gadfly, DataFrames

Data = readcsv("../M3fidu.CSV")

x1 = Data[:, 1];
x2 = x1 .- 0.1;

y = Data[:,2]

df = DataFrame(Mv=x1, mag=x2, red=y);

pl = plot(df, x=:red, y=:Mv, Geom.point, Guide.title("M3fidu"), Guide.XLabel("B-V"), Coord.Cartesian(yflip=true));

draw(SVG("M3fidu.svg", 1000px, 800px), pl);

run(`inkscape -z M3fidu.svg -e M3fidu.png -d 300 --export-background=WHITE`)

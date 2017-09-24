using Gadfly, DataFrames

Data = readcsv("M13fidu.CSV")

x1 = Data[:,1];
x2 = x1 .- 0.1;

x1 = sort(x1, rev=true);
x2 = sort(x2, rev=true);

y = Data[:,2];

df = DataFrame(Mv=x1, mag=x2, red=y);

pl = plot(df, x=:red, y=:Mv, Geom.point, Guide.title("M13fidu"), Guide.XLabel("B-V"));

draw(SVG("M13fidu.svg",1000px, 800px), pl);

run(`inkscape -z M13fidu.svg -e M13fidu.png -d 300 --export-background=WHITE`)
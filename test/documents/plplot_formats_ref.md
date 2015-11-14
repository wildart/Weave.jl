




````julia
using PLplot
x = linspace(0, 2π, 200)
plot(x, sin(x), typ=:line)
````


![sin(x) function.](figures/plplot_formats_sin_fun_1.png)



![cos(x) function.](figures/plplot_formats_2_1.png)



![](figures/plplot_formats_cos2_fun_1.png)



````julia
julia> x = linspace(0, 2π, 200)
linspace(0.0,6.283185307179586,200)

julia> plot(x, sin(x))

julia> y = 20
20

julia> plot(x, cos(x))

````


![](figures/plplot_formats_4_1.png)
![](figures/plplot_formats_4_2.png)



````julia
julia> x = linspace(0, 2π, 200)
linspace(0.0,6.283185307179586,200)

julia> plot(x, cos(x))

julia> plot(x, sin(x))

````


![](figures/plplot_formats_5_1.png)
![](figures/plplot_formats_5_2.png)



````julia
plot(x, sin(x))
lines(x, cos(x))
````


![](figures/plplot_formats_6_1.png)

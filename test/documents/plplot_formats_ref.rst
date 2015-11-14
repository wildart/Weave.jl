




.. code-block:: julia
    
    using PLplot
    x = linspace(0, 2π, 200)
    plot(x, sin(x), typ=:line)



.. figure:: figures/plplot_formats_sin_fun_1.png
   :width: 15 cm

   sin(x) function.




.. figure:: figures/plplot_formats_2_1.png
   :width: 15 cm

   cos(x) function.




.. image:: figures/plplot_formats_cos2_fun_1.png
   :width: 15 cm




.. code-block:: julia
    
    julia> x = linspace(0, 2π, 200)
    linspace(0.0,6.283185307179586,200)
    
    julia> plot(x, sin(x))
    
    julia> y = 20
    20
    
    julia> plot(x, cos(x))




.. image:: figures/plplot_formats_4_1.png
   :width: 15 cm

.. image:: figures/plplot_formats_4_2.png
   :width: 15 cm




.. code-block:: julia
    
    julia> x = linspace(0, 2π, 200)
    linspace(0.0,6.283185307179586,200)
    
    julia> plot(x, cos(x))
    
    julia> plot(x, sin(x))




.. image:: figures/plplot_formats_5_1.png
   :width: 15 cm

.. image:: figures/plplot_formats_5_2.png
   :width: 15 cm




.. code-block:: julia
    
    plot(x, sin(x))
    lines(x, cos(x))



.. image:: figures/plplot_formats_6_1.png
   :width: 15cm


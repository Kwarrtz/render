# Graphics.Render

Graphics.Render is a lightweight graphics library for Elm. It is intended primarily to 
replace the hole left by the deprecation of Graphics.Collage. The API of Graphics.Render 
is similar to that of Graphics.Collage, so it should feel familiar, to those who have 
used Graphics.Collage before. However, there are a few major changes to be aware of between 
this library and Graphics.Collage. Most notably, the origin of the coordinate system of the 
render library is positioned at the center of the viewbox,r ather than the top left corner, 
and render compiles to SVG rather the HTML5 canvas. For more in depth documentation, take a 
look at the package on the [Elm repository][package.elm-lang.org/packages/Kwarrtz/render].

## Examples

The following Elm code draws a blue ellipse with a black border.

    import Graphics.Render as Render
    import Color exposing (rgb)
    
    main = Render.ellipse 150 150
        |> Render.solidFillWithBorder (rgb 0 0 255) 5 (rgb 0 0 0) 
        |> Render.svg 500 500
        
## TODO

* Gradient fills
* SVG paths
* HTML5 canvas support
* Add examples

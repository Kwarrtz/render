# Graphics.Render

Graphics.Render is a lightweight graphics library for Elm. It is intended primarily to
replace the hole left by the deprecation of Graphics.Collage. The API of Graphics.Render
is similar to that of the older library, so it should feel familiar, to those who have
used it before. However, there are a few major changes to be aware of between this library
and Graphics.Collage. Most notably that it currently compiles to SVG rather the HTML5 canvas
(although support for this latter option is planned). For more in depth documentation, take a
look at the documentation for the [Graphics.Render module](http://package.elm-lang.org/packages/Kwarrtz/render/latest/Graphics-Render).

My life has suddenly become much busier than it was when I started this project, so I doubt I will be
able to devote much time to it in the coming months. Still, if you notice any outstanding issues
feel free to open an issue, and I will try to get to it when I can.

NOTE THAT THIS LIBRARY IS STILL VERY EXPERIMENTAL, AND ITS API IS SUBJECT TO CHANGE.

## Notes for v2.x.x

As of version 2.0.0, positions are now from the top left hand corner of the viewport rather than the center. There are several other major changes to the API from version 1.x.x. For more details, take a look at [the
documentation](http://package.elm-lang.org/packages/Kwarrtz/render/latest/Graphics-Render).

## Examples

The following Elm code draws a blue ellipse with a black border at position (100,100) in a
500x500 SVG viewport.

    import Graphics.Render exposing (ellipse, filledAndBordered, position, svg)
    import Color exposing (rgb)

    main = ellipse 150 150
        |> filledAndBordered (solid <| rgb 0 0 255)
                           5 (solid <| rgb 0 0 0)
        |> position (100,100)
        |> svg 500 500

## TODO

* Gradient fills
* Paths and arcs
* HTML5 canvas support
* Add examples
* Improve documentation

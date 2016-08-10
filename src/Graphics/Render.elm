module Graphics.Render exposing
    ( Form
    , Shape, ShapeStyle
    , FillStyle
    , Line, LineStyle
    , LineCap(..)
    , LineJoin(..)
    , TextStyle
    , Point
    , svg
    , html, group
    , shape
    , polygon, rectangle
    , ellipse, circle
    , solidFill, solidFillWithBorder
    , textureFill, textureFillWithBorder
    , line
    , polyline, segment
    , solid, dotted, dashed
    , text
    , plain, bold, italic, underlined
    , image
    , position, angle, size, opacity
    , move, rotate, scale
    )

{-| This library provides a toolkit for rendering and manipulating 
graphics primitives such as lines, polygons, text, images, etc.
It is intended primarily for projects that are too complex for 
the manual manipulation of  an SVG or HTML5 canvas element, but too
simple for a fully blown graphics engine such as WebGL (a motivating
example would be a simple 2D game).

In theory, the structure of this library allows for multiple easily
interchangable backend rendering targets (i.e. SVG, HTML5 canvas), but
the only backend supported at present is SVG.

# Forms
@docs Form, Point

# Shapes
@docs Shape, polygon, rectangle, ellipse, circle

# Lines
@docs Line, polyline, segment

# Images
@docs image

# Rendering
@docs svg

# Grouping
@docs group

# Turning Things into Forms

## Shapes
@docs solidFill, solidFillWithBorder, textureFill, textureFillWithBorder

## Lines
@docs solid, dashed, dotted

## Text
@docs plain, bold, italic, underlined

## HTML
@docs html

# Modifying Forms
@docs position, angle, size, opacity, move, rotate, scale

# Custom Styling

## Shapes
@docs shape, ShapeStyle, FillStyle

## Lines
@docs line, LineStyle, LineCap, LineJoin

## Text
@docs text, TextStyle
-}

import Svg exposing (Svg, Attribute)
import Svg.Attributes as Svg
import Html exposing (Html)

import Color exposing (Color, Gradient)
import List
import String
import Bitwise
import Char


{-| Anything that can be rendered on the screen. A `Form` could be a 
red circle, a line of text, or an arbitrary HTML element.

    redCircle : Form
    redCircle = circle 10 |> solidFill (rgb 255 0 0) |> position (-20,0)

    blueCircle : Form
    blueCircle = circle 10 |> solidFill (rgb 0 0 255)

    circles : Form
    circles = group [redCircle, blueCircle]
-}
type alias Form a =
    { x : Float
    , y : Float
    , theta : Float
    , scale : Float
    , alpha : Float
    , form : BasicForm a
    }


type BasicForm msg
    = FLine Line LineStyle
    | FShape Shape ShapeStyle
    | FText String TextStyle
    | FImage String Float Float
    | FGroup (List (Form msg))
    | FElem (Html msg)


{-| A segment of a line or curve. Only describes the shape of the line.
Position, color, width, etc. are all specified later.
-}
type Line
    = Polyline (List Point)


{-| A polygon or an ellipse. Only describes the size and shape of the figure.
Position, color, width, etc. are all specified later.
-}
type Shape
    = Polygon (List Point)
    | Ellipse Float Float


{-| Speficies the styling (color, width, dashing, etc.) of a line.

    -- defines a red, dashed line with a width of 5px
    { color = rgb 255 20 20
    , width = 5
    , cap = Flat
    , join = Sharp
    , dashing = [8,4]
    , dashOffset = 0
    }
-}
type alias LineStyle =
    { color : Color
    , width : Float
    , cap : LineCap
    , join : LineJoin
    , dashing : List Int
    , dashOffset : Int
    }


{-| Specifies the styling (color, border, etc.) of a shape.
-}
type alias ShapeStyle =
    { fill : FillStyle
    , border : LineStyle
    }


{-| Specifies the styling (color, font, weight, etc.) of text
-}
type alias TextStyle =
    { color : Color
    , fontSize : Int
    , fontFamily : String
    , italic : Bool
    , bold : Bool
    , underlined : Bool
    }


{-| Describes the cap style of a line. `Flat` capped lines have
no endings, `Square` capped lines have flat endings that extend
slightly past the end of the line, and `Round` capped lines have
hemispherical endings.
-}
type LineCap = Round | Square | Flat


{-| Describes the join style of a line. 
-}
type LineJoin = Smooth | Sharp | Bevel


{-| Describes the fill texture of a shape. It can be a solid color,
gradient, or tiled texture.
-}
type FillStyle
    = Solid Color
    | Texture String Float Float Float

{-| A 2-tuple of `Float`s representing a 2D point.
-}
type alias Point = (Float, Float)

    
form : BasicForm msg -> Form msg
form bForm =
    { x = 0
    , y = 0
    , theta = 0
    , scale = 1
    , alpha = 1.0
    , form = bForm
    }


{-| Creates a `Form` from an arbitrary `Html` element. The
resulting form is subject to all of the regular manipulations.
Note that if you are compiling to SVG, then this functionality
is not supported in Internet Explorer.
-}
html : Html msg -> Form msg
html elem = form <| FElem elem


{-| Takes a list of `Form`s and combines them into a single
`Form`.
-}
group : List (Form msg) -> Form msg
group forms = form <| FGroup forms







              




------------------------ SHAPES ------------------------


{-| The `*Fill` and `*FillWithBorder` functions
allow you to add styling to your shapes and conver them
into forms, but sometimes those functions don't offer 
enough flexibility. What if you want a dashed border
instead of a solid one? Or how about a beveled join on
the border? For this you must turn to the shape function.
The `shape` function takes a `Shape` and *any* `ShapeStyle`
and converts them into a `Form`, giving you total control
over the styling of the shape.
-}
shape : Shape -> ShapeStyle -> Form msg
shape shape style = form <| FShape shape style


{-| `polygon points` is a polygon bounded by `points`.
-}
polygon : List Point -> Shape
polygon = Polygon


{-| An ellipse. The arugments specify the vertical and horizontal radii,
respectively.
-}
ellipse : Float -> Float -> Shape
ellipse = Ellipse


{-| A rectangle. Arguments specify width and height, respectively.
-}
rectangle : Float -> Float -> Shape
rectangle w h =
    polygon
    [ (0 - w/2,     h/2)
    , (    w/2,     h/2)
    , (    w/2, 0 - h/2)
    , (0 - w/2, 0 - h/2)]


{-| A circle.
-}
circle : Float -> Shape
circle r = ellipse r r


{-| Fills a shape with a solid color.
-}
solidFill : Color -> Shape -> Form msg
solidFill color s =
    solidFillWithBorder color 0 color s


{-| Fills a shape with a solid color and borders it with a solid line.
Arguments specify fill color, border width and border color, respectively.
-}
solidFillWithBorder : Color -> Float -> Color -> Shape -> Form msg
solidFillWithBorder fillColor borderWidth borderColor s =
    shape s
    { fill = Solid fillColor
    , border = solidStyle borderColor borderWidth
    }

    
{-| Tiles a shape with a repeated image. The arguments specify the image width,
height and url respectively.
-}
textureFill : Float -> Float -> String -> Shape -> Form msg
textureFill width height url s =
    textureFillWithBorder width height url 0 (Color.rgb 0 0 0) s


{-| Tiles a shape with a repeated image and borders it with a solid line. The
arguments specify the url width, height and url, followed by the border width and
color.
-}
textureFillWithBorder : Float -> Float -> String -> Float -> Color -> Shape -> Form msg
textureFillWithBorder width height url borderWidth borderColor s =
    shape s
    { fill = Texture url width height 1
    , border = solidStyle borderColor borderWidth
    }











-------------------- LINES --------------------


{-| Similar to the shape function, line allows you
to apply any LineStyle to a Line when converting it
to a form, giving you more fine grained control than
other similar functions.
-}
line : Line -> LineStyle -> Form msg
line line style = form <| FLine line style


{-| `polyline points` is a polyline with vertices
at `points`. (A polyline is a collection of connected
line segments. It can be thought of as drawing a 
"connect-the-dots" line through a list of points.)
-}
polyline : List Point -> Line
polyline = Polyline


{-| `segment (x1,y1) (x2,y2)` is a line segment with
endpoints at `(x1,y1)` and `(x2,y2)`.
-}
segment : Point -> Point -> Line
segment a b = polyline [a,b]


solidStyle : Color -> Float -> LineStyle
solidStyle color width =
    { color = color
    , width = width
    , cap = Flat
    , join = Sharp
    , dashing = []
    , dashOffset = 0
    }
              
              
{-| `solid width color line` is a solid line of width `width` 
and color `color` whose path is described by `line`.
-}
solid : Float -> Color -> Line -> Form msg
solid width color l =
    line l <| solidStyle color width

    
{-| The same as `solid`, except the line is dashed.
-}
dashed : Float -> Color -> Line -> Form msg
dashed width color l =
    let ls = solidStyle color width in line l { ls | dashing = [8,4] }

    
{-| The same as `solid`, except the line is dotted.
-}
dotted : Float -> Color -> Line -> Form msg
dotted width color l =
    let ls = solidStyle color width in line l { ls | dashing = [2,2] }












--------------------- TEXT ---------------------


{-| Similar to `shape` and `line`, the `text` function 
will take a string and any `TextStyle` and convert them
into a form. It is useful for when functions like `plain`
and `bold` don't offer enough flexibility and you need
more control over the styling of your text.
-}
text : String -> TextStyle -> Form msg
text text style = form <| FText text style

       
plainStyle : Int -> String -> Color -> TextStyle
plainStyle size family color =
    { color = color
    , fontSize = size
    , fontFamily = family
    , bold = False
    , italic = False
    , underlined = False
    }


{-| A line of plain text. The arguments specify the text's
font size, family and color respectively.
-}
plain : Int -> String -> Color -> String -> Form msg
plain size family color t =
    text t <| plainStyle size family color

        
{-| A line of bold text. The arguments specify the text's
font size, family and color respectively.
-}
bold : Int -> String -> Color -> String -> Form msg
bold size family color t =
    let ts = plainStyle size family color in text t { ts | bold = True }

             
{-| A line of italic text. The arguments specify the text's
font size, family and color respectively.
-}
italic : Int -> String -> Color -> String -> Form msg
italic size family color t =
    let ts = plainStyle size family color in text t { ts | italic = True }

             
{-| A line of underlined text. The arguments specify the text's
font size, family and color respectively.
-}
underlined : Int -> String -> Color -> String -> Form msg
underlined size family color t =
    let ts = plainStyle size family color in text t { ts | underlined = True }












------------------- IMAGES ----------------------

{-| An image. The arguments specify the image's width, height and url.
-}
image : Float -> Float -> String -> Form msg
image w h url = form <| FImage url w h












------------------ MODIFIERS --------------------


{-| Sets the position of a `Form`.

    -- 'circle' is now centered at (50,50)
    circle = position (50,50) circle
-}
position : Point -> Form msg -> Form msg
position (x,y) form = { form | x = x, y = y }


{-| Sets the angle of a `Form`. The argument is in radians.
-}
angle : Float -> Form msg -> Form msg
angle theta form = { form | theta = theta }


{-| Sets the scale of a `Form`. 
-}
size : Float -> Form msg -> Form msg
size scale form = { form | scale = scale }


{-| Modifies the position of a `Form`.
-}
move : Float -> Float -> Form msg -> Form msg
move x y form = { form | x = form.x + x, y = form.y + y }


{-| Modifies the angle of a `Form`. 
-}
rotate : Float -> Form msg -> Form msg
rotate theta form = { form | theta = form.theta + theta }

{-| Modifies the scale of a `Form`.
-}
scale : Float -> Form msg -> Form msg
scale scale form = { form | scale = form.scale * scale }


{-| Sets the opacity of a `Form`.
-}
opacity : Float -> Form msg -> Form msg
opacity alpha form = { form | alpha = alpha }







    



    

----------------------- SVG RENDERING --------------------


{-| Takes a `Form` and renders it to usable HTML, in this case
in the form of an SVG element. The first two arguments determine
the height and width of the SVG viewbox in pixels.
-}
svg : Float -> Float -> Form msg -> Html msg
svg width height form =
    Svg.svg
        [ Svg.height <| toString height
        , Svg.width  <| toString width
        , Svg.version "1.1"
        ] <| renderSvg' height width form


renderSvg' : Float -> Float -> Form msg -> List (Svg msg)
renderSvg' w h form =
    case form.form of

        FLine line style ->
            case line of
                    
                    Polyline ps ->
                        [ Svg.polyline
                              ((Svg.points <| svgDecodePoints ps) :: attrs w h form) [ ] ]

        FShape shape style ->
            case shape of

                Polygon ps ->
                    svgEvalFill style.fill ++
                    [ Svg.polygon
                          ((Svg.points <| svgDecodePoints ps) :: attrs w h form) [ ] ]
                        
                Ellipse rx ry ->
                    svgEvalFill style.fill ++
                    [ Svg.ellipse
                          (attrs w h form ++
                               [ Svg.rx <| toString rx
                               , Svg.ry <| toString ry
                               ]) [ ] ]

        FText text style ->
            [ Svg.text' (attrs w h form) [ Svg.text text ] ]

        FImage url width height ->
            [ Svg.image
                  (attrs w h form ++ 
                       [ Svg.width <| toString width
                       , Svg.height <| toString height
                       , Svg.xlinkHref url
                       ]) [ ] ]

        FElem elem ->
            [ Svg.foreignObject (attrs w h form) [ elem ] ]

        FGroup forms ->
            [ Svg.g (attrs w h form)
                  <| List.concat <| List.map (renderSvg' w h) forms ]


attrs : Float -> Float -> Form msg -> List (Attribute msg)
attrs width height form =
    case form.form of

        FLine line style ->
            [ Svg.stroke <| svgDecodeColor style.color
            , Svg.strokeOpacity <| svgDecodeAlpha style.color
            , Svg.strokeWidth <| toString style.width
            , Svg.strokeLinecap <| svgDecodeCap style.cap
            , Svg.strokeLinejoin <| svgDecodeJoin style.join
            , Svg.opacity <| toString form.alpha
            , Svg.transform <| svgTransform height width form
            ]

        FShape shape style ->
            [ Svg.fill <| svgDecodeFill style.fill
            , Svg.fillOpacity <| svgDecodeFillAlpha style.fill
            , Svg.stroke <| svgDecodeColor style.border.color
            , Svg.strokeOpacity <| svgDecodeAlpha style.border.color
            , Svg.strokeWidth <| toString style.border.width
            , Svg.strokeLinecap <| svgDecodeCap style.border.cap
            , Svg.strokeLinejoin <| svgDecodeJoin style.border.join
            , Svg.opacity <| toString form.alpha
            , Svg.transform <| svgTransform height width form
            ]

        FText text style ->       
            [ Svg.fill <| svgDecodeColor style.color
            , Svg.fontFamily style.fontFamily
            , Svg.fontSize <| toString style.fontSize
            , Svg.fontWeight <| if style.bold then "bold" else "normal"
            , Svg.fontStyle <| if style.italic then "italic" else "normal"
            , Svg.textDecoration <| if style.underlined then "underline" else "none"
            , Svg.transform <| svgTransform height width form
            ]

        _ -> [ Svg.transform <| svgTransform height width form ]
                
                        
svgDecodeCap : LineCap -> String
svgDecodeCap cap =
    case cap of
        Round -> "round"
        Square -> "square"
        Flat -> "butt"

                    
svgDecodeJoin : LineJoin -> String
svgDecodeJoin join =
    case join of
        Smooth -> "round"
        Sharp -> "milter"
        Bevel -> "bevel"

                
svgDecodePoints : List Point -> String
svgDecodePoints ps =
    ps |> List.map (\ (x,y) -> [toString x, toString y]) |> List.concat |> String.join " "

        
svgTransform :
    Float ->
    Float ->
        { record
            | x : Float
            , y : Float
            , theta : Float
            , scale : Float
        } ->
    String
svgTransform height width obj =
    let x = toString <| obj.x + width / 2
        y = toString <| obj.y + height / 2
        theta = toString <| obj.theta / 2 / pi * 360
        scale = toString obj.scale
    in String.concat
        [ "translate(",x,",",y,") rotate(",theta,") scale(",scale,")" ]


svgEvalFill : FillStyle -> List (Svg msg)
svgEvalFill fs =
    case fs of

        Texture url w h a ->
            [ Svg.defs [ ]
                  [ Svg.pattern
                        [ Svg.width <| toString w
                        , Svg.height <| toString h
                        , Svg.patternUnits "userSpaceOnUse"
                        , Svg.id <| toId fs
                        ] [ Svg.image
                              [ Svg.width <| toString w
                              , Svg.height <| toString h
                              , Svg.xlinkHref url
                              ] [ ] ] ] ]

        _ -> [ ]

            
svgDecodeFill : FillStyle -> String
svgDecodeFill fs =
    case fs of

        Solid c -> 
            svgDecodeColor c

        _ ->
            String.concat [ "url(#",toId fs,")" ]


svgDecodeFillAlpha : FillStyle -> String
svgDecodeFillAlpha fs =
    case fs of
        Solid c -> svgDecodeAlpha c
        Texture _ _ _ a -> toString a
        

svgDecodeColor : Color -> String
svgDecodeColor c =
    let {red,green,blue} = c |> Color.toRgb
        r = toString red
        g = toString green
        b = toString blue
    in  String.concat [ "rgb(",r,",",g,",",b,")" ]


svgDecodeAlpha : Color -> String
svgDecodeAlpha c =
    let {alpha} = c |> Color.toRgb
    in  toString alpha
        

updateHash : Char -> Int -> Int
updateHash c h =
    Bitwise.shiftLeft h 5 + h + Char.toCode c


toId : a -> String
toId a =
    "ID" ++ (
    toString <|
        String.foldl updateHash 5381
        <| toString a)

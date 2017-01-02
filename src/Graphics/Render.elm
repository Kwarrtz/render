module Graphics.Render exposing
    ( Form
    , Shape, ShapeStyle
    , Texture
    , solid, pattern, patternWithOpacity
    , linearGradient, simpleLinearGradient, angledLinearGradient
    , Line, LineStyle
    , LineCap
    , round, square, flat
    , LineJoin
    , smooth, sharp, bevel
    , TextStyle
    , TextAlign
    , left, center, right
    , Point
    , svg
    , html, group
    , styledShape
    , polygon, rectangle
    , ellipse, circle
    , bordered, filled, filledAndBordered
    , styledLine
    , segments, segment
    , solidLine, dottedLine, dashedLine
    , styledText
    , text
    , leftJustified, centered, rightJustified
    , bold, italic, underlined
    , fontColor, fontPattern, fontGradient, fontFamily
    , image
    , position, angle, scale, opacity
    , on
    , onClick, onMouseDown, onMouseUp, onMouseOver, onMouseOut
    , onFocusIn, onFocusOut
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
@docs Line, segment, segments

# Images
@docs image

# Rendering
@docs svg

# Grouping
@docs group

# Turning Stuff Into Forms

## Shapes
@docs filled, bordered, filledAndBordered

## Lines
@docs solidLine, dashedLine, dottedLine

## Text
@docs text, leftJustified, rightJustified, centered, bold, italic, underlined, fontColor, fontPattern, fontGradient, fontFamily

## HTML
@docs html

# Modifying Forms
@docs position, angle, scale, opacity

# Events

## Mouse Events
@docs onClick, onMouseDown, onMouseUp, onMouseOver, onMouseOut

## Focus Events
@docs onFocusIn, onFocusOut

## Custom Events
@docs on

# Custom Styling

@docs Texture, solid, pattern, patternWithOpacity, linearGradient, simpleLinearGradient, angledLinearGradient

## Shapes
@docs styledShape, ShapeStyle

## Lines
@docs styledLine, LineStyle, LineCap, round, flat, square, LineJoin, smooth, sharp, bevel

## Text
@docs styledText, TextStyle, TextAlign, left, right, center
-}

import Html exposing (Html)
import Color exposing (Color, Gradient, black)
import Json.Decode as Json exposing (field)

import Graphics.Render.Core as Core
import Graphics.Render.Svg as Svg




--------------------------- BASIC -------------------------


form : BasicForm msg -> Form msg
form bForm = Core.Form 0 0 0 1 1 bForm [ ]

{-| Creates a `Form` from an arbitrary `Html` element. The
resulting form is subject to all of the regular manipulations.
Note that if you are compiling to SVG, then this functionality
is not supported in Internet Explorer. -}
html : Html msg -> Form msg
html elem = form <| Core.FElem elem


{-| Takes a list of `Form`s and combines them into a single
`Form`. -}
group : List (Form msg) -> Form msg
group forms = form <| Core.FGroup forms












------------------------ SHAPES ------------------------


{-| Takes a `Shape` and *any* `ShapeStyle` and converts them into
a `Form`, giving you total control over the styling of the shape. -}
styledShape : Shape -> ShapeStyle -> Form msg
styledShape shape = form << Core.FShape shape


{-| `polygon points` is a polygon bounded by `points`. -}
polygon : List Point -> Shape
polygon = Core.Polygon


{-| An ellipse. The arugments specify the horizontal and vertical radii,
respectively. -}
ellipse : Float -> Float -> Shape
ellipse = Core.Ellipse


{-| A rectangle. The arguments specify width and height, respectively. -}
rectangle : Float -> Float -> Shape
rectangle w h =
    polygon
    [ (0 - w/2,     h/2)
    , (    w/2,     h/2)
    , (    w/2, 0 - h/2)
    , (0 - w/2, 0 - h/2)]


{-| A circle. The argument specifies the radius. -}
circle : Float -> Shape
circle r = ellipse r r

{-| Fills in a shape, making it into a 'Form'. The argument
specifies the texture of the fill. The border is left transparent. -}
filled : Texture -> Shape -> Form msg
filled texture shape =
    filledAndBordered texture 0 transparent shape


{-| Adds a border to a shape, making it into a 'Form'. The arguments
specify the width and texture of the border, respectiverly. The fill is
left transparent. -}
bordered : Float -> Texture -> Shape -> Form msg
bordered width texture shape =
    filledAndBordered transparent width texture shape


{-| Adds a fill and border to a 'Shape', making it into a 'Form'. The
first argument specifies the fill texture, and the second two arguments
specify the border width and texture, respectively. -}
filledAndBordered : Texture -> Float -> Texture -> Shape -> Form msg
filledAndBordered fill width border shape =
    form <| Core.FShape shape <| { fill = fill, border = lineStyle border width }












-------------------- LINES --------------------


{-| Similar to the `styledShape` function, `styledLine`
allows you to apply any LineStyle to a Line when converting
it to a form, giving you more fine grained control than
other similar functions. -}
styledLine : Line -> LineStyle -> Form msg
styledLine line style = form <| Core.FLine line style


{-| `polyline points` is a polyline with vertices
at `points`. (A polyline is a collection of connected
line segments. It can be thought of as drawing a
"connect-the-dots" line through a list of points.) -}
segments : List Point -> Line
segments = Core.Polyline


{-| `segment (x1,y1) (x2,y2)` is a line segment with
endpoints at `(x1,y1)` and `(x2,y2)`. -}
segment : Point -> Point -> Line
segment a b = segments [a,b]


lineStyle : Texture -> Float -> LineStyle
lineStyle stroke width =
    Core.LineStyle stroke width flat sharp [] 0


{-| Creates a Form representing a solid line from a
'Line' object. The first argument specifies the line
width and the second argument specifies the texture
to use for the line stroke. -}
solidLine : Float -> Texture -> Line -> Form msg
solidLine width stroke line =
    styledLine line <| lineStyle stroke width


{-| The same as `solidLine`, except the line is dashed. -}
dashedLine : Float -> Texture -> Line -> Form msg
dashedLine width stroke line =
    let ls = lineStyle stroke width
    in styledLine line { ls | dashing = [8,4] }


{-| The same as `solidLine`, except the line is dotted. -}
dottedLine : Float -> Texture -> Line -> Form msg
dottedLine width stroke line =
    let ls = lineStyle stroke width
    in styledLine line { ls | dashing = [2,2] }












--------------------- TEXT ---------------------


{-| Similar to `styledShape`, the `styledText` function
will take a string and any `TextStyle` and convert them
into a form. It is useful for when you need more control
over the styling of your text. -}
styledText : String -> TextStyle -> Form msg
styledText text style =
    let style_ =
            Core.TextStyle_
                style.stroke style.size style.font
                style.bold style.italic style.underlined
    in  form <| Core.FText (Core.Text text style_) style.align


{-| Left justified text. -}
leftJustified : Text -> Form msg
leftJustified t = form <| Core.FText t left


{-| Centered text. -}
centered : Text -> Form msg
centered t = form <| Core.FText t center


{-| Right justified text. -}
rightJustified : Text -> Form msg
rightJustified t = form <| Core.FText t right


{-| Creates a line of text. The first argument specifies the font
size (in pts). Font defaults to black sans-serif. -}
text : Int -> String -> Text
text size t =
    Core.Text t <| Core.TextStyle_
        (solid black) size "sans-serif"
        False False False


{-| Makes `Text` bold. -}
bold : Text -> Text
bold (Core.Text t style) =
    Core.Text t { style | bold = True }


{-| Italicizes `Text`. -}
italic : Text -> Text
italic (Core.Text t style) =
    Core.Text t { style | italic = True }


{-| Underlines `Text`. -}
underlined : Text -> Text
underlined (Core.Text t style) =
    Core.Text t { style | underlined = True }


{-| Gives a `Text` element a solid color. -}
fontColor : Color -> Text -> Text
fontColor color (Core.Text t style) =
    Core.Text t { style | stroke = solid color }


{-| Gives a `Text` element a tiled pattern. -}
fontPattern : Float -> Float -> String -> Text -> Text
fontPattern w h url (Core.Text t style) =
    Core.Text t { style | stroke = pattern w h url }


{-| Gives a `Text` element a linear gradient. -}
fontGradient : List Color -> Text -> Text
fontGradient stops (Core.Text t style) =
    Core.Text t { style | stroke = simpleLinearGradient stops }


{-| Sets the font family of `Text`. -}
fontFamily : String -> Text -> Text
fontFamily f (Core.Text t style) =
    Core.Text t { style | font = f }












------------------- IMAGES ----------------------

{-| An image. The arguments specify the image's width, height and url. -}
image : Float -> Float -> String -> Form msg
image w h url = form <| Core.FImage url w h












------------------ MODIFIERS --------------------


{-| Sets the position of a `Form`.

    -- 'circle' is now centered at (50,50)
    circle = position (50,50) circle
-}
position : Point -> Form msg -> Form msg
position (x,y) form = { form | x = x, y = y }


{-| Sets the angle of a `Form`. The argument is in radians. -}
angle : Float -> Form msg -> Form msg
angle theta form = { form | theta = theta }


{-| Sets the scale of a `Form`.  -}
scale : Float -> Form msg -> Form msg
scale scale form = { form | scale = scale }

{-| Sets the opacity of a `Form`. -}
opacity : Float -> Form msg -> Form msg
opacity alpha form = { form | alpha = alpha }














------------------- EVENTS ------------------------


{-| Adds a custom event handler to a `Form`. The first
argument specifies the event name (as you would give it
to JavaScript's `addEventListener`). The second argument
will be used to decode the JSON response from the event
listener. If the decoder succeeds, the resulting message
will be passed along to your `update` function.

    onClick : msg -> Form msg -> Form msg
    onClick msg =
       on "click" (Json.succeed msg)
-}
on : String -> Json.Decoder msg -> Form msg -> Form msg
on event decoder f = { f | handlers = (event, decoder) :: f.handlers }


simpleOn : String -> msg -> Form msg -> Form msg
simpleOn event = on event << Json.succeed


mouseOn : String -> (Point -> msg) -> Form msg -> Form msg
mouseOn event msg =
    on event <|
        Json.map msg <| Json.map2
            (\x y -> (x, y))
            (field "clientX" Json.float)
            (field "clientY" Json.float)


{-|-}
onClick : msg -> Form msg -> Form msg
onClick = simpleOn "click"


{-|-}
onMouseDown : (Point -> msg) -> Form msg -> Form msg
onMouseDown = mouseOn "mousedown"


{-|-}
onMouseUp : (Point -> msg) -> Form msg -> Form msg
onMouseUp = mouseOn "mouseup"


{-|-}
onMouseMove : (Point -> msg) -> Form msg -> Form msg
onMouseMove = mouseOn "mousemove"


{-|-}
onMouseOver : (Point -> msg) -> Form msg -> Form msg
onMouseOver = mouseOn "mouseover"


{-|-}
onMouseOut : (Point -> msg) -> Form msg -> Form msg
onMouseOut = mouseOn "mouseout"


{-|-}
onFocusIn : msg -> Form msg -> Form msg
onFocusIn = simpleOn "focusin"


{-|-}
onFocusOut : msg -> Form msg -> Form msg
onFocusOut = simpleOn "focusout"













----------------------- RENDERING --------------------


{-| Takes a `Form` and renders it to usable HTML, in this case
in the form of an SVG element. The first two arguments determine
the height and width of the SVG viewbox in pixels. -}
svg : Float -> Float -> Float -> Float -> Core.Form msg -> Html msg
svg = Svg.svg











---------------------------- CORE --------------------------


{-| Anything that can be rendered on the screen. A `Form` could be a
red circle, a line of text, or an arbitrary HTML element.

    redCircle : Form
    redCircle = circle 10 |> solidFill (rgb 255 0 0) |> position (-20,0)

    blueCircle : Form
    blueCircle = circle 10 |> solidFill (rgb 0 0 255)

    circles : Form
    circles = group [redCircle, blueCircle]
-}
type alias Form msg = Core.Form msg

type alias BasicForm msg = Core.BasicForm msg

{-| A segment of a line or curve. Only describes the shape of the line.
Position, color, width, etc. are all specified later. -}
type alias Line = Core.Line

{-| A polygon or an ellipse. Only describes the size and shape of the figure.
Position, color, width, etc. are all specified later. -}
type alias Shape = Core.Shape

{-| A line or block of text. -}
type alias Text = Core.Text

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
type alias LineStyle = Core.LineStyle

{-| Specifies the styling (color, border, etc.) of a shape. -}
type alias ShapeStyle = Core.ShapeStyle

{-| Specifies the styling (color, font, weight, etc.) of text -}
type alias TextStyle = Core.TextStyle

{-| Describes the cap style of a line. `Flat` capped lines have
no endings, `Square` capped lines have flat endings that extend
slightly past the end of the line, and `Round` capped lines have
hemispherical endings. -}
type alias LineCap = Core.LineCap

{-| Describes the join style of a line.  -}
type alias LineJoin = Core.LineJoin

{-| Describes the texture of a shape or line. It can be a solid color,
gradient, or tiled texture. -}
type alias Texture = Core.Texture

{-| Describes the alignment (justification) of a text element. -}
type alias TextAlign = Core.TextAlign

{-| A 2-tuple of `Float`s representing a 2D point. `(0,0)` represents
a point in the center of the viewport. -}
type alias Point = (Float, Float)

{-| Hemispherical linecap -}
round : LineCap
round = Core.Round

{-| Flat linecap extending slightly past the end of the line -}
square : LineCap
square = Core.Square

{-| Flat linecap. -}
flat : LineCap
flat = Core.Flat

{-| Smooth (rounded) linejoin -}
smooth : LineJoin
smooth = Core.Smooth

{-| Sharp linejoin -}
sharp : LineJoin
sharp = Core.Sharp

{-| Beveled (clipped) linejoin -}
bevel : LineJoin
bevel = Core.Bevel

{-| Center justification -}
center : TextAlign
center = Core.Center

{-| Left justification -}
left : TextAlign
left = Core.Left

{-| Right justification -}
right : TextAlign
right = Core.Right

{-| Solid color fill -}
solid : Color -> Texture
solid = Core.Solid

transparent : Texture
transparent = Core.None

{-| Tiled texture fill. Arguments determine the width, height and
url of the image. -}
pattern : Float -> Float -> String -> Texture
pattern w h url = patternWithOpacity w h url 1

{-| Tiled image fill with opacity. Arguments determine the width, height,
url and opacity of the image. -}
patternWithOpacity : Float -> Float -> String -> Float -> Texture
patternWithOpacity = Core.Pattern

{-| Linear color gradient from left to right. The argument specifies the
position and color of each of the stops (poxitions are between 0 and 1,
inclusive). -}
linearGradient : List (Float, Color) -> Texture
linearGradient = angledLinearGradient 0

{-| Simpler version of `linerGradient`. Only the color of the stops needs to
be specified. They are assumed to be equally spaced. -}
simpleLinearGradient : List Color -> Texture
simpleLinearGradient colors =
    linearGradient <| List.indexedMap
        (\i x -> (toFloat i / (toFloat <| List.length colors - 1), x)) colors

{-| Same as `linearGradient`, except the angle (in radians) of the gradient
is also specified -}
angledLinearGradient : Float -> List (Float, Color) -> Texture
angledLinearGradient = Core.Linear

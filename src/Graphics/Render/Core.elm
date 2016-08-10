module Graphics.Render.Core exposing (..)


import Color exposing (Color, Gradient)


type alias Form =
    { x : Float
    , y : Float
    , theta : Float
    , scale : Float
    , alpha : Float
    , form : BasicForm
    }


type BasicForm
    = FLine Line LineStyle
    | FShape Shape ShapeStyle
    | FGroup (List Form)


type Line
    = Polyline (List Point)


type Shape
    = Polygon (List Point)
    | Ellipse Float Float


type alias LineStyle =
    { color : Color
    , width : Float
    , cap : LineCap
    , join : LineJoin
    , dashing : List Int
    , dashOffset : Int
    }


type alias ShapeStyle =
    { fill : FillStyle
    , border : LineStyle
    }


type LineCap = Round | Square | Flat

    
type LineJoin = Smooth | Sharp | Bevel

    
type FillStyle
    = Solid Color
--    | Grad Gradient


type alias Point = (Float, Float)



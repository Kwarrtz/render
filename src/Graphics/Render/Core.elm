
module Graphics.Render.Core exposing (..)

import Color exposing (Color)
import Html exposing (Html)
import Json.Decode as Json


type alias Form msg =
    { x : Float
    , y : Float
    , theta : Float
    , scale : Float
    , alpha : Float
    , form : BasicForm msg
    , handlers : List (String, Json.Decoder msg)
    }

type BasicForm msg
    = FLine Line LineStyle
    | FShape Shape ShapeStyle
    | FText Text TextAlign
    | FImage String Float Float
    | FGroup (List (Form msg))
    | FElem (Html msg)

type Line
    = Polyline (List Point)

type Shape
    = Polygon (List Point)
    | Ellipse Float Float

type Text =
    Text String TextStyle_

type alias LineStyle =
    { stroke : Texture
    , width : Float
    , cap : LineCap
    , join : LineJoin
    , dashing : List Int
    , dashOffset : Int
    }

type alias ShapeStyle =
    { fill : Texture
    , border : LineStyle
    }

type alias TextStyle_ =
    { stroke : Texture
    , size : Int
    , font : String
    , italic : Bool
    , bold : Bool
    , underlined : Bool
    }

type alias TextStyle =
    { stroke : Texture
    , size : Int
    , font : String
    , italic : Bool
    , bold : Bool
    , underlined : Bool
    , align : TextAlign
    }


type TextAlign = Center | Left | Right

type LineCap = Round | Square | Flat

type LineJoin = Smooth | Sharp | Bevel

type Texture
    = Solid Color
    | Pattern Float Float String Float
    | Linear Float (List (Float, Color))
    | None

type alias Point = (Float, Float)

module Main exposing (..)

import Html
import Graphics.Render exposing (Point, centered, text, Form, group, solid, circle, ellipse, polygon, filledAndBordered, position, svg, rectangle, filled, angle, fontColor)
import Color exposing (rgb)


screenWidth : Float
screenWidth =
    1600


screenHeight : Float
screenHeight =
    800


main : Html.Html msg
main =
    svg 0
        0
        screenWidth
        screenHeight
        (group
            [ drawRectangle screenWidth screenHeight ( screenWidth / 2, screenHeight / 2 ) Color.lightGray
            , drawEllipse ( 30, 30 )
            , drawCircle ( screenWidth - 30, 30 )
            , drawEllipse ( screenWidth - 30, screenHeight - 30 )
            , drawCircle ( 30, screenHeight - 30 )
            , drawPolygon (100, 100) (degrees 210) Color.green
            , drawPolygon (150, 100) (degrees 160) Color.yellow
            , drawForm (1000,200) (degrees 10)
            , drawText "Demo text" 60 ( screenWidth / 2, screenHeight / 2 ) Color.black
            ]
        )

drawForm : Point -> Float -> Form msg
drawForm pos rotation =
    group
        [ drawRectangle 300 150 (0, 0) Color.blue
        , drawText "A separate form" 20 (0, 0) Color.yellow
        , drawCircle (0, 40)
        ]
        |> angle rotation
        |> position pos


drawPolygon : Point -> Float -> Color.Color -> Form msg
drawPolygon pos rotation color =
    polygon [ ( 0, 0 ), ( 10, -10 ), ( 10, -20 ), ( -10, -20 ), ( -10, -10 ) ]
        |> filled (solid <| color)
        |> angle rotation
        |> position pos

drawRectangle : Float -> Float -> Point -> Color.Color -> Form msg
drawRectangle width height pos color =
    rectangle width height
        |> filled (solid <| color)
        |> position pos


drawEllipse : Point -> Form msg
drawEllipse pos =
    ellipse 10 20
        |> filledAndBordered (solid <| rgb 0 0 255)
            5
            (solid <| rgb 0 0 0)
        |> position pos


drawCircle : Point -> Form msg
drawCircle pos =
    circle 20
        |> filledAndBordered (solid <| rgb 255 0 0)
            5
            (solid <| rgb 0 0 0)
        |> position pos


drawText : String -> Int -> Point -> Color.Color -> Form msg
drawText textContent textSize pos color =
    text textSize textContent
        |> fontColor color
        |> centered
        |> position pos

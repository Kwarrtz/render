module Graphics.Render.Svg exposing
    ( render
    )

import Svg exposing (Svg, Attribute, svg)
import Svg.Attributes as Svg 
import Html exposing (Html)

import List
import String
import Color exposing (Color, Gradient)



svgRender : Float -> Float -> Form -> Html msg
svgRender height width form =
    svg [ Svg.height <| toString height
        , Svg.width  <| toString width
        , Svg.version "1.1"
        ] <| render' height width form


svgRender' : Float -> Float -> Form -> List (Svg msg)
svgRender' h w form =
    case form.form of

        FLine line style ->
            case line of
                    
                    Polyline ps ->
                        [ Svg.polyline
                              ((Svg.points <| svgDecodePoints ps) :: attrs w h form) [ ] ]

        FShape shape style ->
            case shape of

                Polygon ps ->
                    [ Svg.polygon
                          ((Svg.points <| svgDecodePoints ps) :: attrs w h form) [ ] ]
                        
                Ellipse rx ry ->
                    [ Svg.ellipse
                          (attrs w h form ++
                               [ Svg.rx <| toString rx
                               , Svg.ry <| toString ry
                               ]) [ ] ]

        FGroup forms ->
            [ Svg.g [ Svg.transform <| transform h w form ]
                  <| List.concat <| List.map (render' w h) forms ]


attrs : Float -> Float -> Form -> List (Attribute msg)
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

        FGroup _ -> [ ]
                
                        
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
    let x = toString obj.x
        y = toString obj.y
        theta = toString obj.theta
        scale = toString obj.scale
    in String.concat
        [ "rotate(",theta,") translate(",x,",",y,") scale(",scale,")" ]


svgDecodeFill : FillStyle -> String
svgDecodeFill (Solid c) =
    svgDecodeColor c


svgDecodeFillAlpha : FillStyle -> String
svgDecodeFillAlpha (Solid c) =
    svgDecodeAlpha c
        

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
        

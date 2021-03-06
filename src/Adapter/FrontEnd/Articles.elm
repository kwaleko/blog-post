module Articles exposing (..)

import Html exposing (..)
import Html.Attributes exposing (checked, colspan, href, placeholder, style, type_, value)
import Html.Events exposing (..)
import Http
import List as List exposing (..)
import Generated.Types exposing (Article, getApiArticles, getApiArticlesBySlug)


type State
    = ListArticles (List Article)
    | OneArticle Article
    | Error Http.Error
    | Nothing


type alias Model =
    State


init : ( Model, Cmd Msg )
init =
    ( Nothing, getArticlesCmd )


type Msg
    = GetArticleBySlug String
    | ArticlesRetrieved (Result Http.Error (List Article))
    | OneArticleRetrived (Result Http.Error Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetArticleBySlug slug ->
            ( model, getArticleBySlugCmd slug )

        OneArticleRetrived (Ok article) ->
            ( OneArticle article, Cmd.none )

        OneArticleRetrived (Err error) ->
            ( Error error, Cmd.none )

        ArticlesRetrieved (Ok articles) ->
            ( ListArticles articles, Cmd.none )

        ArticlesRetrieved (Err newError) ->
            ( Error newError, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Error message ->
            div [ style [ ( "margin-left", "auto" ), ( "margin-right", "auto" ), ( "width", "800px" ) ] ] [ text (toString message) ]

        ListArticles articles ->
            div [ style [ ( "margin-left", "auto" ), ( "margin-right", "auto" ), ( "width", "100vw" ) ] ]
                [ navBar
                , div [] (posts articles)
                ]

        OneArticle article ->
            div [ style [ ( "width", "100%" ), ( "display", "block" ), ( "align", "center" ) ] ]
                [ navBar
                , articleToHtml article
                ]

        Nothing ->
            div [] []


navBar : Html Msg
navBar =
    div
        [ style
            [ ( "height", "40px" )
            , ( "background-color", "#D55757" )
            , ( "padding", "18px" )
            , ( "font-family", "Geneva" )
            , ( "font-size", "20px" )
            , ( "text-decoration", "bold" )
            , ( "letter-spacing", "2px" )
            , ( "color", "#FFFFFF" )
            ]
        ]
        [ div [ style [ ( "float", "left" ),("margin-left","3vw") ] ]
            [ a [ href "#", style [ ( "color", "#FFFFFF" ), ( "text-decoration", "none" ) ] ]
                    [ li [ style [ ( "display", "inline" ), ( "padding", "10px" ) ] ] [ text "HOME" ] ]
            ]
        , div [ style [ ( "float", "right" ) ] ]
            [ ul
                [ style
                    [ ( "padding", "0px" )
                    , ( "margin", "0px" )
                    , ( "list-style-type", "none" )
                    ]
                ]
                [
                 a [ href "#", style [ ( "color", "#FFFFFF" ), ( "text-decoration", "none" ) ] ]
                    [ li [ style [ ( "display", "inline" ), ( "padding", "10px" ) ] ] [ text "RESUME" ] ]
                , a [ href "#", style [ ( "color", "#FFFFFF" ), ( "text-decoration", "none" ) ] ]
                    [ li [ style [ ( "display", "inline" ), ( "padding", "5px" ) ] ] [ text "CONTACT" ] ]
                ]
            ]
        ]


posts : List Article -> List (Html Msg)
posts articles =
    List.map (\article -> articleTitleToHtml article) articles


articleTitleToHtml : Article -> Html Msg
articleTitleToHtml article =
    table
        [ style
            [ ( "font-family", "Mustache Script,Verdana" )
            , ( "text-decoration", "bold" )
            , ( "margin-left", "20vw" )
            , ("margin-right","20vw")
            , ("line-height","1.7em")
            ]
        ]
        [ tr []
            [ td [ colspan 3 ]
                [ p []
                    [ a
                        [ href "#"
                        , onClick (GetArticleBySlug article.articleSlug)
                        , style
                            [ ( "color", "#000000" )
                            , ( "text-decoration", "none" )
                            , ( "font-size", "2em" )
                            , ( "font-weight", "bold" )
                            ]
                        ]
                        [ text article.articleTitle ]
                    ]
                ]
            ]
        , tr
            []
            [ td
                [ style
                    [ ( "color", "#000000" )
                    , ( "text-decoration", "italic" )
                    , ( "font-size", "1em" )
                    , ( "font-weight", "normal" )
                    , ( "align", "left" )
                    , ( "width", "14%" )
                    ]
                ]
                [ text article.articleCreatedAt ]
            , td [ style [ ( "font-weight", "bold" ) ] ]
                [ input [ type_ "radio", checked True ] []
                , text "Haskell,Elm"
                ]
            ]
        , br [] []
        ,tr []
            [
             td [ colspan 2]
                 (List.map convert1 article.parsedArticle)
            ]
        ]


tagsToHtml : List String -> List (Html Msg)
tagsToHtml tags =
    List.map (\tag -> span [] [ text (tag ++ " ") ]) tags


articleToHtml : Article -> Html Msg
articleToHtml article =
    div [ style [ ( "float", "center" ), ( "width", "100%" ) ] ]
        [ table
            [ style
                [ ( "font-family", "Verdana" )
                , ( "align", "center" )
                , ( "text-decoration", "bold" )
              --   , ( "width", "50%" )
                -- , ( "float", "center" )
               , ( "margin-left", "18vw" )
            , ("margin-right","18vw")
            , ("line-height","1.7em")
                ]
            ]
            [ tr []
                [ td [ colspan 3 ]
                    [ p []
                        [ a
                            [ href "#"
                            , onClick (GetArticleBySlug article.articleSlug)
                            , style
                                [ ( "color", "#000000" )
                                , ( "text-decoration", "none" )
                                , ( "font-size", "2.5em" )
                                , ( "font-weight", "bold" )
                                , ( "align", "center" )
                                ]
                            ]
                            [ text article.articleTitle ]
                        ]
                    ]
                ]
            , tr
                []
                [ td
                    [ style
                        [ ( "color", "#000000" )
                        , ( "text-decoration", "italic" )
                        , ( "font-size", "1em" )
                        , ( "font-weight", "normal" )
                        , ( "align", "left" )
                        , ( "width", "14%" )
                        ]
                    ]
                    [ text "23-4-2017" ]
                , td [ style [ ( "font-weight", "bold" ) ] ]
                    [ input [ type_ "radio", checked True ] []
                    , text "Haskell,Elm"
                    ]
                ]
            , tr []
                [ td [ colspan 3 ]
                    [ div [] (List.map convert article.parsedArticle)
                    ]
                ]
            ]
        ]


convert : ( String, String ) -> Html a
convert ( txt, style1 ) =
    case style1 of
        "Bold" ->
            strong [] [ text txt ]

        "Italic" ->
            em [] [ text txt ]

        "Heading" ->
            h3 [] [ text txt ]

        "Mark" ->
            span [style [("background-color","#EFDD15")]] [ text txt ]

        "Code" ->
            div [style [("background-color","#EBEBE8")
                        ,("margin","1 4 1 4")]]
                [ code [] [ text txt ]
                ]

        _ ->
            text txt


convert1 : ( String, String ) -> Html a
convert1 ( txt, style1 ) = text txt


getArticlesCmd : Cmd Msg
getArticlesCmd =
    Http.send ArticlesRetrieved getApiArticles


getArticleBySlugCmd : String -> Cmd Msg
getArticleBySlugCmd slug =
    Http.send OneArticleRetrived (getApiArticlesBySlug slug)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

module Admin exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, style, value)
import Html.Events exposing (..)
import Http
import Ports exposing (clearToken)
import Types
    exposing
        ( Article
        , CreateArticle
        , postApiArticlesByUserid
        )


type alias Model =
    { title : String
    , body : String
    , tags : String
    , error : Maybe String
    , userid : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" Nothing 123, Cmd.none )


type Msg
    = NoOp
    | SetTitle String
    | SetBody String
    | SetTags String
    | SubmitArticle
    | ArticleSubmitted (Result Http.Error Article)
    | GetUidFromStorage Int
    | Logout
    --| Sucess


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetTitle titre ->
            ( { model | title = titre }, Cmd.none )

        SetBody data ->
            ( { model | body = data }, Cmd.none )

        GetUidFromStorage uId ->
            ( { model | userid = uId }, Cmd.none )

        SubmitArticle ->
            ( model, addArticleCmd 1 (CreateArticle model.title model.body []) )

        SetTags tags ->
            ( model, Cmd.none )

        ArticleSubmitted (Ok _) ->
            ( model, Cmd.none )

        ArticleSubmitted (Err message) ->
            ( { model | error = Just (toString message) }, Cmd.none )

        Logout ->
            ( model, clearToken "userid" )


view : Model -> Html Msg
view model =
    let
        message =
            case model.error of
                Nothing ->
                    ""

                Just error ->
                    error
    in
    div
        [ style
            [ ( "background-color", "#D55757" )
            , ( "width", "100%" )
            , ( "height", "auto" )
            , ( "font-family", "Geneva" )
            , ( "font-weight", "bold" )
            , ( "text-align", "center" )
            , ( "color", "#FFFFFF" )
            , ( "border-radius", "5px" )
            , ( "outline", "none" )
            , ( "padding", "20px" )
            , ( "font-size", "1.2em" )
            ]
        ]
        [ h1 [] [ text "Create a new article" ]
        , br [] []
        , input
            [ onInput SetTitle
            , placeholder "choose a title"
            , style
                [ ( "background-color", "white" )
               -- , ( "border", "none" )
                , ( "color", " black" )
                , ( "padding", "15px 32px" )
                , ( "text-align", "center" )
               -- , ( "text-decoration", "none" )
                , ( "display", "inline-block" )
                , ( "font-size", "16px" )
                , ( "margin", "4px 2px" )
               -- , ( "cursor", "pointer" )
                , ( "width", "70%" )
                , ( "height", "15px" )
                ]
            ]
            []
        , br [] []
        , textarea
            [ onInput SetBody
            , placeholder "write your article"
            , style
                [-- ( "background-color", "white" )
               -- , ( "border", "none" )
                 ( "color", " black" )
                , ( "padding", "15px 32px" )
                , ( "text-align", "left" )
               -- , ( "text-decoration", "none" )
                , ( "display", "inline-block" )
                , ( "font-size", "16px" )
                , ( "margin", "4px 2px" )
               -- , ( "cursor", "pointer" )
                , ( "width", "70%" )
                , ( "height", "400px" )
                ]
            ]
            []
        , br [] []
        , input
            [ onInput SetTags
            , placeholder "add tags separate by ,"
            , style
                [ ( "background-color", "white" )
                , ( "border", "none" )
                , ( "color", " black" )
                , ( "padding", "15px 32px" )
                , ( "text-align", "center" )
                , ( "text-decoration", "none" )
                , ( "display", "inline-block" )
                , ( "font-size", "16px" )
                , ( "margin", "4px 2px" )
                , ( "cursor", "pointer" )
                ]
            ]
            []
        , br [] []
        , button
            [ onClick SubmitArticle
            , style
                [ ( "background-color", "white" )
                , ( "border", "none" )
                , ( "color", " #D55757" )
                , ( "padding", "15px 32px" )
                , ( "text-align", "center" )
                , ( "text-decoration", "none" )
                , ( "display", "inline-block" )
                , ( "font-size", "16px" )
                , ( "margin", "4px 2px" )
                , ( "cursor", "pointer" )
                ]
            ]
            [ text "Submit" ]
        , div [] [ text message ]
        ]


addArticleCmd : Int -> CreateArticle -> Cmd Msg
addArticleCmd userid article =
    Http.send ArticleSubmitted (postApiArticlesByUserid userid article)


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

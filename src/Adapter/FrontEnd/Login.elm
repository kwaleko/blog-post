module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value,style)
import Html.Events exposing (..)
import Http
import Navigation exposing (load)
import Ports exposing (storeToken)
import Types exposing (Auth, Session, encodeSession, postApiUsersLogin)


type alias Model =
    { username : String
    , email : String
    , password : String
    , error : Maybe String
    , userid : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" Nothing Nothing, Cmd.none )


type Msg
    = NoOp
    | SetUserName String
    | SetPassword String
    | Login
    | LoginAttempt (Result Http.Error Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetPassword pass ->
            ( { model | password = pass }, Cmd.none )

        SetUserName uName ->
            ( { model | username = uName }, Cmd.none )

        LoginAttempt (Ok uId) ->
            ( { model | userid = Just uId }, Cmd.batch [ uId  |> storeToken, load "http://localhost:8000/admin.html" ] )

        LoginAttempt (Err message) ->
            ( { model | error = Just (toString message) }, Cmd.none )

        Login ->
            ( model, registerCmd (Auth model.username model.password) )


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
    div [style [( "background-color", "#D55757" )]]
        [ h3 [] [ text "Register" ]
        , br [] []
        , input [ onInput SetUserName, placeholder "write your username",
                style
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
                , ( "width", "70%" )
                , ( "height", "12px" )
                ]] []
        , br [] []
        , input [ onInput SetPassword, placeholder "write your password"
                ,style
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
                , ( "width", "70%" )
                , ( "height", "12px" )
                ]] []
        , br [] []
        , button [ onClick Login ,
                 style
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
                ]] [ text "Log In" ]
        , div [] [ text message ]
        ]


registerCmd : Auth -> Cmd Msg
registerCmd credential =
    Http.send LoginAttempt (postApiUsersLogin credential)


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

module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (..)
import Http
import Navigation exposing (load)
import Ports exposing (storeToken)
import Types exposing (Auth, Session, encodeSession, getApiUsersLogin)


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
            ( { model | userid = Just uId }, Cmd.batch [ uId |> Just |> storeToken, load "http://localhost:8000/index.html" ] )

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
    div []
        [ h3 [] [ text "Register" ]
        , br [] []
        , input [ onInput SetUserName, placeholder "write your username" ] []
        , br [] []
        , input [ onInput SetPassword, placeholder "write your password" ] []
        , br [] []
        , button [ onClick Login ] [ text "Log In" ]
        , div [] [ text message ]
        ]


registerCmd : Auth -> Cmd Msg
registerCmd credential =
    Http.send LoginAttempt (getApiUsersLogin credential)


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

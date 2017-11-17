module Register exposing (..)
import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing(value,placeholder)
import Http
import Navigation exposing (load)



import Types exposing (Register,Session,postApiUsersRegister,encodeSession)
import Ports exposing (storeToken)

type alias Model
    = {
        username : String
       ,email : String
       ,password : String
       ,error : Maybe String
       ,userid : Maybe Int
    }

init : (Model, Cmd Msg)
init = (Model "" "" "" Nothing Nothing,Cmd.none)


type Msg =
    NoOp
   | SetUserName String
   | SetEmail String
   | SetPassword String
   | SignUp
   | RegisterCompleted (Result Http.Error Int)


update : Msg -> Model -> (Model,Cmd Msg)
update msg model
    = case msg of
          NoOp -> (model,Cmd.none)
          SetPassword pass -> ({model | password = pass },Cmd.none)
          SetUserName uName -> ({model | username = uName},Cmd.none)
          SetEmail uEmail -> ({model | email = uEmail},Cmd.none)
          RegisterCompleted (Ok uId) -> ({model | userid = Just uId}, Cmd.batch [uId |> Just |>storeToken,load "http://localhost:8000/index.html"] )
          RegisterCompleted (Err message) -> ({model | error = Just (toString message)},Cmd.none)
          SignUp -> (model,registerCmd (Register model.username model.email model.password))


view : Model -> Html Msg
view model =
    let
       message = case model.error of
            Nothing -> ""
            Just error -> error
    in
    div[][
        h3 [][text "Register"]
       ,br [][]
       , input [onInput SetUserName,placeholder "choose a username"][]
       , br [][]
       ,input [onInput SetEmail,placeholder "write your email" ][]
       ,br [][]
       ,input [onInput SetPassword ,placeholder "write your password"][]
       ,br [][]
       , button [onClick SignUp][text "Sign Up"]
       ,div [][text message]
             ]



registerCmd : Register  -> Cmd Msg
registerCmd credential =
    Http.send RegisterCompleted (postApiUsersRegister credential)


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

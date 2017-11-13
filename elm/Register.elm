module Register exposing (..)
import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing(value,placeholder)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


type alias Model
    = {
        username : String
       ,password : String
       ,userid : String
       ,errorMsg : String
    }

init : (Model, Cmd Msg)
init = ( Model "" "" "" "",Cmd.none)

type Msg =
    NoOp
   | SetUserName String
   | SetPassword String
   | SubmitForm
   | RegisterCompleted (Result Http.Error String)

url : String
url = "https://e2ecd374-efa7-4edd-ae58-3ca2b9b72867.mock.pstmn.io/api/users/register"

update : Msg -> Model -> (Model,Cmd Msg)
update msg model
    = case msg of
          NoOp -> (model,Cmd.none)
          SetUserName newUserName -> ({ model | username = newUserName },Cmd.none)
          SetPassword newPass -> ({model | password = newPass},Cmd.none)
          SubmitForm -> (model ,authUserCmd model url)
          RegisterCompleted (Ok newUserId) -> ({model | userid = newUserId },Cmd.none)
          RegisterCompleted (Err newError) -> ({model | errorMsg = ( toString newError) },Cmd.none)
         -- _ -> (model,Cmd.none)



view : Model -> Html Msg
view model = div [][
        span [][text "Register Form"]
        , br [][]
        ,input [placeholder "write your usename",Html.Attributes.value  model.username , onInput SetUserName][]
        , br [][]
        ,input [placeholder "write your Password", Html.Attributes.value model.password, onInput SetPassword][]
        ,br [][]
        ,button [onClick SubmitForm][text "Register"]
         , p [][text ( toString model.userid)]
       ]

-- encode Register data from elm type to JSON
userEncoder : Model -> Encode.Value
userEncoder model =
    Encode.object
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]

-- decode JSON data to user id
userIdDecoder : Decoder String
userIdDecoder =
    Decode.field "userid" Decode.string

authUser : Model -> String -> Http.Request String
authUser model apiUrl =
    let
        body =
            model
                |> userEncoder
                |> Http.jsonBody
    in
        Http.post apiUrl body userIdDecoder

authUserCmd : Model -> String -> Cmd Msg
authUserCmd model apiUrl =
    Http.send RegisterCompleted (authUser model apiUrl)

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

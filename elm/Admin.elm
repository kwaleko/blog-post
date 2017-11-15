module Admin exposing (..)
import Html exposing (..)
import Html.Events exposing(..)
import Html.Attributes exposing(value,placeholder)
import Http



import Types exposing (CreateArticle,Article ,postApiArticlesByUserid)


type alias Model
    = {
        title : String
       ,body : String
       ,tags : String
       ,error : Maybe String
       ,userid : Int
    }

init : (Model, Cmd Msg)
init = (Model "" "" "" Nothing 123,Cmd.none)

type Msg =
    NoOp
   | SetTitle String
   | SetBody String
   | SetTags String
   | SubmitArticle
   | ArticleSubmitted (Result Http.Error Article)

url : String
url = "https://e2ecd374-efa7-4edd-ae58-3ca2b9b72867.mock.pstmn.io/api/users/register"

update : Msg -> Model -> (Model,Cmd Msg)
update msg model
    = case msg of
          NoOp -> (model,Cmd.none)
          SetTitle titre -> ({model | title = titre },Cmd.none)
          SetBody data -> ({model | body = data},Cmd.none)
          SubmitArticle -> (model,addArticleCmd model.userid (CreateArticle model.title model.body []))
          SetTags tags -> (model,Cmd.none)
          ArticleSubmitted (Ok _) -> (model,Cmd.none)
          ArticleSubmitted (Err message) -> ({model | error = Just (toString message)},Cmd.none)



view : Model -> Html Msg
view model =
    let
       message = case model.error of
            Nothing -> ""
            Just error -> error
    in
    div[][
        h3 [][text "Create a new article"]
       ,br [][]
       , input [onInput SetTitle,placeholder "choose a title"][]
       , br [][]
       ,textarea [onInput SetBody,placeholder "write your article" ][]
       ,br [][]
       ,input [onInput SetTags ,placeholder "add tags"][]
       ,br [][]
       , button [onClick SubmitArticle][text "Submit"]
       ,div [][text message]
             ]



addArticleCmd : Int -> CreateArticle  -> Cmd Msg
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

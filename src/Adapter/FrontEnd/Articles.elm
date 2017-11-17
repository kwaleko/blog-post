module Articles exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, placeholder, value)
import Html.Events exposing (..)
import Http
import List as List exposing (..)
import Types exposing (Article, getApiArticles, getApiArticlesBySlug)


type State
    = ListArticles (List Article)
    | OneArticle Article
    | Error String
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
            ( Error (toString error), Cmd.none )

        ArticlesRetrieved (Ok articles) ->
            ( ListArticles articles, Cmd.none )

        ArticlesRetrieved (Err newError) ->
            ( Error (toString newError), Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Error message ->
            div [] [ text message ]

        ListArticles articles ->
            div [] (posts articles)

        OneArticle article ->
            articleToHtml article

        Nothing ->
            div [] []


posts : List Article -> List (Html Msg)
posts articles =
    List.map (\article -> articleTitleToHtml article) articles


articleTitleToHtml : Article -> Html Msg
articleTitleToHtml article =
    div []
        [ h1 [] [ a [ href "#", onClick (GetArticleBySlug article.articleSlug) ] [ text article.articleTitle ] ]
        ]


tagsToHtml : List String -> List (Html Msg)
tagsToHtml tags =
    List.map (\tag -> span [] [ text (tag ++ " ") ]) tags


articleToHtml : Article -> Html Msg
articleToHtml article =
    div []
        [ h1 [] [ text article.articleTitle ]
        , br [] []
        , div [] (tagsToHtml article.articleTags)
        , p [] [ text article.articleBody ]
        ]


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

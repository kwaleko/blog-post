module Types exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Http
import String


type alias Register =
    { registerEmail : String
    , registerUserName : String
    , registerPassword : String
    }

encodeRegister : Register -> Json.Encode.Value
encodeRegister x =
    Json.Encode.object
        [ ( "registerEmail", Json.Encode.string x.registerEmail )
        , ( "registerUserName", Json.Encode.string x.registerUserName )
        , ( "registerPassword", Json.Encode.string x.registerPassword )
        ]

type alias Article =
    { articleSlug : String
    , articleTitle : String
    , articleBody : String
    , articleAuthor : String
    , articleTags : List (String)
    , parsedArticle : List ((String, String))
    , articleCreatedAt : String
    , articleUpdatedAt : String
    }

decodeArticle : Decoder Article
decodeArticle =
    decode Article
        |> required "articleSlug" string
        |> required "articleTitle" string
        |> required "articleBody" string
        |> required "articleAuthor" string
        |> required "articleTags" (list string)
        |> required "parsedArticle" (list (map2 (,) (index 0 string) (index 1 string)))
        |> required "articleCreatedAt" string
        |> required "articleUpdatedAt" string

type alias CreateArticle =
    { createArticleTitle : String
    , createArticleBody : String
    , createArticleTags : List (String)
    }

encodeCreateArticle : CreateArticle -> Json.Encode.Value
encodeCreateArticle x =
    Json.Encode.object
        [ ( "createArticleTitle", Json.Encode.string x.createArticleTitle )
        , ( "createArticleBody", Json.Encode.string x.createArticleBody )
        , ( "createArticleTags", (Json.Encode.list << List.map Json.Encode.string) x.createArticleTags )
        ]

type alias Auth =
    { authEmail : String
    , authPassword : String
    }

encodeAuth : Auth -> Json.Encode.Value
encodeAuth x =
    Json.Encode.object
        [ ( "authEmail", Json.Encode.string x.authEmail )
        , ( "authPassword", Json.Encode.string x.authPassword )
        ]

type alias ArticleBody =
    { content : String
    }

encodeArticleBody : ArticleBody -> Json.Encode.Value
encodeArticleBody x =
    Json.Encode.object
        [ ( "content", Json.Encode.string x.content )
        ]

type alias PArticleBody =
    { pContent : List ((String, String))
    }

decodePArticleBody : Decoder PArticleBody
decodePArticleBody =
    decode PArticleBody
        |> required "pContent" (list (map2 (,) (index 0 string) (index 1 string)))

postApiUsersRegister : Register -> Http.Request (Int)
postApiUsersRegister body =
    Http.request
        { method =
            "POST"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://localhost:8001"
                , "api"
                , "users"
                , "register"
                ]
        , body =
            Http.jsonBody (encodeRegister body)
        , expect =
            Http.expectJson int
        , timeout =
            Nothing
        , withCredentials =
            False
        }

postApiUsersLogin : Auth -> Http.Request (Int)
postApiUsersLogin body =
    Http.request
        { method =
            "POST"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://localhost:8001"
                , "api"
                , "users"
                , "login"
                ]
        , body =
            Http.jsonBody (encodeAuth body)
        , expect =
            Http.expectJson int
        , timeout =
            Nothing
        , withCredentials =
            False
        }

postApiArticlesByUserid : Int -> CreateArticle -> Http.Request (Article)
postApiArticlesByUserid capture_userid body =
    Http.request
        { method =
            "POST"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://172.104.229.76:8001"
                , "api"
                , "articles"
                , capture_userid |> toString |> Http.encodeUri
                ]
        , body =
            Http.jsonBody (encodeCreateArticle body)
        , expect =
            Http.expectJson decodeArticle
        , timeout =
            Nothing
        , withCredentials =
            False
        }

getApiArticlesBySlug : String -> Http.Request (Article)
getApiArticlesBySlug capture_slug =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://localhost:8001"
                , "api"
                , "articles"
                , capture_slug |> toString |> Http.encodeUri
                ]
        , body =
            Http.emptyBody
        , expect =
            Http.expectJson decodeArticle
        , timeout =
            Nothing
        , withCredentials =
            False
        }

getApiArticles : ArticleBody -> Http.Request (PArticleBody)
getApiArticles body =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://localhost:8001"
                , "api"
                , "articles"
                ]
        , body =
            Http.jsonBody (encodeArticleBody body)
        , expect =
            Http.expectJson decodePArticleBody
        , timeout =
            Nothing
        , withCredentials =
            False
        }

getApiArticles : Http.Request (List (Article))
getApiArticles =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ "http://localhost:8001"
                , "api"
                , "articles"
                ]
        , body =
            Http.emptyBody
        , expect =
            Http.expectJson (list decodeArticle)
        , timeout =
            Nothing
        , withCredentials =
            False
        }

module  Types exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Http
import String
import Tuple


type alias Register =
    { registerEmail : String
    , registerUserName : String
    , registerPassword : String
    }

decodeRegister : Decoder Register
decodeRegister =
    decode Register
        |> required "registerEmail" string
        |> required "registerUserName" string
        |> required "registerPassword" string

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

decodeCreateArticle : Decoder CreateArticle
decodeCreateArticle =
    decode CreateArticle
        |> required "createArticleTitle" string
        |> required "createArticleBody" string
        |> required "createArticleTags" (list string)

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

decodeAuth : Decoder Auth
decodeAuth =
    decode Auth
        |> required "authEmail" string
        |> required "authPassword" string

encodeAuth : Auth -> Json.Encode.Value
encodeAuth x =
    Json.Encode.object
        [ ( "authEmail", Json.Encode.string x.authEmail )
        , ( "authPassword", Json.Encode.string x.authPassword )
        ]

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
                [ "http://localhost:8001"
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

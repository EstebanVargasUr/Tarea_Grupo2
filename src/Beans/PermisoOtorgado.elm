module Beans.Login exposing (..)

import RemoteData exposing (RemoteData)
import Http.Error exposing (RequestError)
import Http.Request exposing (Request)
import Http.Methods exposing (..)
import Task exposing (map)
import JsonApi.Decode exposing (resource,relationship)
import JsonApi.Document exposing (resource)
import Json.Encode exposing (Value)
import JsonApi.Encode.Document exposing (build)
import JsonApi.Resource exposing (build)
import JsonApi.Encode exposing (document)
import Json.Decode exposing (Decoder)
import Beans.Login as Login

type alias PermisoOtorgado =
   { id : Long 
   , fechaRegistro : Date; 
   , estado : boolean;
   , usuario :Long
   , permiso : Long
   }

type alias Post =
    { id : String
    , title : String
    , body : String
    , creator : Login
    }

type alias PostPayload =
    { title : String
    , body : String
    }

createPost : (RemoteData.RemoteData Http.Error.RequestError Post) -> PostPayload -> Cmd msg
createPost msg body =
    Http.Request.request
        { headers = []
        , url = { url = "http://localhost:8099/ArchivosRelacionados", method = Http.Methods.POST }
        , body = encodeBody body
        , documentDecoder = JsonApi.Decode.resource "posts" postDecoder
        }
        |> Task.map (RemoteData.map JsonApi.Document.resource)
        |> Task.perform msg


encodeBody : PostPayload -> Json.Encode.Value
encodeBody body =
    JsonApi.Encode.Document.build
        |> JsonApi.Encode.Document.withResource
            (JsonApi.Resource.build "posts"
                |> JsonApi.Resource.withAttributes
                    [ ( "body", Json.Encode.string body.body )
                    , ( "title", Json.Encode.string body.title )
                    ]
            )
        |> JsonApi.Encode.document


postDecoder : JsonApi.Resource.Resource -> Json.Decode.Decoder Post
postDecoder res =
    Json.Decode.map4 Post
        (Json.Decode.succeed (JsonApi.Resource.id res))
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "body" Json.Decode.string)
        (JsonApi.Decode.relationship "creator" res Login.loginDecoder )


loginDecoder : JsonApi.Resource.Resource -> Json.Decode.Decoder Login
loginDecoder res = 
    Json.Decode.map2 Login
        (Json.Decode.succeed (JsonApi.Resource.id res))
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "fechaRegistro" Json.Decode.string)
        (Json.Decode.field "estado" Json.Decode.string)
        (Json.Decode.field "usuario" Json.Decode.string)
        (Json.Decode.field "permiso" Json.Decode.string)
        
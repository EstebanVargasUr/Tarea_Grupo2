module Beans.Cliente exposing (..)

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
import Beans.Cliente as Cliente

type alias Cliente =
   { 
     id : Long    
   , nombreCompleto : String
   , cedula : String
   , telefono : String
   , direccion : String
   , passwordEncriptado : String
   , fechaRegistro : Date
   , fechaModificacion : Date
   , estado : Bool
   }


type alias Post =
    { id : Long
    , title : String
    , body : String
    , creator : Cliente
    }


type alias PostPayload =
    { title : String
    , body : String
    }


createPost : (RemoteData.RemoteData Http.Error.RequestError Post) -> PostPayload -> Cmd msg
createPost msg body =
    Http.Request.request
        { headers = []
        , url = { url = "http://localhost:8099/cliente", method = Http.Methods.POST }
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
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "body" Json.Decode.string)
        (JsonApi.Decode.relationship "creator" res Cliente.clienteDecoder )


clienteDecoder : JsonApi.Resource.Resource -> Json.Decode.Decoder Cliente
clienteDecoder res = 
        Json.Decode.map9 Cliente
        (Json.Decode.field "id" Json.Decode.long)
        (Json.Decode.field "nombreCompleto" Json.Decode.string)
        (Json.Decode.field "cedula" Json.Decode.string)
        (Json.Decode.field "telefono" Json.Decode.string)
        (Json.Decode.field "direccion" Json.Decode.string)
        (Json.Decode.field "passwordEncriptado" Json.Decode.string)
        (Json.Decode.field "fechaRegistro" Json.Decode.date)
        (Json.Decode.field "fechaModificacion" Json.Decode.date)
        (Json.Decode.field "estado" Json.Decode.bool)
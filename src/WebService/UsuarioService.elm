module WebService.UsuarioService exposing (..)

import Http.Error exposing (RequestError)
import RemoteData exposing (RemoteData)
import Beans.Usuario exposing (Post)

type Msg =
    OnPostCreated (RemoteData.RemoteData Http.Error.RequestError Post)


type alias Model =
    { post : RemoteData.RemoteData Http.Error.RequestError Post }


newPost : PostPayload
newPost =
    { title = "My new post"
    , body = "This is a new post"
    }


init : ( Model, Cmd Msg )
init =
    ( { post = RemoteData.Loading }
    , createPost OnPostCreated newPost
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPostCreated post ->
            ( { model | post = post }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    case model.post of
        RemoteData.NotAsked ->
            text "The post will be created soon"

        RemoteData.Loading ->
            text "Still a few seconds to wait!"

        RemoteData.Failure error ->
            viewError error

        RemoteData.Success post ->
            div []
                [ div [ class "post-title" ] [ text post.title ]
                , div [ class "post-body" ] [ text post.body ]
                , div [ class "post-creator" ] [ text post.creator.name ]
                ]


viewError : Http.Error.RequestError -> Html Msg
viewError error =
    case error of
        Http.Error.HttpError httpError ->
            text "This is a HTTP error as we already know them..."

        Http.Error.CustomError msg ->
            text ("Custom error " ++ msg)

        Http.Error.JsonApiError errors ->
            text "This is an error coming from the jsonapi paylaod"


subscriptions : Model -> Sub Msg
subscriptions = 
    Sub.none
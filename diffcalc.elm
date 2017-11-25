import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, onCheck)
import Array exposing (..)

main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }

-- model

type alias Player = 
    { name : String
    , level : Int
    , active : Bool 
    }

type alias Model = 
    { players : Array Player
    , nextPlayer : Player
    }

model : Model
model = Model Array.empty (Player "" 0 True)

removePlayer : Int -> Array a -> Array a
removePlayer idx arr =
    Array.append (Array.slice 0 idx arr) (Array.slice (idx + 1) (Array.length arr) arr)


-- messages

type Msg 
    = AddPlayer Player
    | RemovePlayer Int
    | ChangePlayer Int String Int Bool
    | UpdateNext String Int

update : Msg -> Model -> Model
update msg model =
    case msg of
        AddPlayer newPlayer ->
            { model | players = Array.push newPlayer model.players }
        RemovePlayer idx ->
            { model | players = removePlayer idx model.players }
        ChangePlayer idx name lvl active ->
            { model | players = Array.set idx (Player name lvl active) model.players }
        UpdateNext name lvl ->
            { model | nextPlayer = Player name lvl True }


-- VIEW

view : Model -> Html Msg
view model =
    table [] 
        [ thead [] 
            [ tr [] 
                [ th [] [ text "Active" ]
                , th [] [ text "Character" ]
                , th [] [ text "Level" ]
                , th [] []
                ]
            ]
        , tbody [] ((Array.toList (Array.indexedMap makeRow model.players)) ++ 
            [ tr [] 
                [ td [] [] 
                , td [] [ input [ type_ "text"
                                , placeholder "character"
                                , value model.nextPlayer.name
                                , onInput (\ newName -> UpdateNext newName model.nextPlayer.level)
                                ] []
                        ]
                , td [] [ input [ type_ "number" 
                                , value (toString model.nextPlayer.level)
                                , onInput (\ newLvlStr -> UpdateNext model.nextPlayer.name (Result.withDefault 0 (String.toInt newLvlStr)))
                                ] []
                        ]
                , td [] [ input [ type_ "button"
                                , value "+"
                                , onClick (AddPlayer model.nextPlayer)
                                ] [] 
                        ]
                ]
            ])
        ]

makeRow : Int -> Player -> Html Msg
makeRow index player =
    tr [] 
        [ td [] [ input [ type_ "checkbox"
                        , checked player.active
                        , onCheck (ChangePlayer index player.name player.level) 
                        ] 
                        [] 
                ]
        , td [] [ input [ type_ "text"
                        , value player.name
                        , onInput (\ newName -> ChangePlayer index newName player.level player.active )
                        ] 
                        [] 
                ]
        , td [] [ input [ type_ "number"
                        , value (toString player.level)
                        , onInput (\ newLvl -> ChangePlayer index player.name (Result.withDefault 0 (String.toInt newLvl)) player.active ) 
                        ] 
                        [] 
                ]
        , td [] [ input [ type_ "button"
                        , value "-"
                        , onClick (RemovePlayer index)
                        ] 
                        [] 
                ]
        ]
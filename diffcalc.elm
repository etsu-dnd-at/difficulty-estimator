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

type alias Enemy =
    { xp : Int
    , count : Int
    }

type alias Model =
    { players : Array Player
    , nextPlayer : Player
    , enemies : Array Enemy
    , nextEnemy : Enemy
    }

model : Model
model =
    { players = Array.empty
    , nextPlayer = Player "" 1 True
    , enemies = Array.empty
    , nextEnemy = Enemy 0 0
    }

removePlayer : Int -> Array a -> Array a
removePlayer idx arr =
    Array.append (Array.slice 0 idx arr) (Array.slice (idx + 1) (Array.length arr) arr)


-- messages
-- TODO: There is symmetry here; these can be consolidated if you use different types
type Msg
    = AddPlayer Player
    | RemovePlayer Int
    | ChangePlayer Int String Int Bool
    | UpdateNext String Int
    | AddEnemy Enemy
    | ChangeEnemy Int Int Int
    | RemoveEnemy Int
    | UpdateNextEnemy Int Int

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
        AddEnemy newEnemy ->
            { model | enemies = Array.push newEnemy model.enemies }
        RemoveEnemy idx ->
            { model | enemies = removePlayer idx model.enemies }
        ChangeEnemy idx xp count ->
            { model | enemies = Array.set idx (Enemy xp count) model.enemies }
        UpdateNextEnemy xp count ->
            { model | nextEnemy = Enemy xp count }


-- VIEW
view : Model -> Html Msg
view model =
    div [ id "wrap-entry-tables" ]
        [ div [] [ characterView model ]
        , div [] [ enemyView model ]
        ]

characterView : Model -> Html Msg
characterView model =
    table [ class "entry-table" ]
        [ caption [] [ text "Characters" ]
        , thead []
            [ tr []
                [ th [] [ text "Active" ]
                , th [] [ text "Character" ]
                , th [] [ text "Level" ]
                , th [] []
                ]
            ]
        , tbody [] (Array.toList (Array.indexedMap makeCharacterRow model.players))
        , tfoot [] [ tr []
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
                    ]
        ]

makeCharacterRow : Int -> Player -> Html Msg
makeCharacterRow index player =
    tr [ style [("opacity", if player.active then "1.0" else "0.5")] ]
        [ td    [ onClick (ChangePlayer index player.name player.level (not player.active))
                ]
                [ input [ type_ "checkbox"
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

enemyView : Model -> Html Msg
enemyView model =
    table [ class "entry-table" ]
            [ caption [] [ text "Enemies" ]
            , thead []
                            [ tr [] [ th [] []
                            , th [] [ text "XP" ]
                            , th [] [ text "Count" ]
                            , th [] []
                            ]
                        ]
             , tbody [] (Array.toList (Array.indexedMap makeEnemyRow model.enemies))
             , tfoot [] [ tr [] [ td [] []
                                , td [] [ input [ type_ "number"
                                                , placeholder "XP"
                                                , step "10"
                                                , onInput (\newXp -> UpdateNextEnemy (Result.withDefault 0 (String.toInt newXp)) model.nextEnemy.count)
                                                ] []
                                        ]
                                , td [] [ input [ type_ "number"
                                                , placeholder "Count"
                                                , onInput (\newCount -> UpdateNextEnemy model.nextEnemy.xp (Result.withDefault 0 (String.toInt newCount)))
                                                ] []
                                        ]
                                , td [] [ input [ type_ "button"
                                                , value "+"
                                                , onClick (AddEnemy model.nextEnemy)
                                                ] []
                                        ]
                                ] ]
             ]

makeEnemyRow : Int -> Enemy -> Html Msg
makeEnemyRow idx enemy =
    tr [] [ td [] [ text (toString (idx + 1)) ]
          , td [] [ input [ type_ "number"
                          , value (toString enemy.xp)
                          , step "10"
                          , onInput (\ newXp -> ChangeEnemy idx (Result.withDefault 0 (String.toInt newXp)) enemy.count)
                          ] []
                  ]
          , td [] [ input [ type_ "number"
                          , value (toString enemy.count)
                          , onInput (\ newCount -> ChangeEnemy idx enemy.xp (Result.withDefault 0 (String.toInt newCount)))
                          ] []
                  ]
          , td [] [ input [ type_ "button"
                          , value "-"
                          , onClick (RemoveEnemy idx)
                          ] []
                  ]
          ]


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, onCheck)
import Array exposing (..)
import Guards exposing (..)

main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }

-- MODEL

type alias Player =
    { name : String
    , level : Int
    , active : Bool
    }

type alias Enemy =
    { xp : Int
    , count : Int
    }

type alias InputTableModel a =
    { rows : Array a
    , next : a
    }

type alias Model =
    { players : InputTableModel Player
    , enemies : InputTableModel Enemy
    }

model : Model
model =
    { players =
        { rows = Array.empty
        , next = Player "" 1 True
        }
    , enemies =
        { rows = Array.empty
        , next = Enemy 0 0
        }
    }


-- MESSAGES
{-
  These messages make the update function nice, but they are messy to create!
  It made the view functions ugly. Maybe create some convenience functions
  for making instances of these messages?
-}

type InputMsg a
    = Add a
    | Remove Int
    | Replace Int a
    | UpdateNext a

type Msg
    = PlayerInput (InputMsg Player)
    | EnemyInput (InputMsg Enemy)

-- UPDATE

update : Msg -> Model -> Model
update msg model =
    case msg of
        PlayerInput playerMsg ->
            { model | players = updateInputTable model.players playerMsg }
        EnemyInput enemyMsg ->
            { model | enemies = updateInputTable model.enemies enemyMsg }

updateInputTable : InputTableModel a -> InputMsg a -> InputTableModel a
updateInputTable table msg =
    case msg of
        Add it ->
            { table | rows = Array.push it table.rows }
        Remove idx ->
            { table | rows = removeElement idx table.rows }
        Replace idx it ->
            { table | rows = Array.set idx it table.rows }
        UpdateNext it ->
            { table | next = it }

removeElement : Int -> Array a -> Array a
removeElement idx arr =
    Array.append (Array.slice 0 idx arr) (Array.slice (idx + 1) (Array.length arr) arr)

-- VIEW
view : Model -> Html Msg
view model =
    div [ id "wrap-entry-tables" ]
        [ div [] [ characterView model.players ]
        , div [] [ enemyView model.enemies ]
        ]

characterView : InputTableModel Player -> Html Msg
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
        , tbody [] (Array.toList (Array.indexedMap makeCharacterRow model.rows))
        , tfoot [] [ tr []
                        [ td [] []
                        , td [] [ input [ type_ "text"
                                        , placeholder "character"
                                        , value model.next.name
                                        , onInput (\ newName -> PlayerInput <| UpdateNext <| Player newName model.next.level True)
                                        ] []
                                ]
                        , td [] [ input [ type_ "number"
                                        , value (toString model.next.level)
                                        , onInput (\ newLvlStr -> PlayerInput <| UpdateNext <| Player model.next.name
                                                                                                      (Result.withDefault 0 <| String.toInt newLvlStr)
                                                                                                      True)
                                        ] []
                                ]
                        , td [] [ input [ type_ "button"
                                        , value "+"
                                        , onClick <| PlayerInput <| Add model.next
                                        ] []
                                ]
                        ]
                    ]
        ]

makeCharacterRow : Int -> Player -> Html Msg
makeCharacterRow index player =
    tr [ style [("opacity", if player.active then "1.0" else "0.5")] ]
        [ td    [ onClick (PlayerInput <| Replace index <| Player player.name player.level <| not player.active)
                ]
                [ input [ type_ "checkbox"
                        , checked player.active
                        , onCheck (\ checked -> PlayerInput <| Replace index <| Player player.name
                                                                                      player.level
                                                                                      checked)
                        ]
                        []
                ]
        , td [] [ input [ type_ "text"
                        , value player.name
                        , onInput (\ newName -> PlayerInput <| Replace index <| Player newName
                                                                                       player.level
                                                                                       player.active)
                        ]
                        []
                ]
        , td [] [ input [ type_ "number"
                        , Html.Attributes.min "1"
                        , Html.Attributes.max "20"
                        , value (toString player.level)
                        , onInput (\ newLvl -> PlayerInput <| Replace index <| Player player.name
                                                                                      (Result.withDefault 0 (String.toInt newLvl))
                                                                                      player.active)
                        ]
                        []
                ]
        , td [] [ input [ type_ "button"
                        , value "-"
                        , onClick (PlayerInput <| Remove index)
                        ]
                        []
                ]
        ]

enemyView : InputTableModel Enemy -> Html Msg
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
             , tbody [] (Array.toList (Array.indexedMap makeEnemyRow model.rows))
             , tfoot [] [ tr [] [ td [] []
                                , td [] [ input [ type_ "number"
                                                , placeholder "XP"
                                                , step "25"
                                                , onInput (\newXp -> EnemyInput <| UpdateNext <| Enemy (Result.withDefault 0 (String.toInt newXp)) model.next.count)
                                                ] []
                                        ]
                                , td [] [ input [ type_ "number"
                                                , placeholder "Count"
                                                , onInput (\newCount -> EnemyInput <| UpdateNext <| Enemy model.next.xp (Result.withDefault 0 (String.toInt newCount)))
                                                ] []
                                        ]
                                , td [] [ input [ type_ "button"
                                                , value "+"
                                                , onClick (EnemyInput <| Add model.next)
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
                          , onInput (\ newXp -> EnemyInput <| Replace idx <| Enemy (Result.withDefault 0 (String.toInt newXp)) enemy.count)
                          ] []
                  ]
          , td [] [ input [ type_ "number"
                          , value (toString enemy.count)
                          , onInput (\ newCount -> EnemyInput <| Replace idx <| Enemy enemy.xp (Result.withDefault 0 (String.toInt newCount)))
                          ] []
                  ]
          , td [] [ input [ type_ "button"
                          , value "-"
                          , onClick (EnemyInput <| Remove idx)
                          ] []
                  ]
          ]


-- how to model thresholds for character levels?
-- how to model multiplier for monster count?

multForEnemyCount : Int -> Float
multForEnemyCount count = (count <= 1)  => 1.0
                       |= (count <= 2)  => 1.5
                       |= (count <= 6)  => 2.0
                       |= (count <= 10) => 2.5
                       |= (count <= 14) => 3.0
                       |= 4.0

type Difficulty
    = Easy
    | Medium
    | Hard
    | Deadly

type alias Thresholds =
    { easy : Int
    , medium : Int
    , hard : Int
    , deadly : Int
    }

getThresholdForDifficulty : Thresholds -> Difficulty -> Int
getThresholdForDifficulty th diff =
    case diff of
        Easy ->
            th.easy
        Medium ->
            th.medium
        Hard ->
            th.hard
        Deadly ->
            th.deadly

thresholdsForLevels : Array Thresholds
thresholdsForLevels = Array.fromList
    [ Thresholds 0    0    0    0
    , Thresholds 25   50   75   100
    , Thresholds 50   100  150  200
    , Thresholds 75   150  225  400
    , Thresholds 125  250  375  500
    , Thresholds 250  500  750  1100
    , Thresholds 300  600  900  1400
    , Thresholds 350  750  1100 1700
    , Thresholds 450  900  1400 2100
    , Thresholds 550  1100 1600 2400
    , Thresholds 600  1300 1900 2800
    , Thresholds 800  1600 2400 3600
    , Thresholds 1000 2000 3000 4500
    , Thresholds 1100 2200 3400 5100
    , Thresholds 1250 2500 3800 5700
    , Thresholds 1400 2800 4300 6400
    , Thresholds 1600 3200 4800 7200
    , Thresholds 2000 3900 5900 8800
    , Thresholds 2100 4200 6300 9500
    , Thresholds 2400 4900 7300 10900
    , Thresholds 2800 5700 8500 12700
    ]

getThresholdsForLevel : Int -> Thresholds
getThresholdsForLevel lvl =
    let
        top = Array.length thresholdsForLevels
        clampedLvl = clamp 0 top lvl
    in
        case Array.get clampedLvl thresholdsForLevels of
            Just thresh -> thresh
            _ -> Thresholds 0 0 0 0-- should neve happen since we clamped the level

type alias EnemyXpCalc =
    { enemy : Enemy
    , totalXp : Int
    , mult : Float
    , adjust : Int
    }

calcEnemyStuff : Enemy -> EnemyXpCalc
calcEnemyStuff enemy =
    let
        totalXp = enemy.count * enemy.xp
        mult = multForEnemyCount enemy.count
        adjust = floor (mult * toFloat totalXp)
    in
        EnemyXpCalc enemy totalXp mult adjust

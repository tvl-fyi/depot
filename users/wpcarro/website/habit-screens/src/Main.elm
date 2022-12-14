module Main exposing (main)

import Browser
import Habits
import Html exposing (..)
import State
import Time


subscriptions : State.Model -> Sub State.Msg
subscriptions model =
    -- once per minute
    Time.every (1000 * 60) (\_ -> State.MaybeAdjustWeekday)


view : State.Model -> Html State.Msg
view model =
    case model.view of
        State.Habits ->
            Habits.render model


main =
    Browser.element
        { init = \() -> State.init
        , subscriptions = subscriptions
        , update = State.update
        , view = view
        }

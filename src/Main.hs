{-# LANGUAGE OverloadedStrings #-}
module Main where

import Affection as A
import qualified SDL

import Linear as L

import NanoVG hiding (V2(..), V4(..))

import Control.Monad (when)
import Control.Monad.IO.Class (liftIO)

-- internal imports

import Types
import StateMachine ()
import Init

main :: IO ()
main = do
  logIO A.Debug "Starting"
  withAffection AffectionConfig
    { initComponents = All
    , windowTitle    = "Haskelloids"
    , windowConfig   = SDL.defaultWindow
      { SDL.windowOpenGL = Just SDL.defaultOpenGL
        { SDL.glProfile        = SDL.Core SDL.Normal 3 2
        , SDL.glColorPrecision = V4 8 8 8 1
        }
      , SDL.windowResizable = True
      }
    , initScreenMode = SDL.Windowed
    , canvasSize     = Nothing
    , loadState      = load
    , preLoop        = pre >> smLoad Menu
    , eventLoop      = handle
    , updateLoop     = update
    , drawLoop       = draw
    , cleanUp        = \_ -> return ()
    }

pre :: Affection UserData ()
pre = do
  subs <- subsystems <$> getAffection
  liftIO $ logIO A.Debug "Setting global resize event listener"
  _ <- partSubscribe (subWindow subs) (fitViewport (800/600))
  _ <- partSubscribe (subKeyboard subs) $ \kbdev ->
    when (msgKbdKeyMotion kbdev == SDL.Pressed) $
      case SDL.keysymKeycode (msgKbdKeysym kbdev) of
        SDL.KeycodeF -> do
          dt <- getDelta
          liftIO $ logIO A.Debug $ "FPS: " ++ show (1/dt)
        SDL.KeycodeO -> toggleScreen
        _ -> return ()
  return ()

update :: Double -> Affection UserData ()
update sec = do
  ud <- getAffection
  smUpdate (state ud) sec

handle :: [SDL.EventPayload] -> Affection UserData ()
handle e = do
  (Subsystems w k) <- subsystems <$> getAffection
  _ <- consumeSDLEvents w =<< consumeSDLEvents k e
  return ()

draw :: Affection UserData ()
draw = do
  ud <- getAffection
  liftIO $ beginFrame (nano ud) 800 600 1
  smDraw (state ud)
  drawVignette
  liftIO $ endFrame (nano ud)

drawVignette :: Affection UserData ()
drawVignette = do
  ctx <- nano <$> getAffection
  liftIO $ do
    save ctx
    beginPath ctx
    grad <- boxGradient ctx 200 150 400 300 0 500 (rgba 0 0 0 0) (rgba 0 0 0 255)
    rect ctx 0 0 800 600
    fillPaint ctx grad
    fill ctx
    restore ctx

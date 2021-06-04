{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

-- Inspired by https://github.com/altercation/dotfiles-tilingwm
import Prelude hiding (log)

import Control.Monad ((<=<))
import Control.Monad.State (gets)
import qualified Data.Map as M
import Data.Monoid (All)
import Graphics.X11.ExtraTypes.XF86 (
    xF86XK_AudioLowerVolume,
    xF86XK_AudioMute,
    xF86XK_AudioRaiseVolume,
    xF86XK_MonBrightnessDown,
    xF86XK_MonBrightnessUp,
 )
import System.IO (Handle)
import XMonad (
    KeyMask,
    KeySym,
    ManageHook,
    Resize (..),
    ScreenId (..),
    Window,
    XConfig (..),
    XState (..),
    appName,
    controlMask,
    def,
    doFloat,
    float,
    mod4Mask,
    sendMessage,
    shiftMask,
    spawn,
    title,
    windows,
    withFocused,
    xK_Down,
    xK_Escape,
    xK_Left,
    xK_Page_Down,
    xK_Page_Up,
    xK_Right,
    xK_Up,
    xK_a,
    xK_f,
    xK_h,
    xK_j,
    xK_k,
    xK_l,
    xK_m,
    xK_n,
    xK_p,
    xK_s,
    xK_t,
    xK_u,
    xK_w,
    xmonad,
    (.|.),
    (<+>),
    (=?),
    (|||),
 )
import XMonad.Actions.CopyWindow (copyToAll, killAllOtherCopies)
import XMonad.Actions.Submap (submap)
import XMonad.Config.Azerty (azertyKeys)
import XMonad.Config.Prime (Event, X)
import XMonad.Hooks.DynamicBars (dynStatusBarEventHook, dynStatusBarStartup, multiPP)
import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Hooks.ManageDocks (avoidStruts, docks)
import XMonad.Hooks.ManageHelpers (composeOne, doCenterFloat, doFullFloat, (-?>))
import XMonad.Layout.Decoration (Theme (..), shrinkText)
import XMonad.Layout.Gaps (gaps)
import XMonad.Layout.NoFrillsDecoration (noFrillsDeco)
import XMonad.Layout.Renamed (Rename (..), renamed)
import XMonad.Layout.ResizableTile (
    MirrorResize (..),
    ResizableTall (..),
 )
import XMonad.Layout.Simplest (Simplest (..))
import XMonad.Layout.Spacing (Border (..), spacingRaw)
import XMonad.Layout.SubLayouts (GroupMsg (..), pullGroup, subLayout)
import XMonad.Layout.Tabbed (addTabs, tabbed)
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeColMid))
import XMonad.Layout.WindowNavigation (
    Direction2D (..),
    Navigate (..),
    windowNavigation,
 )
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad (
    NamedScratchpad (..),
    namedScratchpadAction,
    namedScratchpadManageHook,
 )
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce (spawnOnce)

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "picom"

    -- from xss-lock man page
    spawnOnce "xset s 180"
    spawnOnce "xss-lock -- i3lock -n -f -c 000000"

    spawnOnce "xsetroot -solid black -cursor_name left_ptr"
    spawnOnce "hsetroot -solid '#000000'"
    spawnOnce
        "setxkbmap -layout fr,fr -variant nodeadkeys, \
        \-option caps:escape,grp:ctrls_toggle"

    spawnOnce "dunst"
    spawnOnce "nm-applet"
    spawnOnce "pasystray"
    -- Location: Dol-de-Bretagne
    -- geoclue2 doesn't work with redshift on nixos right now
    spawnOnce "redshift-gtk -l 48.5417602:-1.742104"
    spawnOnce "udiskie -s"

    dynStatusBarStartup barStartup barCleanup

myHandleEventHook :: Event -> X All
myHandleEventHook =
    fullscreenEventHook
        <+> dynStatusBarEventHook barStartup barCleanup

myLayout =
    avoidStruts . windowNavigation . withTopBar $
        myTabbed ||| myResizableTall ||| myThreeColMid
  where
    myTabbed = withName "Tabs" . withScreenGaps $ tabbed shrinkText tabBar
    myResizableTall =
        withName "Tall" . withTabs . withSpaces $
            ResizableTall 1 (3 / 100) (1 / 2) []
    myThreeColMid =
        withName "ThreeCol" . withTabs . withSpaces $
            ThreeColMid 1 (3 / 100) (1 / 2)

    withName x = renamed [Replace x]
    withTopBar = renamed [CutWordsLeft 1] . noFrillsDeco shrinkText topBar
    withTabs x = addTabs shrinkText tabBar $ subLayout [] Simplest x
    withSpaces = spacingRaw False (Border 5 0 0 0) True (Border 5 5 5 5) True
    withScreenGaps = gaps [(U, 10), (L, 5), (R, 5)]

    myActiveColor = "#4c7899"
    myInactiveColor = "#333333"

    -- The top bar to show the current window
    topBar =
        tabBar
            { activeTextColor = myActiveColor
            , inactiveTextColor = myInactiveColor
            , decoHeight = 12
            }

    -- The tab bar
    tabBar =
        def
            { activeColor = myActiveColor
            , inactiveColor = myInactiveColor
            , activeBorderColor = myActiveColor
            , inactiveBorderColor = myInactiveColor
            , -- TODO are they found
              fontName = "xft:Cantarell:bold:size=10"
            , decoHeight = 25
            }

barStartup :: ScreenId -> IO Handle
barStartup (S s) = do
    putStrLn $ polybar s
    spawnPipe $ polybar s
  where
    polybar n =
        "~/.config/polybar/polybar-start-monitor.sh $(" <> monitor (n + 1) <> ")"
    monitor n =
        "mons | grep enabled | awk '{ print$2 }' | sed -n " <> show n <> "p"

barCleanup :: IO ()
barCleanup = do
    spawn "pkill polybar"

myKeys :: XConfig l -> M.Map (KeyMask, KeySym) (X ())
myKeys XConfig{XMonad.modMask = modm} =
    M.fromList
        -- Actions
        [ ((modm, xK_p), spawn "rofi -show drun -show-icons")
        , ((modm, xK_Escape), spawn "xset s activate")
        , -- Multimedia keys
          ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
        , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
        , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
        , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
        , ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl set 5%-")
        , ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl set 5%+")
        , -- Scratchpad

            ( (modm, xK_s)
            , submap . M.fromList $
                [ ((0, xK_t), namedScratchpadAction scratchpads "term")
                , ((0, xK_p), namedScratchpadAction scratchpads "personal")
                , ((0, xK_l), namedScratchpadAction scratchpads "log")
                , ((0, xK_n), namedScratchpadAction scratchpads "notes")
                , ((0, xK_w), namedScratchpadAction scratchpads "work")
                ]
            )
        , -- Sticky floating window
          ((modm, xK_a), withFocused toggleStick)
        , ((modm, xK_f), withFocused toggleFloat)
        , -- Directional navigation of windows
          ((modm, xK_l), sendMessage $ Go R)
        , ((modm, xK_h), sendMessage $ Go L)
        , ((modm, xK_k), sendMessage $ Go U)
        , ((modm, xK_j), sendMessage $ Go D)
        , ((modm, xK_Page_Up), windows W.focusUp)
        , ((modm, xK_Page_Down), windows W.focusDown)
        , -- Swap adjacent windows
          ((modm .|. shiftMask, xK_l), sendMessage $ Swap R)
        , ((modm .|. shiftMask, xK_h), sendMessage $ Swap L)
        , ((modm .|. shiftMask, xK_k), sendMessage $ Swap U)
        , ((modm .|. shiftMask, xK_j), sendMessage $ Swap D)
        , ((modm .|. shiftMask, xK_Page_Up), windows W.swapUp)
        , ((modm .|. shiftMask, xK_Page_Down), windows W.swapDown)
        , -- Resize
          ((modm, xK_Down), sendMessage MirrorShrink)
        , ((modm, xK_Up), sendMessage MirrorExpand)
        , ((modm, xK_Left), sendMessage Shrink)
        , ((modm, xK_Right), sendMessage Expand)
        , -- Sublayouts
          ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
        , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
        , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
        , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
        , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
        , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
        ]
  where
    toggleFloat = ifFloating sink float
    toggleStick = ifFloating unstick stick

    isFloating :: Window -> X Bool
    isFloating w = gets $ M.member w . W.floating . windowset

    ifFloating :: (Window -> X ()) -> (Window -> X ()) -> Window -> X ()
    ifFloating a1 a2 w =
        isFloating w >>= \case
            True -> a1 w
            False -> a2 w

    sink = windows . W.sink

    stick = const (windows copyToAll) <=< float
    unstick = const killAllOtherCopies <=< sink

myTerminal :: String
myTerminal = "alacritty"

myManageHook :: ManageHook
myManageHook =
    namedScratchpadManageHook scratchpads
        <+> composeOne [appName =? "gnome-calculator" -?> doFloat]

scratchpads :: [NamedScratchpad]
scratchpads =
    [ NS "log" log isLog doFullFloat
    , NS "notes" notes isNotes doFullFloat
    , NS "personal" personalTrello isPersonalTrello doFullFloat
    , NS "term" myTerminalWithTitle isTerminal doCenterFloat
    , NS "work" workTrello isWorkTrello doFullFloat
    ]
  where
    personalTrello = "google-chrome-stable --app=https://trello.com/b/0ElFr1SJ/personnel"
    isPersonalTrello = appName =? "trello.com__b_0ElFr1SJ_personnel"
    workTrello = "google-chrome-stable --app=https://trello.com/b/yMm4ZBZq/boulot"
    isWorkTrello = appName =? "trello.com__b_yMm4ZBZq_boulot"
    log = "google-chrome-stable --app=https://docs.google.com/document/d/1Hhk9JohRr2pkNTXSZGY0JKGJ_AJ5SQyauB4HA-iohmM"
    isLog = appName =? "docs.google.com__document_d_1Hhk9JohRr2pkNTXSZGY0JKGJ_AJ5SQyauB4HA-iohmM"
    notes = "google-chrome-stable --app=https://checkvist.com/checklists/792404"
    isNotes = appName =? "checkvist.com__checklists_792404"
    myTerminalTitle = "term-scratchpad"
    myTerminalWithTitle = myTerminal <> " --title " <> myTerminalTitle
    isTerminal = title =? myTerminalTitle

main :: IO ()
main = do
    xmonad . ewmh . docks $
        def
            { borderWidth = 0
            , handleEventHook = myHandleEventHook
            , keys = azertyKeys <+> myKeys <+> keys def
            , layoutHook = myLayout
            , logHook = multiPP def def
            , manageHook = myManageHook
            , modMask = mod4Mask
            , startupHook = myStartupHook
            , terminal = myTerminal
            }

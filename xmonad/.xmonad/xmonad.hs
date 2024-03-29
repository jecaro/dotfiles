{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}

-- Inspired by https://github.com/altercation/dotfiles-tilingwm

import Control.Monad ((<=<))
import Control.Monad.State (gets)
import Data.List (stripPrefix)
import qualified Data.Map as M
import Data.Maybe (catMaybes)
import Graphics.X11.ExtraTypes.XF86 (
    xF86XK_AudioForward,
    xF86XK_AudioLowerVolume,
    xF86XK_AudioMicMute,
    xF86XK_AudioMute,
    xF86XK_AudioNext,
    xF86XK_AudioPlay,
    xF86XK_AudioPrev,
    xF86XK_AudioRaiseVolume,
    xF86XK_AudioRewind,
    xF86XK_Display,
    xF86XK_MonBrightnessDown,
    xF86XK_MonBrightnessUp,
 )
import System.Exit (exitSuccess)
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
    io,
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
    xK_q,
    xK_r,
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
import XMonad.Actions.WorkspaceNames (renameWorkspace, setWorkspaceName)
import XMonad.Config.Azerty (azertyKeys)
import XMonad.Config.Prime (X)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageHelpers (composeOne, doCenterFloat, doRectFloat, (-?>))
import XMonad.Hooks.Place (inBounds, placeHook, underMouse, withGaps)
import XMonad.Hooks.StatusBar (StatusBarConfig, dynamicEasySBs, statusBarProp)
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
import XMonad.Layout.WindowNavigation (
    Direction2D (..),
    Navigate (..),
    windowNavigation,
 )
import XMonad.Prompt (XPConfig (..), XPPosition (..))
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad (
    NamedScratchpad (NS),
    namedScratchpadAction,
    namedScratchpadManageHook,
 )
import XMonad.Util.SpawnOnce (spawnOnce)
import Prelude hiding (log)

myStartupHook :: X ()
myStartupHook = do
    -- Workspace name configuration
    setWorkspaceName "1" "www"
    setWorkspaceName "2" "work"

    -- X setup

    -- The compositor
    spawnOnce "picom"

    -- Screensaver and locker
    spawnOnce "xset s 180"
    spawnOnce "xss-lock -- i3lock -n -f -c 000000"

    spawnOnce "xsetroot -solid black -cursor_name left_ptr"
    spawnOnce "hsetroot -solid '#000000'"

    -- Keyboard handling
    spawnOnce "~/bin/setup-keyboard.sh"
    spawnOnce "inputplug -c ~/bin/on-new-kbd.sh"

    -- Monitor handling
    spawnOnce "mons -a"

    -- Player daemon. Make the multimedia keys work on the media player with the
    -- most recent activity
    spawnOnce "playerctld"

    -- Systray
    spawnOnce "dunst"
    spawnOnce "nm-applet"
    spawnOnce "pasystray"
    -- Location: Dol-de-Bretagne
    -- geoclue2 doesn't work with redshift on nixos right now
    spawnOnce "redshift-gtk -l 48.5417602:-1.742104"
    spawnOnce "udiskie -s"

myActiveColor :: String
myActiveColor = "#4c7899"

myInactiveColor :: String
myInactiveColor = "#333333"

myForegroundColor :: String
myForegroundColor = "#eeeeee"

myBoldFont :: String
myBoldFont = "xft:Cantarell:bold:size=10"

myRegularFont :: String
myRegularFont = "xft:Cantarell:regular:size=10"

myLayout = windowNavigation . withTopBar $ myTabbed ||| myResizableTall
  where
    myTabbed = withName "Tabs" . withScreenGaps $ tabbed shrinkText tabBar
    myResizableTall =
        withName "Tall" . withTabs . withSpaces $
            ResizableTall 1 (3 / 100) (1 / 2) []

    withName x = renamed [Replace x]
    withTopBar = renamed [CutWordsLeft 1] . noFrillsDeco shrinkText topBar
    withTabs x = addTabs shrinkText tabBar $ subLayout [] Simplest x
    withSpaces = spacingRaw False (Border 5 0 0 0) True (Border 5 5 5 5) True
    withScreenGaps = gaps [(U, 10), (L, 5), (R, 5)]

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
            , fontName = myBoldFont
            , decoHeight = 25
            }

barSpawner :: ScreenId -> IO StatusBarConfig
barSpawner (S s) = pure $ statusBarProp (polybar s) (pure def)
  where
    polybar n =
        withVar "MONITOR" (monitor $ n + 1)
            <> " "
            <> withVar "BACKLIGHT_CARD" backlightCard
            <> " "
            <> "polybar top"
    withVar name cmd = name <> "=$(" <> cmd <> ")"
    backlightCard = "ls -1 /sys/class/backlight/"
    monitor n =
        "mons | grep enabled | awk '{ print$2 }' | sed -n " <> show n <> "p"

myKeys :: XConfig l -> M.Map (KeyMask, KeySym) (X ())
myKeys XConfig{XMonad.modMask = modm} =
    M.fromList
        -- Actions
        [ ((modm, xK_p), spawn "rofi -show drun -show-icons")
        , ((modm, xK_Escape), spawn "xset s activate")
        , -- Multimedia keys
          ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
        , ((0, xF86XK_AudioForward), spawn "playerctl position 5+")
        , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
        , ((0, xF86XK_AudioMicMute), spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
        , ((0, xF86XK_AudioNext), spawn "playerctl next")
        , ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
        , ((0, xF86XK_AudioPrev), spawn "playerctl previous")
        , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
        , ((0, xF86XK_AudioRewind), spawn "playerctl position 5-")
        , ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl set 5%-")
        , ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl set 5%+")
        , ((0, xF86XK_Display), spawn "mons -n right")
        , ((shiftMask, xF86XK_Display), spawn "mons -n left")
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
        , -- Rename workspace
          ((modm .|. shiftMask, xK_r), renameWorkspace myXPConfig)
        , -- Quit xmonad
          ((modm .|. shiftMask, xK_q), exitXMonad)
        ]
  where
    -- mons and redshift are respawned when logout/login. All other startup
    -- processes are either killed with xmonad or allow only one instance
    -- running (playerctld).
    exitXMonad = do
        spawn "pkill mons"
        spawn "pkill redshift"
        io exitSuccess

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

    myXPConfig =
        def
            { font = myRegularFont
            , bgColor = myInactiveColor
            , fgColor = myForegroundColor
            , position = Top
            , promptBorderWidth = 0
            , height = 30
            }

myTerminal :: String
myTerminal = "alacritty"

myManageHook :: ManageHook
myManageHook =
    namedScratchpadManageHook scratchpads
        <+> placeHook (inBounds (withGaps (5, 5, 5, 5) $ underMouse (0, 0)))
        <+> composeOne [appName =? "gnome-calculator" -?> doFloat]

urlToAppName :: String -> Maybe String
urlToAppName x = fmap slashToUnderscore . withTwoFstSlash <$> withoutHttps x
  where
    withoutHttps = stripPrefix "https://"
    addSlashIn = uncurry $ (<>) . (<> "/")
    withTwoFstSlash = addSlashIn . break (== '/')
    slashToUnderscore '/' = '_'
    slashToUnderscore c = c

chromeNS :: [Char] -> [Char] -> Maybe NamedScratchpad
chromeNS name url = mkNS <$> identifyApp
  where
    mkNS = flip (NS name chrome) $ doRectFloat verticalCenterRect
    verticalCenterRect = W.RationalRect (1 / 4) 0 (1 / 2) 1
    chrome = "google-chrome-stable --app=" <> url
    identifyApp = (appName =?) <$> urlToAppName url

scratchpads :: [NamedScratchpad]
scratchpads =
    NS "term" myTerminalWithTitle isTerminal doCenterFloat :
    catMaybes
        [ chromeNS
            "log"
            "https://docs.google.com/document/d/1Hhk9JohRr2pkNTXSZGY0JKGJ_AJ5SQyauB4HA-iohmM"
        , chromeNS
            "notes"
            "https://checkvist.com/checklists/792404"
        , chromeNS
            "personal"
            "https://trello.com/b/0ElFr1SJ/personnel"
        , chromeNS
            "work"
            "https://trello.com/b/yMm4ZBZq/boulot"
        ]
  where
    myTerminalTitle = "term-scratchpad"
    myTerminalWithTitle = myTerminal <> " --title " <> myTerminalTitle
    isTerminal = title =? myTerminalTitle

main :: IO ()
main =
    xmonad . ewmhFullscreen . ewmh . dynamicEasySBs barSpawner $
        def
            { borderWidth = 0
            , keys = myKeys <+> azertyKeys <+> keys def
            , layoutHook = myLayout
            , manageHook = myManageHook
            , modMask = mod4Mask
            , startupHook = myStartupHook
            , terminal = myTerminal
            }

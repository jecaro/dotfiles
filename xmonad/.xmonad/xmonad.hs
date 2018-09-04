import XMonad
import XMonad.Actions.CycleWS
import XMonad.Config.Azerty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86  
import System.IO
import XMonad.StackSet as W (focusUp, focusDown, sink)

myManageHook = composeAll
    [ (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> unfloat
    , className =? "Vncviewer" --> doFloat
    , isFullscreen --> doFullFloat
    ]
    where unfloat = ask >>= doF . W.sink
          role = stringProperty "WM_WINDOW_ROLE"

myTerminal = "urxvt +sb -fg white -bg black -fade 15 -fadecolor black"

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ azertyConfig
        { manageHook = manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
                        <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  smartBorders $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
	, terminal = myTerminal
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 3%-") -- decrease volume  
        , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 3%+") -- increase volume  
        , ((mod4Mask, xK_F4), kill) -- close window

	, ((mod4Mask,               xK_Right), nextWS)
	, ((mod4Mask,               xK_Left),  prevWS)
	, ((mod4Mask .|. shiftMask, xK_Right), shiftToNext >> nextWS)
	, ((mod4Mask .|. shiftMask, xK_Left),  shiftToPrev >> prevWS)
	, ((mod4Mask,               xK_z),     toggleWS)

        ]

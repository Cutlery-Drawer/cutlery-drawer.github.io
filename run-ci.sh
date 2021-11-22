#!/bin/sh
set -e

p(){
	echo "::group::$1 -> $2"
	echo "[command]defaults read-type $1 $2"
	defaults 2>&1 read-type "$1" "$2" || :
	echo "[command]defaults read $1 $2"
	defaults 2>&1 read "$1" "$2" || :
	sleep 0.5 2>&1 || :
	echo "::endgroup::$1 -> $2"
}

p com.apple.finder          DisableAllAnimations
p com.apple.finder          FavoriteTagNames
p com.apple.finder          FXEnableExtensionChangeWarning
p com.apple.finder          NewWindowTarget
p com.apple.finder          NewWindowTargetPath
p com.apple.finder          NSAutomaticCapitalizationEnabled
p com.apple.finder          NSAutomaticDashSubstitutionEnabled
p com.apple.finder          NSAutomaticPeriodSubstitutionEnabled
p com.apple.finder          NSAutomaticQuoteSubstitutionEnabled
p com.apple.finder          NSAutomaticSpellingCorrectionEnabled
p com.apple.finder          NSAutomaticTextCompletionEnabled
p com.apple.finder          QuitMenuItem
p com.apple.finder          ShowExternalHardDrivesOnDesktop
p com.apple.finder          ShowHardDrivesOnDesktop
p com.apple.finder          ShowMountedServersOnDesktop
p com.apple.finder          ShowRecentTags
p com.apple.finder          ShowRemovableMediaOnDesktop
p com.apple.universalaccess closeViewScrollWheelModifiersInt
p com.apple.universalaccess closeViewScrollWheelToggle
p com.apple.universalaccess closeViewZoomFollowsFocus
p com.apple.universalaccess reduceMotion
p com.apple.touchbar.agent  PresentationModeFnModes
p com.apple.touchbar.agent  PresentationModeGlobal
p com.apple.touchbar.agent  PresentationModePerApp

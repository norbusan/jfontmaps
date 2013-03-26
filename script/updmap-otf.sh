#!/bin/sh
# updmap-otf: v0.9.1
#
# Copyright 2004-2006 by KOBAYASHI R. Taizo
# Copyright 2011-2012 by PREINING Norbert
#
# WARNING: This file is NOT developed any more. TeX Live uses a version
#          rewritten in perl called updmap-setup-kanji, which is located
#          and developed in the same place as this file.
# 
# For development see
#  http://www.tug.org/svn/texlive/trunk/Build/source/extra/jfontmaps/
#
# This file is licensed under GPL version 3 or any later version.
# For copyright statements see end of file.
#
# 27 Jan 2012 by PREINING Norbert <preining@logic.at>  v0.9.2
#    support IPA and IPAex fonts
#    improve and extended documentation
# 11 Nov 2011 by PREINING Norbert <preining@logic.at>  v0.9.1
#    use kpsewhich for finding fonts
#    use updmap-sys --setoption kanjiEmbed to select the font family
#    use current names of map files
#    use different font name for Kozuka font, as used in the map file
#    get state from updmap.cfg, not from some state file
# 27 May 2006 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.9
#    use noEmbed.map instead of noEmbeddedFont.map
# 10 Jun 2005 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.8
#    modified to use updmap-sys in teTeX3
# 07 Nov 2004 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.7
#    do not echo back the message of updmap.
# 17 Oct 2004 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.6
#    set hiragino map file if nofont is installed and arg is auto.
# 04 Oct 2004 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.5
#    handl standby map files more strictly
# 20 Sep 2004 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.4
#    hand over current status to map file installer
# 19 Sep 2004 by KOBAYASHI R. Taizo <tkoba965@mac.com> v0.3
#    handl *-udvips.map in TEXMF/dvipdfm/config/otf/
# 02 Mar 2004 by KOBAYASHI R. Taizo <tkoba@ike-dyn.ritsumei.ac.jp> v0.2
#    added noFont-udvips.map
# 28 Feb 2004 by KOBAYASHI R. Taizo <tkoba@ike-dyn.ritsumei.ac.jp> v0.1


###
### Usage
###

Usage() {
cat <<EOF
  updmap-otf     Front end to updmap.cfg configuration for Japanese fonts
                 as used in the otf package.

                 This script searches for some of the most common fonts
                 for embedding into pdfs by dvipdfmx.

  Usage:  updmap-otf {<fontname>|auto|nofont|status}

     <fontname>  set fonts as defined by the map file otf-<fontname>.map
                 if it exists.
     auto:       sets one of the following supported font families
                 automatically:
                   hiragino, morisawa, kozuka, ipaex, ipa
     nofont:     set no fonts are embedded
                 If your system does not have any of the supported font 
                 families as specified above, this target is selected 
                 automatically.
     status:     get information about current environment and usable font map

EOF
}

#
# representatives of support font families
#
hiragino_font=HiraMinPro-W3.otf
morisawa_font=A-OTF-RyuminPro-Light.otf
kozuka_font=KozMinPro-Regular.otf
ipa_font=ipam.ttf
ipaex_font=ipaexm.ttf


###
### Check Installed Font
###

CheckInstallFont() {
  if kpsewhich $hiragino_font >/dev/null ; then
    HIRAGINO=installed
  else
    HIRAGINO=""
  fi
    
  if kpsewhich $morisawa_font >/dev/null ; then
    MORISAWA=installed
  else
    MORISAWA=""
  fi

  if kpsewhich $kozuka_font >/dev/null ; then
    KOZUKA=installed
  else
    KOZUKA=""
  fi

  if kpsewhich $ipa_font >/dev/null ; then
    IPA=installed
  else
    IPA=""
  fi

  if kpsewhich $ipaex_font >/dev/null ; then
    IPAEX=installed
  else
    IPAEX=""
  fi

  
}

###
### GetStatus
###

GetStatus() {

STATUS=$(grep ^kanjiEmbed $(kpsewhich updmap.cfg) | awk '{print$2}')

if kpsewhich otf-$STATUS.map >/dev/null ; then
    echo "CURRENT map file : otf-$STATUS.map"
else
    echo "WARNING: Currently selected map file cannot be found: otf-$STATUS.map"
fi
  

for MAPFILE in otf-hiragino.map otf-morisawa.map otf-kozuka.map otf-ipaex.map otf-ipa.map
do
    if [ "$MAPFILE" = "otf-$STATUS.map" ] ; then
        continue
    fi
    mffound=`kpsewhich $MAPFILE`
    if [ -n "$mffound" ] ; then
	case "$MAPFILE" in
	    otf-hiragino.map)
		if [ "$HIRAGINO" = "installed" ]; then
			echo "Standby map file : $MAPFILE"
		fi
		;;
	    otf-morisawa.map)
		if [ "$MORISAWA" = "installed" ]; then
			echo "Standby map file : $MAPFILE"
		fi
		;;
	    otf-kozuka.map)
		if [ "$KOZUKA" = "installed" ]; then
			echo "Standby map file : $MAPFILE"
		fi
		;;
	    otf-ipa.map)
		if [ "$IPA" = "installed" ]; then
			echo "Standby map file : $MAPFILE"
		fi
		;;
	    otf-ipaex.map)
		if [ "$IPAEX" = "installed" ]; then
			echo "Standby map file : $MAPFILE"
		fi
		;;
	    *)
		echo "Should not happen!"
		;;
	esac
    fi
done

}

###
### Setup Map files
###

SetupMapFile() {

MAPFILE=otf-$1.map

if kpsewhich $MAPFILE >/dev/null ; then
    echo "Setting up ... $MAPFILE"
    updmap-sys -setoption kanjiEmbed $1
    updmap-sys
else
    echo "NOT EXIST $MAPFILE"
    return 1
fi
}

###
### MAIN
###

main() {

# mktexlsr 2> /dev/null

CheckInstallFont

if [ $# != 1 ] ; then
    eval Usage ${0##*/}
    return -1
fi

case "$1" in
     hiragino)
	if [ "$HIRAGINO" = "installed" ]; then
	    SetupMapFile hiragino
	else
	    main auto
	fi
	;;
     morisawa)
	if [ "$MORISAWA" = "installed" ]; then
	    SetupMapFile morisawa
	else
	    main auto
	fi
	;;
     kozuka)
	if [ "$KOZUKA" = "installed" ]; then
	    SetupMapFile kozuka
	else
	    main auto
	fi
	;;
     ipa)
	if [ "$IPA" = "installed" ]; then
	    SetupMapFile ipa
	else
	    main auto
	fi
	;;
     ipaex)
	if [ "$IPAEX" = "installed" ]; then
	    SetupMapFile ipaex
	else
	    main auto
	fi
	;;
     nofont)
	SetupMapFile noEmbed
	;;
     auto)
	GetStatus
	# first check if we have a status set and the font is installed
	# in this case don't change anything, just make sure
	if [ "$STATUS" = "morisawa" ] && [ "$MORISAWA" = "installed" ]; then
	    SetupMapFile morisawa
	elif [ "$STATUS" = "kozuka" ] && [ "$KOZUKA" = "installed" ]; then
	    SetupMapFile kozuka
	elif [ "$STATUS" = "hiragino" ] && [ "$HIRAGINO" = "installed" ]; then
	    SetupMapFile hiragino
	elif [ "$STATUS" = "ipaex" ] && [ "$IPAEX" = "installed" ]; then
	    SetupMapFile ipaex
	elif [ "$STATUS" = "ipa" ] && [ "$IPA" = "installed" ]; then
	    SetupMapFile ipa
	else
		if [ "$STATUS" = "noEmbed" ] || [ "$STATUS" = "" ]; then
			: do nothing here, we dont have to warn
		else
			# some unknown setting is set up currently, overwrite
			# but warn
			echo "Previous setting $STATUS is unknown, replacing it!"
		fi
		# if we are in the noEmbed or nothing set case, but one
		# of the three fonts hiragino/morisawa/kozuka are present
		# then use them
		if [ "$HIRAGINO" = "installed" ]; then
			SetupMapFile hiragino
		elif [ "$MORISAWA" = "installed" ]; then
			SetupMapFile morisawa
		elif [ "$KOZUKA" = "installed" ]; then
			SetupMapFile kozuka
		elif [ "$IPAEX" = "installed" ]; then
			SetupMapFile ipaex
		elif [ "$IPA" = "installed" ]; then
			SetupMapFile ipa
		else
			SetupMapFile noEmbed
		fi
	fi
	;;
     status)
	GetStatus
	return 0
	;;
     *)
	SetupMapFile $1
	;;
esac
}

main $@

#
#
# Copyright statements:
#
# KOBAYASHI Taizo
# email to preining@logic.at
# Message-Id: <20120130.162953.59640143170594580.tkoba@cc.kyushu-u.ac.jp>
# Message-Id: <20120201.105639.625859878546968959.tkoba@cc.kyushu-u.ac.jp>
# --------------------------------------------------------
# copyright statement は簡単に以下で結構です。
#
#        Copyright 2004-2006 by KOBAYASHI Taizo
#
# では
#        GPL version 3 or any later version
#
# --------------------------------------------------------
#
# PREINING Norbert
# as author and maintainer of the current file
# Licensed under GPL version 3 or any later version
#

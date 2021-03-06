#!/bin/bash

echo 'cocos2d-iphone template installer'

COCOS2D_VER='cocos2d 0.99.5'
BASE_TEMPLATE_DIR="/Library/Application Support/Developer/Shared/Xcode"
BASE_TEMPLATE_USER_DIR="$HOME/Library/Application Support/Developer/Shared/Xcode"

force=
user_dir=

usage(){
cat << EOF
usage: $0 [options]
 
Install / update templates for ${COCOS2D_VER}
 
OPTIONS:
   -f	force overwrite if directories exist
   -h	this help
   -u	install in user's Library directory instead of global directory
EOF
}

while getopts "fhu" OPTION; do
	case "$OPTION" in
		f)
			force=1
			;;
		h)
			usage
			exit 0
			;;
		u)
			user_dir=1
			;;
	esac
done

# Make sure only root can run our script
if [[ ! $user_dir  && "$(id -u)" != "0" ]]; then
	echo ""
	echo "Error: This script must be run as root in order to copy templates to ${BASE_TEMPLATE_DIR}" 1>&2
	echo ""
	echo "Try running it with 'sudo', or with '-u' to install it only you:" 1>&2
	echo "   sudo $0" 1>&2
	echo "or:" 1>&2
	echo "   $0 -u" 1>&2   
exit 1
fi


copy_files(){
	rsync -r --exclude=.svn "$1" "$2"
}

check_dst_dir(){
	if [[ -d $DST_DIR ]];  then
		if [[ $force ]]; then
			echo "removing old libraries: ${DST_DIR}"
			rm -rf $DST_DIR
		else
			echo "templates already installed. To force a re-install use the '-f' parameter"
			exit 1
		fi
	fi
	
	echo ...creating destination directory: $DST_DIR
	mkdir -p "$DST_DIR"
}

copy_base_mac_files(){
	echo ...copying cocos2d files
	copy_files cocos2d "$LIBS_DIR"

	echo ...copying CocosDenshion files
	copy_files CocosDenshion "$LIBS_DIR"
}

copy_base_files(){
	echo ...copying cocos2d files
	copy_files cocos2d "$LIBS_DIR"

	echo ...copying cocos2d dependency files
	copy_files external/FontLabel "$LIBS_DIR"

	echo ...copying CocosDenshion files
	copy_files CocosDenshion/CocosDenshion "$LIBS_DIR"

	echo ...copying cocoslive files
	copy_files cocoslive "$LIBS_DIR"

	echo ...copying cocoslive dependency files
	copy_files external/TouchJSON "$LIBS_DIR"
}

print_template_banner(){
	echo ''
	echo ''
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
	echo ''
}

# copies project-based templates
copy_project_templates(){
		if [[ $user_dir ]]; then
		TEMPLATE_DIR="${BASE_TEMPLATE_USER_DIR}/Project Templates/${COCOS2D_VER}/"
	else
		TEMPLATE_DIR="${BASE_TEMPLATE_DIR}/Project Templates/${COCOS2D_VER}/"
	fi

	if [[ ! -d "$TEMPLATE_DIR" ]]; then
		echo '...creating cocos2d template directory'
		echo ''
		mkdir -p "$TEMPLATE_DIR"
	fi

	print_template_banner "Installing cocos2d iOS template"

	DST_DIR="$TEMPLATE_DIR""cocos2d Application/"
	LIBS_DIR="$DST_DIR"libs

	check_dst_dir

	echo ...copying template files
	copy_files templates/cocos2d_app/ "$DST_DIR"

	copy_base_files

	echo done!

	print_template_banner "Installing cocos2d iOS + box2d template"

	DST_DIR="$TEMPLATE_DIR""cocos2d Box2d Application/"
	LIBS_DIR="$DST_DIR"libs

	check_dst_dir

	echo ...copying template files
	copy_files templates/cocos2d_box2d_app/ "$DST_DIR"

	copy_base_files

	echo ...copying Box2D files
	copy_files external/Box2d/Box2D "$LIBS_DIR"

	echo done!


	print_template_banner "Installing cocos2d iOS + chipmunk template"

	DST_DIR="$TEMPLATE_DIR""cocos2d Chipmunk Application/"
	LIBS_DIR="$DST_DIR"libs

	check_dst_dir

	echo ...copying template files
	copy_files templates/cocos2d_chipmunk_app/ "$DST_DIR"

	copy_base_files

	echo ...copying Chipmunk files
	copy_files external/Chipmunk "$LIBS_DIR"

	echo done!

	print_template_banner "Installing cocos2d Mac template"

	DST_DIR="$TEMPLATE_DIR""cocos2d Application - Mac/"
	LIBS_DIR="$DST_DIR"libs

	check_dst_dir

	echo ...copying template files
	copy_files templates/cocos2d_mac/ "$DST_DIR"

	copy_base_mac_files

	echo done!
}

copy_file_templates(){
	if [[ $user_dir ]]; then
		TEMPLATE_DIR="${BASE_TEMPLATE_USER_DIR}/File Templates/${COCOS2D_VER}/"
	else
		TEMPLATE_DIR="${BASE_TEMPLATE_DIR}/File Templates/${COCOS2D_VER}/"
	fi
	
	echo ...copying file templates

	DST_DIR="$TEMPLATE_DIR"
	check_dst_dir

	if [[ ! -d "$TEMPLATE_DIR" ]]; then
		echo '...creating cocos2d template directory'
		echo ''
		mkdir -p "$TEMPLATE_DIR"
	fi
	
	print_template_banner "Installing CCNode file templates..."
	
	copy_files "templates/file-templates/CCNode class" "$DST_DIR"
	
	echo done!
}

copy_project_templates

copy_file_templates

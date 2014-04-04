#!/bin/bash

#
# A script to make building various images for the uWARP easier
#

# defines
LOGFILE_NAME="openuwarpbuild.log"
DEFAULT_BASE_DIR_PATH="./"
BASE_DIR_PATH=""

# text colours
NORMAL=`echo "\033[m"`
MENU=`echo "\033[36m"` #Blue
NUMBER=`echo "\033[33m"` #orange
FOREGROUND_RED=`echo "\033[41m"`
RED_TEXT=`echo "\033[31m"`
GREEN_TEXT=`echo "\033[32m"`
ENTER_LINE=`echo "\033[33m"`
WHITE_TEXT=`echo "\033[00m"`
FAIL='\033[01;31m' # bold red
PASS='\033[01;32m' # bold green
RESET='\033[00;00m' # normal white

#############
# Functions
#############

get_run_directory() {
	local SOURCE="${BASH_SOURCE[0]}"
	# resolve SOURCE until file is not a symlink
	while [ -h "$SOURCE" ]; do 
		DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
		SOURCE="$(readlink "$SOURCE")"
		# if SOURCE was a relative symlink, resolve it relative to the path where symlink was located
		[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
	done
	BASE_DIR_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

set_logfile_path() {
	get_run_directory
	if [ -d $BASE_DIR_PATH ]; then
		LOGFILE=$BASE_DIR_PATH/$LOGFILE_NAME
	else
		LOGFILE=$DEFAULT_BASE_DIR_PATH/$LOGFILE_NAME
	fi
}

show_menu_first() {
	echo -e "${MENU}Initial Configuration${RESET}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER} 1)${MENU} Check for Updates   ${NORMAL}- Update the source code."
	echo -e "${MENU}**${NUMBER} 2)${MENU} Choose Build Option ${NORMAL}- Proceed to build option menu."
	echo -e "${MENU}**${NUMBER} 3)${MENU} Quit ${NORMAL}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}q to exit. ${NORMAL}"
	read -n 1 opt1
	echo ""
}

show_menu_second(){
	echo -e "${MENU}Build Options${RESET}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER} 1)${MENU} Default  ${NORMAL}- Basic router functionality."
	echo -e "${MENU}**${NUMBER} 2)${MENU} Custom   ${NORMAL}- Select custom options."
	echo -e "${MENU}**${NUMBER} 3)${MENU} Asterisk ${NORMAL}- Asterisk PBX."
	echo -e "${MENU}**${NUMBER} 4)${MENU} VPN      ${NORMAL}- Virtual Private Network."
	echo -e "${MENU}**${NUMBER} 5)${MENU} Current  ${NORMAL}- Keep current options."
	echo -e "${MENU}**${NUMBER} 6)${MENU} Quit ${NORMAL}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}q to exit. ${NORMAL}"
	read -n 1 opt2
	echo ""
}

show_menu_three() {
	echo -e "${MENU}Board Type${RESET}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER} 1)${MENU} 8MB  ${NORMAL}- Build for Open uWARP with 8MB flash."
	echo -e "${MENU}**${NUMBER} 2)${MENU} 16MB ${NORMAL}- Build for Open uWARP with 16MB flash."
	echo -e "${MENU}**${NUMBER} 3)${MENU} Quit ${NORMAL}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}q to exit. ${NORMAL}"
	read -n 1 opt3
	echo ""
}

show_menu_fourth() {
	echo -e "${MENU}Custom Configuration${RESET}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER} 1)${MENU} Yes ${NORMAL}- Customize build configuration."
	echo -e "${MENU}**${NUMBER} 2)${MENU} No  ${NORMAL}- Proceed to build."
	echo -e "${MENU}**${NUMBER} 3)${MENU} Quit ${NORMAL}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}q to exit. ${NORMAL}"
	read -n 1 opt4
	echo ""
}

show_menu_fifth() {
	echo -e "${MENU}Ready to Build${RESET}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER} 1)${MENU} Yes ${NORMAL}- Start the build"
	echo -e "${MENU}**${NUMBER} 2)${MENU} No  ${NORMAL}- Stop and exit."
	echo -e "${MENU}**${NUMBER} 3)${MENU} Quit ${NORMAL}"
	echo -e "${MENU}**********************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}q to exit. ${NORMAL}"
	read -n 1 opt5
	echo ""
}

function option_picked() {
	local MESSAGE=${@:-"${FAIL}ERROR: No or invalid option picked!${RESET}"}
	local CLEANMESSAGE=${@:-"ERROR: No or invalid option picked!"}
	echo -e "\n${PASS}${MESSAGE}${RESET}\n"
	echo -e "\n$CLEANMESSAGE\n" >> $LOGFILE
}

function say_goodbye() {
	echo -e "\n${PASS}Goodbye!${RESET}\n"
	echo -e "\nGoodbye!\n" >> $LOGFILE
	exit 0
}

function print_error() {
	local MESSAGE=${@:-"${FAIL}ERROR: ${RESET}Unknown"}
	local CLEANMESSAGE=${@:-"ERROR: Unknown"}
	echo -e "\n${FAIL}ERROR: ${RESET}${MESSAGE}"
	echo -e "${FAIL}ERROR: ${RESET}Consult the \"$LOGFILE\" for further details\n"
	echo -e "\nERROR: ${CLEANMESSAGE}\n" >> $LOGFILE
}

function print_success() {
	local MESSAGE=${@:-"${PASS}SUCCESS: ${RESET}Unknown"}
	local CLEANMESSAGE=${@:-"SUCCESS: Unknown"}
	echo -e "\n${PASS}SUCCESS: ${RESET}${MESSAGE}\n"
	echo -e "\nSUCCESS: ${CLEANMESSAGE}\n" >> $LOGFILE
}

#######################
# Main
######################

# set paths and logfile name
set_logfile_path

# put system info header in logfile for debug purposes
echo -e "###########################################################\n" > $LOGFILE
echo -e "Build Start: `date`" >> $LOGFILE
echo -e "Kernel Info: `uname -a`" >> $LOGFILE
for versionfile in `ls /etc/*_version`; do
	echo -e "Version Info: $versionfile"  >> $LOGFILE
	cat $versionfile >> $LOGFILE
done
echo -e "\n###########################################################\n" >> $LOGFILE

# change to source directory and make sure build system is there
CURDIR=`pwd`
cd $BASE_DIR_PATH
if [ ! -d uwarp_configs ]; then 
	cd $CURDIR
	if [ ! -d uwarp_configs ]; then 
		print_error "Cannot find source code."
		exit 1
	fi
fi

#
# give an intro
#
clear
echo -e "${PASS}Welcome${RESET}"
echo -e "This is the simple menu system to create images for the PIKA uWARP embedded device."
echo -e "Additional information on this device can be found at:"
echo -e "        http://www.pikatechnologies.com/english/View.asp?x=1296 \n"
echo -e "To create a custom image for your Open uWARP device, please select your options from"
echo -e "the following menus as appropriate.\n\n\n"

#
# First menu
#
clear
show_menu_first
while [ opt1 != '' ]
	do
	if [ $opt1 = "" ]; then 
		clear;
		option_picked;
		show_menu_first;
	else
		case $opt1 in
		1) 
			option_picked "Checking for updates ..."; 
			echo -e "Updating source code ...\n" | tee -a $LOGFILE;
			git pull 2>>$LOGFILE | tee -a $LOGFILE;
			echo -e "Updating packages ...\n" | tee -a $LOGFILE;
			./scripts/feeds update -a 2>>$LOGFILE | tee -a $LOGFILE;
			./scripts/feeds install -a 2>>$LOGFILE | tee -a $LOGFILE;
			if [ $? -eq 0 ]; then
				print_success "Updated source code."
			else
				print_error "Failed to update source code."
			fi
			break;
			;;

		2) 
			option_picked "Choose build option";
			break;
			;;

		3|q)
			say_goodbye;
			;;

		*)
			clear;
			option_picked "Pick an option from the menu";
			show_menu_first;
			;;
		esac
	fi
done

#
# Second menu
#
sleep 1
clear
show_menu_second
while [ opt2 != '' ]
	do
	if [ $opt2 = "" ]; then 
		clear;
		option_picked;
		show_menu_second;
	else
		case $opt2 in
		1|2) 
			option_picked "Using default image.";
			cp uwarp_configs/default .config;
			if [ $? -eq 0 ]; then
				print_success "Default image set."
				if [ $opt2 -eq 2 ]; then
					option_picked "Custom configuration ...\nStarting menu ...";
					echo -e "\nStarting custom configuration ...\n" >> $LOGFILE
					make menuconfig
				fi
			else
				print_error "Failed to set up default image."
			fi
			break;
			;;

		3) 
			option_picked "Using Asterisk image.";
			cp uwarp_configs/asterisk .config;
			if [ $? -eq 0 ]; then
				print_success "Asterisk image set."
			else
				print_error "Failed to set up Asterisk image."
			fi
			break;
			;;

		4) 
			option_picked "Using VPN image.";
			cp uwarp_configs/vpn .config;
			if [ $? -eq 0 ]; then
				print_success "VPN image set."
			else
				print_error "Failed to set up VPN image."
			fi
			break;
			;;

		5) 
			option_picked "Keeping Current selections.";
			break;
			;;

		6|q)
			say_goodbye;
			;;

		*)
			clear;
			option_picked "Pick an option from the menu";
			show_menu_second;
			;;
		esac
	fi
done

#
# Third menu
#
# don't select board if custom config ran in menu 2
if [ $opt2 -ne 2 ]; then
sleep 1
clear
show_menu_three
while [ opt3 != '' ]
	do
	if [ $opt3 = "" ]; then 
		clear;
		option_picked;
		show_menu_three;
	else
		case $opt3 in
		1) 
			option_picked "Building for Open uWARP with 8MB flash ...";
			echo -e "\nBuilding for Open uWARP with 8MB flash ...\n" >> $LOGFILE
			fgrep -q "CONFIG_TARGET_ar71xx_generic_UWARP8MB=y" .config
			if [ $? -ne 0 ]; then
				sed -i "s?# CONFIG_TARGET_ar71xx_generic_UWARP8MB is not set?CONFIG_TARGET_ar71xx_generic_UWARP8MB=y?g" .config
				sed -i "s?CONFIG_TARGET_ar71xx_generic_UWARP16MB=y?# CONFIG_TARGET_ar71xx_generic_UWARP16MB is not set?g" .config
				sed -i "s?# CONFIG_ATH79_MACH_UWARP_SPI_8M is not set?CONFIG_ATH79_MACH_UWARP_SPI_8M=y?g" target/linux/ar71xx/config-3.10
				sed -i "s?CONFIG_ATH79_MACH_UWARP_SPI_16M=y?# CONFIG_ATH79_MACH_UWARP_SPI_16M is not set?g" target/linux/ar71xx/config-3.10
				touch target/linux/ar71xx/Makefile
				# make clean before build new images
				#echo -e "\nSwitching to 8MB flash, make clean so builds properly ...\n" >> $LOGFILE
				#make clean 2>>$LOGFILE | tee -a $LOGFILE;
			fi
			break;
			;;

		2) 
			option_picked "Building for Open uWARP with 16MB flash ...";
			echo -e "\nBuilding for Open uWARP with 16MB flash ...\n" >> $LOGFILE
			fgrep -q "CONFIG_TARGET_ar71xx_generic_UWARP16MB=y" .config
			if [ $? -ne 0 ]; then
				sed -i "s?# CONFIG_TARGET_ar71xx_generic_UWARP16MB is not set?CONFIG_TARGET_ar71xx_generic_UWARP16MB=y?g" .config
				sed -i "s?CONFIG_TARGET_ar71xx_generic_UWARP8MB=y?# CONFIG_TARGET_ar71xx_generic_UWARP8MB is not set?g" .config
				sed -i "s?# CONFIG_ATH79_MACH_UWARP_SPI_16M is not set?CONFIG_ATH79_MACH_UWARP_SPI_16M=y?g" target/linux/ar71xx/config-3.10
				sed -i "s?CONFIG_ATH79_MACH_UWARP_SPI_8M=y?# CONFIG_ATH79_MACH_UWARP_SPI_8M is not set?g" target/linux/ar71xx/config-3.10
				touch target/linux/ar71xx/Makefile
				# make clean before build new images
				#echo -e "\nSwitching to 16MB flash, make clean so builds properly ...\n" >> $LOGFILE
				#make clean 2>>$LOGFILE | tee -a $LOGFILE;
			fi
			break;
			;;

		3|q)
			say_goodbye;
			;;

		*)
			clear;
			option_picked "Pick an option from the menu";
			show_menu_three;
			;;
		esac
	fi
done
fi

#
# Fourth menu
#
# don't run custom config if ran in menu 2
if [ $opt2 -ne 2 ]; then
sleep 1
clear
show_menu_fourth
while [ opt4 != '' ]
	do
	if [ $opt4 = "" ]; then 
		clear;
		option_picked;
		show_menu_fourth;
	else
		case $opt4 in
		1) 
			option_picked "Customize build configuration ...\nStarting menu ...";
			echo -e "\nStarting custom configuration ...\n" >> $LOGFILE
			make menuconfig
			break;
			;;

		2) 
			option_picked "Proceeding to build selection ....";
			break;
			;;

		3|q)
			say_goodbye;
			;;

		*)
			clear;
			option_picked "Pick an option from the menu";
			show_menu_fourth;
			;;
		esac
	fi
done
fi

#
# Fifth menu
#
if [ $opt2 -ne 2 ]; then
	sleep 1
fi
clear
show_menu_fifth
while [ opt5 != '' ]
	do
	if [ $opt5 = "" ]; then 
		clear;
		option_picked;
		show_menu_fifth;
	else
		case $opt5 in
		1) 
			option_picked "Starting the build ...\nThis may take a while ...";
			echo -e "\nStarting the build ...\n" >> $LOGFILE
			# remove old images first
			echo -e "\nRemoving old build files...\n" >> $LOGFILE
			rm bin/ar71xx/openwrt-ar71xx-generic-uwarp-ar7420-squashfs-* 2>>$LOGFILE
			# build new images
			make V=99 2>>$LOGFILE | tee -a $LOGFILE;
			# check if images created
			if [ -f bin/ar71xx/openwrt-ar71xx-generic-uwarp-ar7420-squashfs-factory.bin ] && [ -f bin/ar71xx/openwrt-ar71xx-generic-uwarp-ar7420-squashfs-sysupgrade.bin ]; then
				print_success "Image files have been created. Find them in $BASE_DIR_PATH/bin/ar71xx/ directory."
			else
				print_error "Failed to create image files."
			fi
			break;
			;;

		2) 
			option_picked "Stopping to exit ....";
			echo -e "\nStopping to exit ...\n" >> $LOGFILE
			say_goodbye;
			;;

		3|q)
			say_goodbye;
			;;

		*)
			clear;
			option_picked "Pick an option from the menu";
			show_menu_fifth;
			;;
		esac
	fi
done

say_goodbye
exit 0
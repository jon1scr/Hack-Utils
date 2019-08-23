#!/bin/bash

#---------------- FORMATING VARIABLES -------------
#Here are some variable for the text format. These variables uses escape sequences $
#In linux the escape sequences are \e, \033, \x1B
BLINK="\e[5m"
BOLD="\e[1m"
UNDERLINED="\e[4m"
INVERT="\e[7m"
HIDE="\e[8m"

RED="\e[31m"
BLUE="\e[34m"
BLACK="\e[30m"
WHITE="\e[37m"
CYAN="\e[36m"
LIGHTYELLOW="\e[1;33m"

UNDERRED="\e[41m"
UNDERGREEN="\e[42m"
UNDERWHITE="\e[107m"
UNDERGRAY="\e[47m"

#Obv we need a control sequence that closes the rest control sequences
END="\e[0m"

TAB="\t"


#---------------- VARIABLES -------------
#All interfaces in used in the system
interfaces_extracted=`ip addr | grep ^[0-9]: | cut -f 2 -d ":" | sed 's/ //g' | tr '\n' " "`

#Transforms the string with the interfaces into array
read -a ifaces_array <<< $interfaces_extracted
#Saves how many interfaces have the system
number_of_interfaces=${#ifaces_array[@]}

#########All programs required save it into array
#declare -a programs_array
programs_array=(ping nmcli traceroute iftop iptraf-ng nethogs slurm tcptrack vnstat bwm-ng bmon ifstat network-manager speedometer)
number_of_programs=${#programs_array[@]}

#---------------- FUNCTIONS ----------------
menu()
{
	clear

	echo -e $TAB$RED"  _   _      _                      _        _   _ _   _ _
	 | \\ | | ___| |___      _____  _ __| | __   | | | | |_(_) |___
	 |  \\| |/ _ \\ __\\ \\ /\\ / / _ \\| '__| |/ /   | | | | __| | / __|
	 | |\\  |  __/ |_ \\ V  V / (_) | |  |   <    | |_| | |_| | \\__ \\
	 |_| \\_|\\___|\\__| \\_/\\_/ \\___/|_|  |_|\\_\\    \\___/ \\__|_|_|___/		v 0.1
-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	"$END
	echo ""



	echo -e $BLUE"  >>> MISCELLANEOUS <<<  "$END
	echo ""

	echo -e $LIGHTYELLOW"   chckdep"$END")" "Check all the dependencies"	$TAB$TAB$LIGHTYELLOW"up"$END")" "Update Network Utils"
	echo -e $TAB$LIGHTYELLOW" 0"$END")" "Exit"$TAB$TAB
	echo ""
	echo ""



	echo -e $BLUE"  >>> BASICS <<<  "$END
	echo ""

	echo -e $TAB$LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"$TAB	$TAB$LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
	echo -e $TAB$LIGHTYELLOW" 1"$END")" "Ping"$TAB$TAB                      $TAB$TAB$LIGHTYELLOW" 2"$END")" "Traceroute"$TAB                $TAB$TAB$TAB$LIGHTYELLOW" 3"$END")" "Hops to gateway"
	echo -e $TAB$LIGHTYELLOW" 4"$END")" "ARP table"$TAB$TAB                 $TAB$TAB$LIGHTYELLOW" 5"$END")" "Public IP"$TAB                 $TAB$TAB$TAB$LIGHTYELLOW" 6"$END")" "Bandwith"
	echo -e $TAB$LIGHTYELLOW" 7"$END")" "Bytes in/out"$TAB                  $TAB$TAB$LIGHTYELLOW" 8"$END")" "Check remote port status"
	echo ""
	echo ""



	echo -e $BLUE"  >>> ADVANCED <<<  "$END
	echo ""

	echo -e $LIGHTYELLOW"     advif"$END")" "Advanced interfaces info (nmcli)"
	echo -e $TAB$LIGHTYELLOW" X"$END")" "Ping (personalized)"$TAB$TAB	$TAB$LIGHTYELLOW" X"$END")" "Traceroute (personalized)"
	echo ""
	echo ""



	if [[ $invalidoption == true ]];
	then
		echo "Wut? I guess this is not a valid option... :/"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
		echo ""
	else
		echo "Type an option:"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
		echo ""
	fi
}

command_for_interfaces()
{
	echo -e "Available interfaces:"$BLUE ${ifaces_array[@]}
	echo ""

	for (( interface_number=0; interface_number<$number_of_interfaces; interface_number++ ));
	do
		echo -e $BLUE">>> "${ifaces_array[$interface_number]}" <<<"$END
		$1 ${ifaces_array[$interface_number]} $2
		echo ""
	done
}

interfaces_selector()
{
	for (( interface_number=0; interface_number<$number_of_interfaces; interface_number++ ));
	do
		echo -e " " $LIGHTYELLOW$interface_number$END") "$BLUE${ifaces_array[$interface_number]}$END
	done

	echo ""
}

show_programs()
{
	echo -e $LIGHTYELLOW"chckdep"$END")" "Check all the dependencies"
	echo ""

	for (( program_number=0; program_number<$number_of_programs; program_number++ ));
	do
		path_actual_program=`which ${programs_array[$program_number]}`
		#program_name=${programs_array[$program_number]}

		if [[ $path_actual_program == '' ]];
		then
			printf "%-2s %-20s $UNDERRED$BLACK %-0s $END" "  >" "${programs_array[$program_number]}" "UNINSTALLED"
			echo ""
		else
			printf "%-2s %-20s $UNDERGREEN$BLACK %-1s $END %-1s %-1s" "  >" "${programs_array[$program_number]}" " INSTALLED " ">>>>>" $path_actual_program
			echo ""
		fi

		#program_name=""
		path_actual_program=""
	done
}

install_uninstall_programs_array()
{
	option=$3

	clear
	show_programs

	for (( program=0; program<$number_of_programs; program++ ));
	do
		path_actual_program=`which ${programs_array[$program]}`
		#program_name=${programs_array[$program_number]}

		echo ""
		echo "Checking ${programs_array[$program]} ..."
		sleep 0.1

		if [[ $path_actual_program == '' && $option == "id" ]];
		then
			echo "Installing ${programs_array[$program]} ..."
			echo ""

			#echo "sudo apt-get --assume-yes $1 ${programs_array[$program]} > /dev/null"
			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} > /dev/null

		elif [[ $path_actual_program == "/"* && $option == "ud" && ${programs_array[$program]} == "ping" || ${programs_array[$program]} == "nmcli" || ${programs_array[$program]} == "traceroute" ]];
		then
			echo "Omiting ${programs_array[$program]} ..."
			sleep 0.5

		elif [[ $path_actual_program == "/"* && $option == "ud" ]];
		then
			echo "Unistalling ${programs_array[$program]} ..."
			echo ""

			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} > /dev/null
		fi

		#program_name=""
		path_actual_program=""

		clear
		show_programs
	done
}

#---------------- SCRIPT ----------------
while true;
do
	#Starts the main screen
	menu
	#When user select an option, sets the parameter for distinguise an invalid option in false
	invalidoption=false

	clear

	case $option in
		if)
			echo -e $LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"
			echo ""

			#Function		First part of the command	Second part of the command
			#command_for_interfaces "ifconfig "			""
			command_for_interfaces "ifconfig " ""

			;;
		advif)
			echo -e $LIGHTYELLOW"advif"$END")" "Advanced interface info (nmcli)"
			echo ""

			#Function               First part of the command       Second part of the command
			#command_for_interfaces "ifconfig "                     ""
			command_for_interfaces "nmcli device show " ""

			;;
		wc)
			echo -e $LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
			echo ""

			nmcli device wifi rescan
			nmcli device wifi list
			echo ""

			echo -ne "SSID: "$LIGHTYELLOW ; read ssid ; echo -ne $END
			echo -ne "Password: "$HIDE ; read psswd ; echo -e $END
			echo ""

			nmcli device wifi connect $ssid password $psswd
			echo ""

			sleep 2

			echo "You want to test your internet connection?"
			while true;
			do
				echo -ne "[ y/n ]"$BLINK" > "$END$LIGHTYELLOW ; read resp ; echo -ne "" $END

				if [ $resp = 'y' ]
				then
					ping -c 5 8.8.8.8
					break
				elif [ $resp = 'n' ]
				then
					break
				else
					print "Type yes (y) or no (n)"
				fi
			done

			;;
		chckdep)
			valid_option=false

			while [[ $valid_option == false ]];
			do
				show_programs

				echo ""
				echo ""

				echo -e " " $LIGHTYELLOW"id"$END")" "Install all the dependencies"
				echo -e " " $LIGHTYELLOW"ud"$END")" "Uninstall all the dependencies"
				echo -e " " $LIGHTYELLOW" 0"$END")" "Cancel"
				echo ""
				echo ""

				echo "Type an option:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
				echo ""

				case $option in
					id)
						install_uninstall_programs_array "install" "" "$option"

						valid_option=true

						;;
					ud)
						install_uninstall_programs_array "" "purge" "$option"

						valid_option=true

						;;
					0)
						valid_option=true

						;;
					*)
						clear

						;;
				esac
			done

			;;
		up)
			echo -e $LIGHTYELLOW"up"$END")" "Update Network Utils"
			echo ""

			git clone https://github.com/davidahid/Network-Utils
			cd
			mkdir /tmp/Network-Utils/
			mv Network-Utils/ /tmp/Network-Utils/

			;;
		1)
			echo -e $LIGHTYELLOW"1"$END")" "Ping"
			echo ""

			echo -e "Which address you want to ping?"
			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ping_address ; echo -ne "" $END
			echo ""

			echo -e "From which interface you want to throw the ping?"

			interfaces_selector

			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selected_interface ; echo -ne "" $END
			echo ""

			ping -I ${ifaces_array[$selected_interface]} $ping_address
			;;
		2)
			;;
		3)
			echo -e $LIGHTYELLOW"3"$END")" "Hops to gateway"
			echo ""

			echo -e "From which interface you want to reach the gateway?"

			interfaces_selector

			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selected_interface ; echo -ne "" $END
			echo ""

			gateway_ip=`ip route list | grep $selected_interface | grep default | cut -f 3 -d " " | uniq`

			traceroute --interface=${ifaces_array[$selected_interface]} $gateway_ip

			;;
		4)
			echo -e $LIGHTYELLOW"4"$END")" "ARP table"
			echo ""

			#Function		First part of the command	Second part of the command
			#command_for_interfaces "arp -i "			""
			command_for_interfaces "arp -i " ""

			;;
		5)
			echo -e $LIGHTYELLOW"5"$END")" "Public IP"
			echo ""

			echo -ne "Your public IP is >>> "$CYAN ; curl icanhazip.com ; echo -e $END

			;;
		6)
			;;
		7)
			;;
		8)
			;;
		0)
			exit

			;;
		*)
			invalidoption=true

			;;
	esac

	#If the user type an invalid option...
	if [[ $invalidoption == true ]];
	then
		#...do nothing
		:

	#...but if the option is included in the case
	else
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERGRAY$BLACK"Press ENTER to go back to the main menu"$END
		tput civis
		read
		tput cnorm
	fi

	#Set all control variables to default
	#selected_interface=""
	#option=""
done
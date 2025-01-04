#!/bin/bash

# Set ANSI color variables

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
MGT='\033[0;35m'
CYN='\033[0;36m'
CLR='\033[0m'

# Set select prompt text
PS3='Select an option: '

# Set variables for /dev/urandom for possible password entries
alphabetical='A-Za-z'
numeric='0-9'
symbolrst='?!@#$%&'
symbolall='{}()[]#*:+;^,-.?!|&"_`~@$%/\='
pwopt=''

# Set dialog option arrays
options=(1 "Numbers" off
         2 "Letters" off
         3 "Common Symbols" off
         4 "All Symbols" off)

# User set variables
length='USER INPUT'
pwstor='USER INPUT'

# Used with regex
isnum='^[0-9]{2}$'

# Set the nessecary program functions
# callTitle() - Clears the screen and calls the title with color variables
# callPwgen() - Called when the user decides to generate a password
# genRand() - Called when the user wants to generate a password using /dev/urandom

callTitle() {
	clear
	printf "${GRN}----------------------------------------------------\n"
	printf "${GRN}|            ${CYN}Bash Password Generator               ${GRN}|\n"
	printf "${GRN}|                   ${CYN} by G22                        ${GRN}|\n"
	printf "${GRN}----------------------------------------------------\n\n${CLR}"
}

callPwgen() {
	callTitle
	printf "You chose to ${YLW}generate a new password${CLR}.\n"
	printf "What would you like to use to generate the new password?\n\n"
	# Selection dialog for password generation options
	select opt2 in "/dev/urandom" "Exit the program"; do
	  case $opt2 in
		"/dev/urandom")
			genRand
			break
			;;
		"Exit the program")
			break
			;;
		*)
			echo "Invalid option ${REPLY}"
			;;
	  esac
	done
}

genRand() {
	printf "\n/dev/urandom is a device file that serves as a ${MGT}secure${CLR} psuedorandom number generator. While it outputs total random bytes, we can filter the data to generate a functioning password."
	printf "What would you like the length of the password to be?\n"
	# Reads a number from the user that is two digits, outputs to the length variable
	read -n 2 -p "Enter a number (00-99): " length
	# Continue asking for input from the user if the format is wrong
	while [[ ! $length =~ $isnum ]] do
	  printf "\nThe format is wrong!\n"
	  read -n 2 -p "Enter a number (0-99): " length
	done
	# Prepare dialog and call dialog
	cmd=(dialog --separate-output --checklist "Select password generation options:" 22 76 16)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	callTitle
	# For any selected choices within the dialog, append the respective options to the pwopt
	# file variable, to be passed along to the generation command
	for choice in $choices
	do
	    case $choice in
	        1)
	            pwopt+=${alphabetical}
	            ;;
	        2)
	            pwopt+=${numeric}
	            ;;
	        3)
	            pwopt+=${symbolrst}
	            ;;
	        4)
	            pwopt+=${symbolall}
	            ;;
	    esac
	done
	# Filter output from /dev/urandom to only output characters that were selected by the
	# user - then pipe the output to head, so that it can be limited by length
	# Parsed with xargs
	pwstor=$(tr -dc $pwopt < /dev/urandom | head -c $length | xargs -0)
	echo "Your password is: "
	echo ${pwstor}
	printf "Would you like to save your password in a file?\n"
	# Read for a Y/N response from the user
	read -r -p "[y/N] " response
	case "$response" in
	  [yY][eE[sS]|[yY])
		printf "Please enter the file name: "
		read filename
		# Output to the file that the user indicated
		echo "Created by G22's Password Generator - " >> $filename
		echo $pwstor >> $filename
		printf "${CYN}Thank you${CLR} for using the generator!"
		break
		;;
	  *)
		printf "${CYN}Thank you${CLR} for using the generator!"
		break
		;;
	esac
}

# Main program, prompting user for main options

callTitle

printf "Welcome to the interactive password generator prompt.\n"
printf "This script requires ${RED}dialog${CLR} to be installed.\n"
printf "What would you like to do?\n\n"

select opt in "Generate a new password" "Exit the program"; do

  # Selection dialog for generating a password or exiting the program
  case $opt in
	"Generate a new password")
		callPwgen
		break
		;;
	"Exit the program")
		break
		;;
	*)
		echo "Invalid option ${REPLY}"
		;;
  esac
done

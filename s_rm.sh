#!/bin/sh
#
# author:	jizhouli (justinli.ljt@gmail.com)
# update:	2011-04-23
# purpose:	a security version command instead of dangerous "rm"

# shell script options
#set -u

#RECYCLEDBIN="/home/${USER}/.Recycle Bin"
RECYCLEDBIN="/tmp/.Recycle Bin"
SCRIPT="$0"
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
H=`date +%H`
M=`date +%M`
S=`date +%S`

DIR="$RECYCLEDBIN/$YEAR$MONTH$DAY"

function no_param()
{
	cat <<-NOPARAMDOCUMENT
	${SCRIPT}: missing file operand
	Try ' --help' for more information.
	(security version)
	NOPARAMDOCUMENT
	exit 1
}

function invalid_option()
{
	cat <<-INVALIDOPTIONDOCUMENT
	${SCRIPT}: invalid option -- $1
	Try ' --help' for more information.
	(security version)
	INVALIDOPTIONDOCUMENT
	exit 1
}

function help()
{
	cat <<-HELPDOCUMENT
	Usage: ${SCRIPT} [OPTION]... FILE...
	Move FILE(s) to ${RECYCLEDBIN} instead of removing the FILE(s).
	
	e.g. rm a.txt
	     rm a.txt b.txt c.dir
	     rm a.*

	  -f			remove the file PERMANENTLY instead of moving to recycle bin
	  -h, --help		display this help and exit
	  -v, --version		output version information and exit

	Report bugs to <justinli.ljt@gmail.com>.
	HELPDOCUMENT
	exit 0
}

function version()
{
	cat <<-VERSIONDOCUMENT
	rm(security version) 1.00
	Copyright (C) 2011 LIJINGTIAN.
	License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
	This is free software: you are free to change and redistribute it. 
	There is NO WARRANTY, to the extent permitted by law.

	Written by Lijingtian<justinli.ljt@gmail.com>.
	VERSIONDOCUMENT
	exit 0
}

if [ "$#" -eq "0" ]
then
	no_param
fi

declare -a FILENAME_ARR

i=0
OPT_REALRM=0
OPT_RECURSIVE=""
while [ -n "$1" ]
do
	case $1 in
		-[hH]|--[hH]elp)
		help
		shift 1
		;;
		-[vV]|--[vV]ersion)
		version
		shift 1
		;;
		-f)
		OPT_REALRM=1
		shift 1
		;;
		-[rR]|--[rR]ecursive)
		OPT_RECURSIVE="-r"
		shift 1
		;;
		-[a-zA-Z0-9]*)
		invalid_option $1
		shift 1
		;;
		*)
		FILENAME[i]=$1
		((i += 1))
		shift 1
		;;
	esac
done

if [ ! -d "$RECYCLEDBIN" ]
then
	echo -e "\"$RECYCLEDBIN\" does not exist, do you want create it?"
	echo -n "(yes/on):"
	
	read answer
	if [ "$answer" = "yes" ]
	then
		mkdir "$RECYCLEDBIN"
	else
		echo "removed failed!"
		exit 1
	fi
fi

if [ ! -d "$DIR" ]
then
	mkdir "$DIR"
fi

for orifile in "${FILENAME[@]}"
do
	if [ -e "${orifile}" ]
	then
		oribasename=`basename ${orifile}`
		dstfile="$DIR/$H$M$S.${oribasename}"
		if [ -e "${dstfile}" ]
		then
			postfix=1
			while [ -e "${dstfile}.$postfix" ]
			do
				((postfix += 1))
			done
			dstfile="${dstfile}.$postfix"
		fi

		if [ "${OPT_REALRM}" -eq "0" ]
		then
			mv "${orifile}" "${dstfile}"
			#echo -e "\"${orifile}\" removed saftely"
		else
			rm "${orifile}" -r
			#echo -e "\"${orifile}\" removed permanently"
		fi

	else
		echo -e "${SCRIPT}: cannot remove \"${orifile}\": No such file or directory"
	fi
done

exit 0

# next version to do
#if size >1000M ask if really delete
#
#e.g. this file is larger than 1G
#     do you want delete this file permanently?
#
#add crontab to auto delete recycle bin long ago

# BUGLIST

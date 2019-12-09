#!/bin/bash
if [ -z $1 ]
then
	echo "Please enter the doublename you want to remove: "
	read doubleName
else
	if [ $1 == "-list" ]
	then
		echo "Users: "
		sqlite3 pythonsqlite.db "select * from users"
		echo ""
		echo "Auths: "
		sqlite3 pythonsqlite.db "select * from auth"
		exit 0
	else
		doubleName=$1
	fi
fi

echo ""
sql=$(sqlite3 pythonsqlite.db "select double_name, email from users where double_name = '$doubleName'")

if [ -z $sql ]
then
	echo "Sorry, we didn't find $doubleName in our database."
	exit 1
fi

if [ -z $2 ]
then
	echo "Are you sure you want to delete: $doubleName (Y/n)"
	read confirmation
else
	if [ $2 == '-y' ] || [ $2 == '-Y' ]
	then
		confirmation="y"
	fi
fi


if [ -z $confirmation ] ||  [ $confirmation == "y" ] || [ $confirmation == "Y" ] || [ $confirmation == "" ]
then
	echo "Attempting to delete: $sql"
	sqlite3 pythonsqlite.db "delete from users where double_name = '$doubleName'"
	sqlite3 pythonsqlite.db "delete from auth where double_name = '$doubleName'"

	sql2=$(sqlite3 pythonsqlite.db "select double_name, email from users where double_name = '$doubleName'")
	if [ -z $sql2 ]
	then
		echo "Success."
	else
		echo "Something went wrong."
	fi
fi

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
    exit
fi


ATOMIC_NUMBER=0
if [[ $1 =~ ^[0-9]+$ ]]
then
  NUMBER_EXISTS=$($PSQL "SELECT 1 FROM elements WHERE atomic_number=$1 LIMIT 1;")
  if [ "$NUMBER_EXISTS" = "1" ]; 
  then
    ATOMIC_NUMBER=$1
  fi
else
  SYMBOL_EXISTS=$($PSQL "SELECT 1 FROM elements WHERE symbol = '$1' LIMIT 1;")
  if [ "$SYMBOL_EXISTS" = "1" ]; 
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1';")
  fi

  NAME_EXISTS=$($PSQL "SELECT 1 FROM elements WHERE name = '$1' LIMIT 1;")
  if [ "$NAME_EXISTS" = "1" ]; 
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1';")
  fi
fi
if [ "$ATOMIC_NUMBER" = "0" ]; 
then
  echo I could not find that element in the database.
  exit
fi

ATOMIC_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
ATOMIC_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")

ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
ATOMIC_MELT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
ATOMIC_BOIL=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")

ATOMIC_TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
ATOMIC_TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $ATOMIC_TYPE_ID";)
echo "The element with atomic number $ATOMIC_NUMBER is $ATOMIC_NAME ($ATOMIC_SYMBOL). It's a $ATOMIC_TYPE, with a mass of $ATOMIC_MASS amu. $ATOMIC_NAME has a melting point of $ATOMIC_MELT celsius and a boiling point of $ATOMIC_BOIL celsius."
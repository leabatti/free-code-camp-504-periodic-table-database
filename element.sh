#!/bin/bash

# Set the psql command for querying the database with plain output
PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# Handle the case when no argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Determine the search condition based on the input type
# If it's a number, search by atomic_number
# If it's text, search by symbol or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="atomic_number = $1"
else
  CONDITION="symbol = '$1' OR name = '$1'"
fi

# Perform the query to get all necessary info from the related tables
RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE $CONDITION;")

# If the query returns nothing, the element was not found
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parse the result values into variables using IFS (Internal Field Separator)
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# Output the formatted element information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
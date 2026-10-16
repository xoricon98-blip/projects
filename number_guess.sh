#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:" 
read username

USERNAME_EXISTS=$($PSQL "SELECT 1 FROM guessing_game WHERE username = '$username' LIMIT 1;")
if [[ -n "$USERNAME_EXISTS" ]]; then
  BEST_GAME=$($PSQL "SELECT best_game FROM guessing_game WHERE username = '$username';")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM guessing_game WHERE username = '$username';")
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $username! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=1000
fi

RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_AMOUNT=1

while [[ ! "$GUESS" == "$RANDOM_NUMBER" ]]; do
  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ "$GUESS" -gt "$RANDOM_NUMBER" ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
    (( GUESS_AMOUNT++ ))
  elif [[ "$GUESS" -lt "$RANDOM_NUMBER" ]]; then
    echo "It's higher than that, guess again:"
    read GUESS
    (( GUESS_AMOUNT++ ))
  fi
done


echo "You guessed it in $GUESS_AMOUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

if [[ $GUESS_AMOUNT -lt $BEST_GAME ]]; then
  BEST_GAME="$GUESS_AMOUNT"
fi

(( GAMES_PLAYED++ ))

if [[ -n "$USERNAME_EXISTS" ]]; then
  FINAL=$($PSQL "UPDATE guessing_game SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username = '$username';")
else
  FINAL=$($PSQL "INSERT INTO guessing_game(username, games_played, best_game) VALUES('$username', $GAMES_PLAYED, $BEST_GAME);")
fi





#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"


echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")


if [[ -z $USER_DATA ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
GUESS=1

echo "Guess the secret number between 1 and 1000:"
RANDOM_NUMBER=$((RANDOM % 10 + 1))
read INPUT_NUMBER

while [[ ! $INPUT_NUMBER -eq $RANDOM_NUMBER ]]
do
  if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    ((GUESS++))
    read INPUT_NUMBER
  else
    if [[ $INPUT_NUMBER -gt $RANDOM_NUMBER ]]
      then
      echo "It's lower than that, guess again:"
      ((GUESS++))
      read INPUT_NUMBER
    elif [[ $INPUT_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      ((GUESS++))
      read INPUT_NUMBER
    fi
  fi
done 

HIGH_SCORE=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $GUESS)")
echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"



#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

DB_NAME="salon"
DB_USER="freecodecamp"

echo "Welcome to My Salon, how can I help you?"
# Run psql and pipe the unaligned output into the while loop
MAIN_MENU(){
if [[ $1 ]]
  then
    echo -e "\n$1"

  fi

  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  echo "$SERVICES_LIST" | while IFS="|" read service_id name;
  do
    echo "$service_id) $name"
  done

  echo -e "Please request a service: " 
  read SERVICE_ID_SELECTED

  REQ_SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
  if [[ -z $REQ_SERVICE_EXISTS ]]
    then
    MAIN_MENU "Please enter an existing service ID"
    else

    echo -e"Please enter your phone number: " 
    read CUSTOMER_PHONE

    CUSTOMER_PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_PHONE_EXISTS ]]
    then
      echo -e "Please enter your name: " 
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    fi
      
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    echo -e"Please enter a time for your appointment: " 
    read SERVICE_TIME

    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

    echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

  fi

}

MAIN_MENU
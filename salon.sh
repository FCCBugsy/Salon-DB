#!/bin/bash

GREET() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo -e "\nWelcome to My Salon, how can I help you?"
  fi

  PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
  echo "~~~~~ MY SALON ~~~~~"

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # listing current services
  echo "$AVAILABLE_SERVICES" | while read SERV_ID BAR SERV_NAME
  do
    echo "$SERV_ID) $SERV_NAME"
  done

  # listening to the user's service
  read SERVICE_ID_SELECTED

  CHECKING_VALIDITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $CHECKING_VALIDITY ]]
  then
    # no service_id found.. we call the function again and set the greet message to the following
    GREET "I could not find that service. What would you like today?"
  
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    ALREADY_CUSTOMER=$($PSQL "SELECT customer_id, phone, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $ALREADY_CUSTOMER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # "silently" adding the customer in our database...
      $PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
    fi

    # xargs will remove any whitespaces in a variable, so me wight as well use it instead of regex
    GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    GET_SERVICE_NAME=$(echo $GET_SERVICE_NAME | xargs)

    CURRENT_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CURRENT_CUSTOMER_NAME=$(echo $CURRENT_CUSTOMER_NAME | xargs)

    echo -e "\nWhat time would you like your $GET_SERVICE_NAME, $CURRENT_CUSTOMER_NAME?"
    read SERVICE_TIME

    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    GET_CUSTOMER_ID=$(echo $GET_CUSTOMER_ID | xargs)

    echo -e "\nI have put you down for a $GET_SERVICE_NAME at $SERVICE_TIME, $CURRENT_CUSTOMER_NAME."

    $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($GET_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
  fi
}

GREET # function call

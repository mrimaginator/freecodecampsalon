#! /bin/bash

PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'

echo -e "\n~~~~~ Salon Appointment Booker ~~~~~\n"

MAIN_MENU() {
  if [[ 1 ]]
  then
    echo -e "\n$1"
  fi
  # get the available services
  SERVICE_OPTIONS=$($PSQL "SELECT service_id, name FROM services")
  
  # ask which service they'd like
  echo -e "Please Select A Service"
  echo "$SERVICE_OPTIONS" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  # if input isn't a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "Please input a number."
  else
    # check service id is a service
    SERVICE_OPTION=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    # if not
    if [[ -z $SERVICE_OPTION ]]
    then 
      # send to main menu
      MAIN_MENU "That is not a valid service option."
    fi
    # ask for phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if no customer name
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for name
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME

      # generate new customer
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # ask what time
    echo -e "\nWhat time would you like?"
    read SERVICE_TIME
    
    # input the appointment into the table
    INPUT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_OPTION | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
}

MAIN_MENU
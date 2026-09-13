#!/usr/bin/env bash
# ------------------------------------------------------------
# @title       Task5_crud_app.sh
# @author      Vera Baiden
# @index       7354523
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description A menu-driven Phonebook CRUD app. Stores contacts as
#              ID,Name,Phone,Email in a plain text file next to the script.
# @date        2026-09-13
# ------------------------------------------------------------
#
# Exit codes:
#   0 = normal exit
#   1 = bad usage
# ------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "Runs an interactive phonebook menu. No arguments needed."
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

data_file="data.txt"

# Make sure the data file exists so read/view don't error out on first run.
touch "$data_file"

# Get the next free ID by finding the highest existing ID and adding 1.
next_id() {
  last_id=$(cut -d',' -f1 "$data_file" | sort -n | tail -1)
  if [ -z "$last_id" ]; then
    echo 1
  else
    echo $((last_id + 1))
  fi
}

# CREATE: add a new contact.
add_contact() {
  read -p "Name: " name
  read -p "Phone number: " phone
  read -p "Email: " email

  if [ -z "$name" ] || [ -z "$phone" ] || [ -z "$email" ]; then
    echo "Error: all fields are required. Contact not added."
    return
  fi

  id=$(next_id)
  echo "$id,$name,$phone,$email" >> "$data_file"
  echo "Added contact #$id: $name"
}

# READ: list all contacts.
list_contacts() {
  if [ ! -s "$data_file" ]; then
    echo "No contacts yet."
    return
  fi
  echo "ID | Name | Phone | Email"
  echo "----------------------------"
  while IFS=',' read -r id name phone email; do
    echo "$id | $name | $phone | $email"
  done < "$data_file"
}

# READ (search): find a contact by name.
search_contact() {
  read -p "Enter name to search for: " search_term
  matches=$(grep -i "$search_term" "$data_file")
  if [ -z "$matches" ]; then
    echo "No contact found matching '$search_term'."
  else
    echo "ID | Name | Phone | Email"
    echo "----------------------------"
    echo "$matches" | while IFS=',' read -r id name phone email; do
      echo "$id | $name | $phone | $email"
    done
  fi
}

# UPDATE: change an existing contact's details.
update_contact() {
  read -p "Enter ID of contact to update: " id

  if ! grep -q "^$id," "$data_file"; then
    echo "Error: no contact found with ID $id."
    return
  fi

  cp "$data_file" "$data_file.bak"
  echo "Backed up data to $data_file.bak before updating."

  read -p "New name: " name
  read -p "New phone number: " phone
  read -p "New email: " email

  if [ -z "$name" ] || [ -z "$phone" ] || [ -z "$email" ]; then
    echo "Error: all fields are required. Update cancelled."
    return
  fi

  # Rewrite the file, replacing only the matching line.
  grep -v "^$id," "$data_file" > "$data_file.tmp"
  echo "$id,$name,$phone,$email" >> "$data_file.tmp"
  sort -n -t',' -k1 "$data_file.tmp" > "$data_file"
  rm -f "$data_file.tmp"

  echo "Updated contact #$id."
}

# DELETE: remove a contact.
delete_contact() {
  read -p "Enter ID of contact to delete: " id

  if ! grep -q "^$id," "$data_file"; then
    echo "Error: no contact found with ID $id."
    return
  fi

  read -p "Are you sure you want to delete contact #$id? (y/n): " confirm
  if [ "$confirm" != "y" ]; then
    echo "Delete cancelled."
    return
  fi

  cp "$data_file" "$data_file.bak"
  echo "Backed up data to $data_file.bak before deleting."

  grep -v "^$id," "$data_file" > "$data_file.tmp"
  mv "$data_file.tmp" "$data_file"
  echo "Deleted contact #$id."
}

# MENU: the main loop.
while true; do
  echo ""
  echo "----- Phonebook Menu -----"
  echo "1) Add contact"
  echo "2) View/List all contacts"
  echo "3) Search contact"
  echo "4) Update contact"
  echo "5) Delete contact"
  echo "6) Exit"
  read -p "Choose an option (1-6): " choice

  case "$choice" in
    1) add_contact ;;
    2) list_contacts ;;
    3) search_contact ;;
    4) update_contact ;;
    5) delete_contact ;;
    6) echo "Goodbye."; exit 0 ;;
    *) echo "Invalid option. Please choose 1-6." ;;
  esac
done

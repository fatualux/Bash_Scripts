#!/bin/bash

###FUNCTIONS###
ChooseFilename() {
  read -p "Enter filename: " filename
  echo $filename
}

ChoseNumdays() {
  read -p "Enter number of days: " numdays
  echo $numdays
}

###END FUNCTIONS###

###MAIN###
WORKDIR=OPENSSL
FILENAME=$(ChooseFilename)
NUMDAYS=$(ChoseNumdays)
mkdir $WORKDIR && cd $WORKDIR

echo"Generating key..."
openssl genrsa -des3 -passout pass:xnet@123 -out $FILENAME.pass.key 2048
openssl genrsa -des3 -passout pass:xnet@123 -out $FILENAME.pass.key 2048
openssl rsa -passin pass:xnet@123 -in $FILENAME.pass.key -out $FILENAME.key
rm $FILENAME.pass.key

echo"Generating certificate..."
openssl req -new -key $FILENAME.key -out $FILENAME.csr
openssl x509 -req -days $NUMDAYS -in $FILENAME.csr -signkey $FILENAME.key -out $FILENAME.certificate

echo "Done!"

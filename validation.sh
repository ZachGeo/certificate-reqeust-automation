#!/bin/bash

privateKeyPath=$1
certCsrPath=$2
certCrtPath=$3

privateKeyHash=$(openssl pkey -in ${privateKeyPath} -pubout -outform pem | sha256sum | cut -f 1 -d " ")
certCsrHash=$(openssl req -in ${certCsrPath} -pubkey -noout -outform pem | sha256sum | cut -f 1 -d " ")

if [ $certCrtPath ]; then
	certCrtHash=$(openssl x509 -in ${certCrtPath} -pubkey -noout -outform pem | sha256sum | cut -f 1 -d " ")
	if [ $privateKeyHash = $certCsrHash ] && [ $privateKeyHash =  $certCrtHash ]; then
		echo "Validation is successfuly completed."
	else
		echo "Validation error!!"
		echo "Key Hash: ${privateKeyHash}"
		echo "CSR Hash: ${certCsrHash}"
		echo "CRT Hash: ${certCrtHash}"
	fi
else
	if [ $privateKeyHash = $certCsrHash ]; then
                echo "Validation is successfuly completed."

	else
		echo "Validation error!!"
		echo "Key Hash: ${privateKeyHash}"
		echo "CSR Hash: ${certCsrHash}"
	fi
fi

#!/bin/bash

type=$1
commonName=$2
country=$3
state=$4
localityName=$5
organization=$6
emailAddress=$7

arg="/C=${country}/ST=${state}/L=${localityName}/O=${organization}/CN=${commonName}/emailAddress=${emailAddress}"

echo "The type of the certificate request is: $type"
echo "Common Name: $commonName"

if [ $type = "single" ] || [ $type = "wildcard" ]; then
    openssl req -new -newkey rsa:2048 -nodes -keyout private.key -subj "$arg" -out cert.csr
    openssl req -text -in cert.csr -noout -verify
elif [ $type = "multidomain" ]; then
    multiDomainConfigPath=$8

    cp /etc/ssl/openssl.cnf $multiDomainConfigPath/openssl.cnf
    sed -i -e 's/# req_extensions = v3_req.*/req_extensions = v3_req/g' $multiDomainConfigPath/openssl.cnf
    sed -i -e 's/\[ v3_req \]/\[ v3_req \]\nsubjectAltName = @alt_names/g' $multiDomainConfigPath/openssl.cnf
    echo "[ alt_names ]" >> $multiDomainConfigPath/openssl.cnf

    IFS=","
    read -ra SANs <<< "$9"
    for (( i=0; i<${#SANs[@]}; i++ ))
    do
        echo -e "\nDNS.$i=${SANs[$i]}" >> $multiDomainConfigPath/openssl.cnf
    done

    openssl req -out cert.csr -newkey rsa:2048 -nodes -keyout private.key -subj "$arg" -config "$multiDomainConfigPath/openssl.cnf"
    openssl req -text -in cert.csr -noout -verify
else
    echo "Please enter one of the following certificate types: single, multidomain, wildcard"
fi

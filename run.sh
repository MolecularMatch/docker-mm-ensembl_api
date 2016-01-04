#!/bin/bash

sed -i "s/\SQL_HOST/$SQL_HOST/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_PORT/$SQL_PORT/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_USER/$SQL_USER/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_PASSWORD/$SQL_PASSWORD/" /opt/src/ensembl-rest/ensembl_rest.conf

/opt/src/ensembl-rest/script/ensembl_rest_server.pl
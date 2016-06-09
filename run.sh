#!/bin/bash

sed -i "s/\SQL_HOST/$SQL_HOST/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_PORT/$SQL_PORT/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_USER/$SQL_USER/" /opt/src/ensembl-rest/ensembl_rest.conf
sed -i "s/\SQL_PASSWORD/$SQL_PASSWORD/" /opt/src/ensembl-rest/ensembl_rest.conf

#pull down files used by ensembl from s3
aws s3 cp s3://mm-s3-bucket/importdata/ensembl_api_84_cache_fasta.tgz ensembl_api_84_cache_fasta.tgz

#unzip the files from s3 to the proper location
if [ -e "ensembl_api_84_cache_fasta.tgz" ]
then
	mkdir -p /opt/.vep
	tar -xvf ensembl_api_84_cache_fasta.tgz -C /opt/.vep
fi

/opt/src/ensembl-rest/script/ensembl_rest_server.pl
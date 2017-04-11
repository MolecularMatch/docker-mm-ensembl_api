docker-mm-ensembl_api
=====================

Builds an ensembl server that relays API calls to an ensembl database

```
git clone git@github.com:MolecularMatch/docker-mm-ensembl_api.git
cd docker-mm-ensembl_api
docker build -t molecularmatch/docker-mm-ensembl_api .
docker run --name docker-mm-ensembl_api -it -p 3000:3000 molecularmatch/docker-mm-ensembl_api bash
```
You may test the connection to ensembl from a prompt
```
perl /opt/src/ensembl/misc-scripts/ping_ensembl.pl
```
And you may test the API by navigating to http://localhost:3000

## Upgrading Ensembl
1. Create new rXX release branch for github
1. Change Dockerfile to refer to current version (currently 86)
1. Generate s3://mm-s3-bucket/importdata/ensembl_api_86_cache_fasta.tgz for cache performance improvements
	1. Get latest cache file from ensembl (rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-88/variation/VEP/homo_sapiens_merged_vep_88_GRCh37.tar.gz .)
	1. Unzip cache locally (link /opt/.vep to local drive on container)
	1. Execute cache command (docker exec -t <containerid> /bin/bash) to generate cache files (/opt/src/ensembl-tools/scripts/variant_effect_predictor/convert_cache.pl -species homo_sapiens -version 88_GRCh37 --force)
	1. Tar gzip the locally linked /opt/.vep folder as ensembl_api_88_cache_fasta.tgz
	1. Upload new file to s3://mm-s3-bucket/importdata/ensembl_api_88_cache_fasta.tgz


## Upgrading MySQL
1. Run the download script through ./ensembl_db_download.sh homo_sapiens 88 37
	1. This will download the data as well as load it into the mysql server (connection details are at the bottom of the download script)
	1. Load the schema for the ensembl_compara_88 manually.  You only need the schema defined, not the data. (If you don't do this you'll get the multi or multi error)

## Upgrading Docker container
1. Build and tag the new docker container locally
	1. docker build -t rsmith/docker-mm-ensembl_api:latest -t rsmith/docker-mm-ensembl_api:r88 .
1. Push docker container to the docker hub repository
	1. docker push rsmith/docker-mm-ensembl_api

## Configuring ECS
1. See mm-documentation on how to restart ensembl containers and link to nginx proxy on backup server
	(Note: containers are run manually on that machine now because ecs was being difficult.  At some point, someone needs to fix that)

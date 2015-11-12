docker-mm-ensembl_api
=====================

Builds an ensembl server that relays API calls to an ensembl database

```
git clone git@github.com:MolecularMatch/docker-mm-ensembl_api.git
cd docker-mm-ensembl_api
docker build -t MolecularMatch/docker-mm-ensembl_api .
docker run --name docker-mm-ensembl_api -it -p 3000:3000 MolecularMatch/docker-mm-ensembl_api bash
```
You may test the connection to ensembl from a prompt
```
perl /opt/src/ensembl/misc-scripts/ping_ensembl.pl
```
And you may test the API by navigating to http://localhost:3000
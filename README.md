# Stratum Taxmap

Work in Progress DO NOT LOOK AT THIS REPO 

Proof of concept to import NYC Digital Taxmap spatial data into a [stratum](https://github.com/mattyschell/stratum)
deployment.

# Dependencies

1. Git [Large File Storage](https://git-lfs.github.com/)
2. PostgreSQL with PostGIS extension (Travis CI tests at PostgreSQL 10.7, PostGIS 2.5)
3. A [Stratum](https://github.com/mattyschell/stratum) deployment.

# Import data

Externalize PostgreSQL connection details for the stratum user.

```shell
$ export PGDATABASE=gis
$ export PGPORT=5432
$ export PGPASSWORD=BeMyDatabaePostGis!
$ export PGHOST=aws.dollar.dollar.bill
```

Run the import script to populate either taxmap_blue or taxmap_green.  This 
script executes as the stratum user regardless of your PGUSER environmental. The 
target tables enforce geometry validity which takes a little time, patience friend. 

```shell
$ ./import.sh taxmap_blue
```

# Integration Tests

Tests that we loaded the data as expected on today's date and stratum_catalog 
metadata looks decent. 

Requires python 3+ in addition to psql.

Should succeed for a public user on the database but the stratum user is fine 
too. Externalize connection details.

```shell
$ export PGDATABASE=gis
$ export PGPASSWORD=BeMyDataBaePostGis!
$ ../stratum_bldg/src/test/run_all_tests.sh taxmap_blue
```


# TMI: Where Did This Data Come From?

You shouldn't read this, it is radically transparent detail describing how 
the vegan data sausage is made.  But you're still reading for some reason.

The New York City Department of Finance maintains maintains the New York City
Digital Tax Map. The [metadata for the NYC Open Data download is here](https://github.com/CityOfNewYork/nyc-geo-metadata/blob/master/Metadata/Metadata_DigitalTaxMap.md).

The Department of Finance maintains this data in a versioned [ESRI](https://www.esri.com/en-us/home)
Enterprise Geodatabase.  The spatial data is stored in ESRI's proprietary SDELOB
format.  Data stored in this format is essentially ransomwared, so the procedure
outlined below is driven by our need to jailbreak the spatial data from the 
database where it is locked up.

Paths and file names below should be changed to protect the innocent.

1. Using ESRI ArcCatalog or the included helper script export the data to the 
dreaded, but interoperable, [shapefile](https://en.wikipedia.org/wiki/Shapefile) format.

Requires python 3 and connectivity to the Dept. of Finance ESRI Geodatabase.

```
> "C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python" /scripts/export_taxmap.py "C:/taxmap.sde" "D:/temp" 
```

2. Set up a scratch PostGIS database that mirrors [stratum](https://github.com/mattyschell/stratum).
The sample steps that follow are on a PostGIS database named 'scratch' under a
taxmap_blue schema. 

```shell
$ psql -c 'create database scratch;'
$ export PGDATABASE=scratch
$ export STRATUMPASSWORD=BeMyDataBae!
$ ./sample_users.sh
```

3. Load the dreaded but interoperable shapefiles into the scratch PostGIS database
using [shp2pgsql](https://postgis.net/docs/using_postgis_dbmanagement.html#shp2pgsql_usage)
or the included helper script.  

Requires bash and shp2pgsql on the path. SQL files will be written to the same 
directory where the shapefiles are located.

```shell
$ ./scripts/shp2sql.sh /d/temp
```

4. Run the sql produced to create new tables named like xxxxtemp. Column 
names will be lopped off because of the dreaded but interoperable shapefile format. 
We could produce a mapping file to avoid the messy column names hitting the
database but we are lazy and prefer to manage things in SQL.

Externalize connection details to a scratch database, the script calls psql.

```shell
$ export PGDATABASE=scratch
$ export PGUSER=gis
$ export PGPASSWORD=BeMyDataBaePostGis!
$ ./scripts/sql2temptables.sh /d/temp
```

5. Insert the scratch data into a more tidy final form. The exact parameters 
buried in these sqls are for now in flux.  Review them.

```shell
./scripts/temptables2finaltables.sh 
```

6. Deal with invalid shapes as you do. Some input shapes are invalid from the 
source.  Some input shapes become invalid in step 4 where we perform some modest
simplification and snapping.  

Helper SQL reminders:

```sql
update xxxxx 
set 
    shape = st_makevalid(shape) 
where 
    objectid = 12345;

update xxxx 
set shape =
    (select st_makevalid(shape) 
     from 
          xxxxtemp 
      where 
          gid = 12345)
where objectid = 67890;
```

7. Dump it

```shell
pg_dump -a -f /d/temp/tax_block_polygon.sql -O -t tax_block_polygon -x
```

8. Zip it

Leaving the process this way because I want human-readable .sql.  Compression
levels above default 6 accomplish little.

```shell
gzip -k xx.sql
```



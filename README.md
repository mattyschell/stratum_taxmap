# Stratum Taxmap

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

You shouldn't read this, it is radically transparent background describing how 
the vegan data sausage is made.  But you're still reading for some reason.

The New York City Department of Finance maintains maintains the New York City
Digital Tax Map. The [metadata for the NYC Open Data download is here](https://github.com/CityOfNewYork/nyc-geo-metadata/blob/master/Metadata/Metadata_DigitalTaxMap.md).

The Department of Finance maintains this data in a versioned [ESRI](https://www.esri.com/en-us/home)
Enterprise Geodatabase.  The spatial data is stored in ESRI's proprietary SDELOB
format.  Data stored in this format is essentially ransomwared, so the procedure
outlined below is driven by our need to jailbreak the spatial data from the 
database where it is locked up.

Paths and file names below should be changed to protect the innocent.

1. Using ESRI ArcCatalog or a script, export the data to the dreaded, but 
interoperable, [shapefile](https://en.wikipedia.org/wiki/Shapefile) format.

```
> "C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python" export_taxmap.py "C:/taxmap.sde" "D:/temp" 
```

2. Load the dreaded but interoperable shapefile into a scratch PostGIS database
using [shp2pgsql](https://postgis.net/docs/using_postgis_dbmanagement.html#shp2pgsql_usage)

```shell
$ shp2pgsql -s 2263 -g shape /d/temp/xx.shp some_featureclasstemp.sql  > /d/temp/xx.sql
```

3. Run the sql produced to create a new table named buildingtemp. Column names 
will be lopped off because of the dreaded but interoperable shapefile format. 
We could produce a mapping file to avoid the messy column names hitting the
database but we are lazy and the SQL below accomplishes the same.

```shell
$ psql -q -f /d/temp/xx.sql
```

4. Insert the scratch data into a more tidy form.  Eliminate buildings that
are under construction, aka "million bins." Remove meaningless vertices and snap
the results to a grid.  The exact parameters below are, and probably will be 
forever, in flux. 

```sql

```

5. Verify that all shapes are valid. If not, deal with them as you do.

```sql
select 
    objectid
   ,ST_IsValidReason(shape) 
from 
    xx 
where 
    st_isvalid(shape) <> true;
```

6. Dump it

```shell
pg_dump -a -f /d/temp/x.sql -n taxmap_blue -O -S stratum -t bldg_blue.xx -x
```

7. Zip it

Leaving the process this way because I want human-readable .sql.  Compression
levels above default 6 accomplish little.

```shell
gzip -k xx.sql
```



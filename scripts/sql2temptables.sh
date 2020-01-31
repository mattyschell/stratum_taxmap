if [[ -z "$1" ]]; then
   echo "missing input directory with sqls"
   exit 1
else
   sqldirectory=$1
fi
echo "loading from $shapefiledirectory/tax_block_polygontemp.sql"
psql -q -f "$sqldirectory/tax_block_polygontemp.sql"
# psql -q -f "$sqldirectory/tax_lot_polygontemp.sql"
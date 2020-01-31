if [[ -z "$1" ]]; then
   echo "missing input directory with shapefiles"
   exit 1
else
   shapefiledirectory=$1
fi
echo "writing sql to $shapefiledirectory/tax_block_polygontemp.sql"
shp2pgsql -s 2263 -g shape "$shapefiledirectory/Tax_Block_Polygon.shp" tax_block_polygontemp > "$shapefiledirectory/tax_block_polygontemp.sql"
# shp2pgsql -s 2263 -g shape "$shapefiledirectory/Tax_Lot_Polygon.shp" tax_lot_polygontemp > "$shapefiledirectory/tax_lot_polygontemp.sql"
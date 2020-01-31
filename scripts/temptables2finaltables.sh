echo "inserting into tax_block_polygon and performing QA"
psql -q -f ./scripts/insert_tax_block_polygon.sql
# echo "inserting into tax_lot_polygon and performing QA"
# psql -q -f insert_tax_lot_polygon.sql

#!/bin/bash

# @param -c Create new table
# @param -s Set SRID
# @param -t Cut raster into tiles to be inserted one per table row. 
#           TILE_SIZE is expressed as WIDTHxHEIGHT
# @param -f Specify name of destination raster column, default is 'rast'
# @param -F Add a column with the name of the file
# @param -n Specify the name of the filename column. Implies -F.
# @param -I Create a GiST index on the raster column.
# @param -M Vacuum analyze the raster table.
# @param -N Set NoData
# @param -k Keeps empty tiles and skips NODATA value checks for each raster 
# @param -l Overviews levels

#
# @Desc: Create a table for topodata images
#
raster2pgsql -c \
             -s 4326 \
             -t 512x512 \
             -f rast \
             -F -n fid \
             -I \
             -M \
             /shared-data/topodata/*.tif \
             public.topodata | psql -U postgres -h localhost -d list2
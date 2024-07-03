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
# @Desc: Create a table for T21LWE tile
#
raster2pgsql -c \
             -s 32721 \
             -t 512x512 -P \
             -f rast \
             -F -n fid \
             -I \
             -M \
             -N 0 -k \
             /shared-data/s2/T21LWE/*.tif \
             public.t21lwe_20240629 | psql -U postgres -h localhost -d list2

#
# Create a table for T21LWF tile
#
raster2pgsql -c \
             -s 32721 \
             -t 512x512 -P \
             -f rast \
             -F -n fid \
             -I \
             -M \
             -N 0 -k \
             /shared-data/s2/T21LWF/*.tif \
             public.t21lwf_20240629 | psql -U postgres -h localhost -d list2
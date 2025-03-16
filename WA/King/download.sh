#!/bin/bash
# download_king_county_parcels.sh
#
# This script downloads the entire King County parcel dataset in GeoJSON format
# from the ArcGIS REST API. It automatically paginates through the results
# using the resultOffset and resultRecordCount parameters.
#
# Requirements:
#   - curl
#   - jq (for parsing JSON to determine the number of features)
#
# Usage:
#   chmod +x download_king_county_parcels.sh
#   ./download_king_county_parcels.sh
#
# The script saves each batch as "king_county_parcels_part_<offset>.geojson".

offset=0
limit=2000

while true; do
    url="https://gisdata.kingcounty.gov/arcgis/rest/services/OpenDataPortal/property__parcel_address_area/MapServer/1722/query?where=1%3D1&outFields=*&f=geojson&outSR=4326&resultOffset=${offset}&resultRecordCount=${limit}"
    outfile="king_county_parcels_part_${offset}.geojson"
    
    echo "Downloading features from offset ${offset}..."
    curl -s "$url" -o "$outfile"
    
    # Count the number of features in the downloaded file using jq
    count=$(jq '.features | length' "$outfile")
    echo "Downloaded ${count} features at offset ${offset}."
    
    # If fewer than the limit, we assume this is the final batch.
    if [ "$count" -lt "$limit" ]; then
        echo "No more features to download. Exiting."
        break
    fi
    
    # Increment the offset for the next batch
    offset=$(( offset + limit ))
done


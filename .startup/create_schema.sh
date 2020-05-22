#!/bin/bash

set -x

IP=$(ifconfig | awk '/inet/ { print $2 }' | egrep -v '^fe|^127|^192|^172|::' | head -1)
IP=${IP#addr:}

if [[ $HOSTNAME == "ds201-node1"* ]] ; then
    #rightscale
    IP=localhost
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    IP=localhost
fi

cd /tmp

echo "Cloning Powertrain repos"
rm -rf /tmp/Powertrain*
git clone https://github.com/beccam/PowertrainStreaming.git 
git clone https://github.com/beccam/Powertrain2.git

cd Powertrain2

echo "Creating Cassandra schema"
cqlsh $IP -f resources/cql/create_schema.cql


echo "Creating Solr Cores"
dsetool -h $IP unload_core vehicle_tracking_app.current_location
dsetool -h $IP create_core vehicle_tracking_app.current_location generateResources=true
dsetool -h $IP unload_core vehicle_tracking_app.vehicle_stats
dsetool -h $IP create_core vehicle_tracking_app.vehicle_stats generateResources=true
dsetool -h $IP unload_core vehicle_tracking_app.vehicle_events
dsetool -h $IP create_core vehicle_tracking_app.vehicle_events generateResources=true

echo "Creating DSE Graph schema"
dse gremlin-console -e resources/graph/load_schema.groovy

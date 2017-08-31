IP="$(ip route get 1 | awk '{print $NF;exit}')"

cd /tmp

echo "Cloning Powertrain repos"
git clone https://github.com/datastax-demos/PowertrainStreaming.git 
git clone https://github.com/datastax-demos/Powertrain2.git

echo "Creating Cassandra schema"
cqlsh $IP -f Powertrain2/resources/cql/create_schema.cql 

echo "Creating Solr Cores"
dsetool -h $IP create_core vehicle_tracking_app.current_location generateResources=true
dsetool -h $IP create_core vehicle_tracking_app.vehicle_stats generateResources=true
dsetool -h $IP create_core vehicle_tracking_app.vehicle_events generateResources=true

echo "Creating DSE Graph schema"
sudo dse gremlin-console -e Powertrain2/resources/graph/load_schema.groovy

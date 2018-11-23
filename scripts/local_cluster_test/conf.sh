
write_replica_conf()
{
	replica_dir="$1"
	port=$2

	rm -f $replica_dir/etc/mongod.conf
	echo "systemLog:" >> $replica_dir/etc/mongod.conf
	echo "  destination: file" >> $replica_dir/etc/mongod.conf
	echo "  logAppend: true" >> $replica_dir/etc/mongod.conf
	echo "  path: $replica_dir/log/mongod.log" >> $replica_dir/etc/mongod.conf

	echo "" >> $replica_dir/etc/mongod.conf
	echo "storage:" >> $replica_dir/etc/mongod.conf
	echo "  dbPath: $replica_dir/data" >> $replica_dir/etc/mongod.conf
	echo "  journal:" >> $replica_dir/etc/mongod.conf
	echo "    enabled: true" >> $replica_dir/etc/mongod.conf
	echo "  directoryPerDB: true" >> $replica_dir/etc/mongod.conf

	echo "" >> $replica_dir/etc/mongod.conf
	echo "processManagement:" >> $replica_dir/etc/mongod.conf
	echo "  fork: true" >> $replica_dir/etc/mongod.conf
	echo "  pidFilePath: $replica_dir/log/mongod.pid" >> $replica_dir/etc/mongod.conf

	echo "" >> $replica_dir/etc/mongod.conf
	echo "net:" >> $replica_dir/etc/mongod.conf
	echo "  port: $port" >> $replica_dir/etc/mongod.conf
	echo "  bindIp: 127.0.0.1" >> $replica_dir/etc/mongod.conf
}

write_configserver_conf()
{
	configserver_dir="$1"
	port=$2

	rm -f $configserver_dir/etc/mongod.conf
	echo "systemLog:" >> $configserver_dir/etc/mongod.conf
	echo "  destination: file" >> $configserver_dir/etc/mongod.conf
	echo "  logAppend: true" >> $configserver_dir/etc/mongod.conf
	echo "  path: $configserver_dir/log/mongod.log" >> $configserver_dir/etc/mongod.conf

	echo "" >> $configserver_dir/etc/mongod.conf
	echo "storage:" >> $configserver_dir/etc/mongod.conf
	echo "  dbPath: $configserver_dir/data" >> $configserver_dir/etc/mongod.conf
	echo "  journal:" >> $configserver_dir/etc/mongod.conf
	echo "    enabled: true" >> $configserver_dir/etc/mongod.conf
	echo "  directoryPerDB: true" >> $configserver_dir/etc/mongod.conf

	echo "" >> $configserver_dir/etc/mongod.conf
	echo "processManagement:" >> $configserver_dir/etc/mongod.conf
	echo "  fork: true" >> $configserver_dir/etc/mongod.conf
	echo "  pidFilePath: $configserver_dir/log/mongod.pid" >> $configserver_dir/etc/mongod.conf

	echo "" >> $configserver_dir/etc/mongod.conf
	echo "net:" >> $configserver_dir/etc/mongod.conf
	echo "  port: $port" >> $configserver_dir/etc/mongod.conf
	echo "  bindIp: 127.0.0.1" >> $configserver_dir/etc/mongod.conf
}

write_route_conf()
{
	route_dir="$1"
	port=$2

	rm -f $route_dir/etc/mongos.conf
	echo "systemLog:" >> $route_dir/etc/mongos.conf
	echo "  destination: file" >> $route_dir/etc/mongos.conf
	echo "  logAppend: true" >> $route_dir/etc/mongos.conf
	echo "  path: $route_dir/log/mongos.log" >> $route_dir/etc/mongos.conf

	echo "" >> $route_dir/etc/mongos.conf
	echo "processManagement:" >> $route_dir/etc/mongos.conf
	echo "  fork: true" >> $route_dir/etc/mongos.conf
	echo "  pidFilePath: $route_dir/log/mongos.pid" >> $route_dir/etc/mongos.conf

	echo "" >> $route_dir/etc/mongos.conf
	echo "net:" >> $route_dir/etc/mongos.conf
	echo "  port: $port" >> $route_dir/etc/mongos.conf
	echo "  bindIp: 0.0.0.0" >> $route_dir/etc/mongos.conf
}
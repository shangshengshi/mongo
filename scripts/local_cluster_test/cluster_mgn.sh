
. ./env.sh
. ./conf.sh
. ./test.sh

[ $# != 1 ] && echo "usage: $0 <deploy | start | stop | clean | test>" && exit 1

if [ x$1 == x"deploy" ];then
	for((i=0; i<${#replicaset_port_array[@]}; i++)) 
	do
		replica_port_array=(${replicaset_port_array[$i]})
		for port in "${replica_port_array[@]}"; do
			[ -d $work_dir/mongod_${port} ] && echo "Error! $work_dir/mongod_${port} already exist!" && exit 1
		done
	done
	for port in "${config_port_array[@]}"; do
		[ -d $work_dir/mongod_${port} ] && echo "Error! $work_dir/mongod_${port} already exist!" && exit 1
	done
	for port in "${route_port_array[@]}"; do
		[ -d $work_dir/mongod_${port} ] && echo "Error! $work_dir/mongod_${port} already exist!" && exit 1
	done

	ln -sf $bin_dir/bin/mongo $work_dir/mongo

	for((i=0; i<${#replicaset_port_array[@]}; i++)) 
	do
		replica_port_array=(${replicaset_port_array[$i]})
		for port in "${replica_port_array[@]}"; do
			mkdir -p $work_dir/mongod_${port}/etc
			mkdir -p $work_dir/mongod_${port}/log
			mkdir -p $work_dir/mongod_${port}/data
			mkdir -p $work_dir/mongod_${port}/bin

			write_replica_conf $work_dir/mongod_${port} ${port}
			ln -sf $bin_dir/bin/mongod $work_dir/mongod_${port}/bin/mongod_${port}

			$work_dir/mongod_${port}/bin/mongod_${port} -f $work_dir/mongod_${port}/etc/mongod.conf --shardsvr --replSet repset_${i}
		done

		cmdstr="rs.initiate({_id: \"repset_${i}\", members: 
								[{_id: 0, host: \"127.0.0.1:${replica_port_array[0]}\"}, 
								{_id: 1, host: \"127.0.0.1:${replica_port_array[1]}\"},
								{_id: 2, host: \"127.0.0.1:${replica_port_array[2]}\"}] } )"
		port=${replica_port_array[0]}
		$work_dir/mongo --host 127.0.0.1 --port $port --quiet --eval "$cmdstr"
	done

	configdbstr="configReplSet"
	for port in "${config_port_array[@]}"; do
		mkdir -p $work_dir/mongod_${port}/etc
		mkdir -p $work_dir/mongod_${port}/log
		mkdir -p $work_dir/mongod_${port}/data
		mkdir -p $work_dir/mongod_${port}/bin

		write_configserver_conf $work_dir/mongod_${port} ${port}
		ln -sf $bin_dir/bin/mongod $work_dir/mongod_${port}/bin/mongod_${port}

		$work_dir/mongod_${port}/bin/mongod_${port} -f $work_dir/mongod_${port}/etc/mongod.conf --configsvr --replSet configReplSet

		[ x"$configdbstr" != x"configReplSet" ] && configdbstr="${configdbstr},127.0.0.1:$port"
		[ x"$configdbstr" == x"configReplSet" ] && configdbstr="${configdbstr}/127.0.0.1:$port"

	done
	cmdstr="rs.initiate({_id: \"configReplSet\", configsvr: true, members: 
								[{_id: 0, host: \"127.0.0.1:${config_port_array[0]}\"},
								{_id: 1, host: \"127.0.0.1:${config_port_array[1]}\"},
								{_id: 2, host: \"127.0.0.1:${config_port_array[2]}\"} ] } )"
	$work_dir/mongo --host 127.0.0.1 --port ${config_port_array[0]} --quiet --eval "$cmdstr"

	for port in "${route_port_array[@]}"; do
		mkdir -p $work_dir/mongos_${port}/etc
		mkdir -p $work_dir/mongos_${port}/log
		mkdir -p $work_dir/mongos_${port}/data
		mkdir -p $work_dir/mongos_${port}/bin

		write_route_conf $work_dir/mongos_${port} ${port}
		ln -sf $bin_dir/bin/mongos $work_dir/mongos_${port}/bin/mongos_${port}

		$work_dir/mongos_${port}/bin/mongos_${port} --configdb $configdbstr -f $work_dir/mongos_${port}/etc/mongos.conf
	done

	for((i=0; i<${#replicaset_port_array[@]}; i++)) 
	do
		replica_port_array=(${replicaset_port_array[$i]})
		port=${replica_port_array[0]}

		cmdstr="db.runCommand({ addshard:\"repset_${i}/127.0.0.1:${port}\", name:\"shard_${i}\", maxsize: 20480})"
		$work_dir/mongo --host 127.0.0.1 --port ${route_port_array[0]} admin --quiet --eval "$cmdstr"
	done

	$work_dir/mongo --host 127.0.0.1 --port ${route_port_array[0]} --quiet --eval "sh.status()"

elif [ x$1 = x"start" ];then
	for((i=0; i<${#replicaset_port_array[@]}; i++)) 
	do
		replica_port_array=(${replicaset_port_array[$i]})
		for port in "${replica_port_array[@]}"; do
			$work_dir/mongod_${port}/bin/mongod_${port} -f $work_dir/mongod_${port}/etc/mongod.conf --shardsvr --replSet repset_${i}
		done
	done
	for port in "${config_port_array[@]}"; do
		$work_dir/mongod_${port}/bin/mongod_${port} -f $work_dir/mongod_${port}/etc/mongod.conf --configsvr --replSet configReplSet
	done
	for port in "${route_port_array[@]}"; do
		$work_dir/mongos_${port}/bin/mongos_${port} --configdb $configdbstr -f $work_dir/mongos_${port}/etc/mongos.conf
	done
elif [ x$1 = x"stop" ];then

	ps -ef | grep mongo | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}

elif [ x$1 == x"clean" ];then

	ps -ef | grep mongo | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}

	for((i=0; i<${#replicaset_port_array[@]}; i++)) 
	do
		replica_port_array=(${replicaset_port_array[$i]})
		for port in "${replica_port_array[@]}"; do
			rm -rf $work_dir/mongod_${port}
		done
	done
	for port in "${config_port_array[@]}"; do
		rm -rf $work_dir/mongod_${port}
	done
	for port in "${route_port_array[@]}"; do
		rm -rf $work_dir/mongos_${port}
	done

	rm -f $work_dir/mongo
elif [ x$1 == x"test" ];then
	basic_test
else
	echo "usage: $0 <deploy | start | stop | clean>" && exit 1
fi

basic_test()
{
	cmdstr="db.runCommand({ enablesharding:\"dbtest\" })"
	$work_dir/mongo --host 127.0.0.1 --port ${route_port_array[0]} admin --quiet --eval "$cmdstr"

	cmdstr="db.runCommand({ shardcollection: \"dbtest.table1\", key: { id:\"hashed\"}})"
	$work_dir/mongo --host 127.0.0.1 --port ${route_port_array[0]} admin --quiet --eval "$cmdstr"

	for ((i=0;i<10;i++))
	do
		cmdstr="db.table1.insert( { id: $i, item1: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 
											item2: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
											item3: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 
											item4: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',  
											qty: 15 } )"
		$work_dir/mongo --host 127.0.0.1 --port ${route_port_array[0]} dbtest --quiet --eval "$cmdstr"
	done
}

script_dir=`cd $(dirname $0); pwd`
work_dir=$script_dir
proj_dir=`cd $script_dir/../..; pwd`

bin_dir_name=mongo_bin
bin_dir=$proj_dir/$bin_dir_name

replicaset_port_array=('27010 27020 27030' '27040 27050 27060' '27070 27080 27090')

config_port_array=(27600 27700 27800)
route_port_array=(27900)

# for test two-dimensional array
port_array2=( '5191 5192'
			  '5193 5194' )
for((i=1; i<${#port_array2[@]}; i++)) 
do
	port_array2_1=(${port_array2[$i]})
	for port in "${port_array2_1[@]}"; do
		echo `expr $port + 1` > /dev/null
	done
done
# end test
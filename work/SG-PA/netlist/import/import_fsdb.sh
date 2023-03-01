#!/bin/bash

sim_dir = $1
lv_flag = $2
shift 2 
LIST = $@

echo sim_dir = $sim_dir
echo lv_flag = $lv_flag
echo "LIST=$LIST"

import_dir=$(dirname $0)
echo import_dir=$import_dir

if [[ -d $sim_dir ]] ; then
    /bin/rm -rf $import_dir/fsdb.list
    for i in $LIST ; do 
        case = $(basename $i .fsdb)
        echo case=$case
        if [[ "$lv_flag" == "0" ]] ; then 
            fsdb=$(find $sim_dir/${case}_*/verdi_file -name ${case}*_000.fsdb | grep -v _lv | xargs ls -t | head -1)
        else
            fsdb=$(find $sim_dir/${case}_*/verdi_file -name ${case}*_000.fsdb | grep _lv | xargs ls -t | head -1)
        fi
        if [[ "$fsdb" != "" ]] ; then
            echo fsdb=$(basename $fsdb)
            cp $fsdb $import_dir/$case.fsdb
            echo "$case.fsdb -> $fsdb" >> $import_dir/fsdb.list
        else
            echo "fsdb not found"
            exit 0
        fi
    done
else
    echo "$sim_dir no exists"
fi

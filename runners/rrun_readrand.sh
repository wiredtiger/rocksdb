#!/bin/bash

# Configurations shared by RocksDB and WiredTiger
mb=67108864	# chunk_size
dds=1		# Disable data sync
sync=0		# Sync writes
opcount=50000000
readcount=500000
threadcount=32
vs=800		# Value size
bs=4096		# Block allocation size
cs=1000000000	# Cache size
si=1000000	# Stats interval
disable_wal=1	# Write ahead logging
data_dir=results

# RocksDB specific configurations
bpl=10485760
overlap=10
mcz=2
del=300000000
levels=6
ctrig=4
delay=8
stop=12
wbn=3
mbc=20
wbs=134217728
of=500000

# Parse command line options.
while getopts "h?d:i:r:s:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 -i opcount -d <data dir> -r <readcount>"
        exit 0
        ;;
    d)  data_dir=$OPTARG
        ;;
    i)  opcount=$OPTARG
        ;;
    r)  readcount=$OPTARG
        ;;
    s)  vs=$OPTARG
        ;;
    esac
done

echo "Load keys sequentially into database....."
( set -x ; ./db_bench --benchmarks=fillseq --disable_seek_compaction=1 --mmap_read=0 --statistics=1 --histogram=1 --num=$opcount --threads=1 --value_size=$vs --block_size=$bs --cache_size=$cs --bloom_bits=10 --cache_numshardbits=6 --open_files=$of --verify_checksum=1 --db=$data_dir --sync=$sync --disable_wal=$disable_wal --compression_type=none --stats_interval=$si --compression_ratio=50 --disable_data_sync=$dds --write_buffer_size=$wbs --target_file_size_base=$mb --max_write_buffer_number=$wbn --max_background_compactions=$mbc --level0_file_num_compaction_trigger=$ctrig --level0_slowdown_writes_trigger=$delay --level0_stop_writes_trigger=$stop --num_levels=$levels --delete_obsolete_files_period_micros=$del --min_level_to_compress=$mcz --max_grandparent_overlap_factor=$overlap --stats_per_interval=1 --max_bytes_for_level_base=$bpl --use_existing_db=0 )

echo "Reading keys in database in random order...."
( set -x ; ./db_bench --benchmarks=readrandom --disable_seek_compaction=1 --mmap_read=0 --statistics=1 --histogram=1 --num=$opcount --reads=$readcount --threads=$threadcount --value_size=$vs --block_size=$bs --cache_size=$cs --bloom_bits=10 --cache_numshardbits=6 --open_files=$of --verify_checksum=1 --db=$data_dir --sync=$sync --disable_wal=$disable_wal --compression_type=none --stats_interval=$si --compression_ratio=50 --disable_data_sync=$dds --write_buffer_size=$wbs --target_file_size_base=$mb --max_write_buffer_number=$wbn --max_background_compactions=$mbc --level0_file_num_compaction_trigger=$ctrig --level0_slowdown_writes_trigger=$delay --level0_stop_writes_trigger=$stop --num_levels=$levels --delete_obsolete_files_period_micros=$del --min_level_to_compress=$mcz --max_grandparent_overlap_factor=$overlap --stats_per_interval=1 --max_bytes_for_level_base=$bpl --use_existing_db=1 )

du -s -k $data_dir

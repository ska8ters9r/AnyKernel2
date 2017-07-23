# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=Chtolly Kernel by krasCGQ @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=ido
} # end properties

# shell variables
block=/dev/block/mmcblk0p22;
is_slot_device=0;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel permissions
# set permissions for included ramdisk files
chmod 750 $ramdisk/init.chtolly.rc;
chmod 755 $ramdisk/init.chtolly.main.sh;
chmod 755 $ramdisk/init.chtolly.lmk.sh;
chmod 755 $ramdisk/sbin/busybox;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# Backup all original files before applying changes
backup_file init.rc;
backup_file init.qcom.rc;
backup_file init.qcom.power.rc;

# Applying changes
# Import Chtolly Kernel init scripts
insert_line init.qcom.rc 'init.chtolly.rc' after 'import init.qcom.usb.rc' 'import init.chtolly.rc';

# Also use exact permissions for powersave cluster
insert_line init.rc 'chown system system /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq' after '    chown system system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' '    chown system system /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq';
insert_line init.rc 'chmod 0660 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq' after '    chmod 0660 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' '    chmod 0660 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq';

# Reduce minimum frequency to 200 MHz on both clusters
replace_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 960000' '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 200000';
replace_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 800000' '    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 200000';
replace_line init.qcom.power.rc '    setprop ro.min_freq_0 960000' '    setprop ro.min_freq_0 200000';
replace_line init.qcom.power.rc '    setprop ro.min_freq_4 800000' '    setprop ro.min_freq_4 200000';

# Limit maximum frequency to 800 MHz on both clusters
insert_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 800000' after '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 200000' '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 800000';
insert_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 800000' after '    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 200000' '    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 800000';

# Interactive tweaks
replace_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "1 960000:85 1113600:90 1344000:80"' '    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "75 960000:85 1113600:90 1344000:80"';
replace_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "1 800000:90"' '    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "80 800000:90"';

# RIP core_ctl
remove_line init.qcom.power.rc '    # Enable core control';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/min_cpus 0';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/max_cpus 4';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres 68';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres 40';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms 100';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/task_thres 4';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster 1';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres 20';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres 5';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms 5000';
remove_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu4/core_ctl/not_preferred 1';

# powersave to ondemand
replace_line init.qcom.power.rc '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "powersave"' '    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "ondemand"'

# Conflicts with default I/O scheduler settings that Spectrum has to set on boot
remove_line init.qcom.power.rc 'on property:dev.bootcomplete=1';
remove_line init.qcom.power.rc '    setprop sys.io.scheduler "bfq"';

# end ramdisk changes

write_boot;

## end install

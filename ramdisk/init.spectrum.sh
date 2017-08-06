#!/system/bin/sh
# SPECTRUM KERNEL MANAGER
# Profile initialization script by nathanchance

# If there is not a persist value or if the profile isn't balanced, we need to set one
if [ ! -f /data/property/persist.spectrum.profile ] || [[ $(cat /data/property/persist.spectrum.profile) != 0 ]]; then
    setprop persist.spectrum.profile 0
fi

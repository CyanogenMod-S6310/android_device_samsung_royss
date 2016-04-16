#!/system/bin/sh
#daniel_hk
#Modified log messages (NV-Dev)

LOG_TAG="BT-CSR7820"
BTUART_PORT=/dev/ttyHS0
BTSTATE=/sys/class/rfkill/rfkill0/state
PSCONFIG=/system/etc/PSConfig_7820.psr

logi ()
{
  /system/bin/log -t $LOG_TAG -p i ": $@"
}

loge ()
{
  /system/bin/log -t $LOG_TAG -p e ": $@"
}

failed ()
{
  loge "$1: exit code $2"
  exit $2
}

#Enable power of CSR chip
logi "Enable BT Power"
echo "1" > $BTSTATE

# PS Config with bccmd
logwrapper /system/bin/bccmd -t bcsp -d $BTUART_PORT -b 115200 psload -r $PSCONFIG
case $? in
  0) logi "CSR BCCMD initialization done.";;
  *) failed "CSR BCCMD initialization failed. Port initialization failure: $BTUART_PORT" $?;
     exit $?;;
esac

# Attach HCI 
logwrapper /system/bin/hciattach -p $BTUART_PORT bcsp 3000000 flow
case $? in
  0) logi "HCI attach done. Attached to port: $BTUART_PORT";;
  *) failed "HCI attach failed. Failed to attach to port: $BTUART_PORT - " $?;
     exit $?;;
esac

exit 0

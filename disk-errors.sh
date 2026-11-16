#!/bin/bash
# Disk / SATA port summary with kernel error counts since last boot.
# Lists NVMe drives, then every physical SATA port per controller (free ports shown as "-").
# ERR = ATA exceptions + command timeouts + I/O errors (sd*), or nvme error/timeout/reset lines.
# Usage: disk-errors.sh [-a]   (-a: also list placeholder ports that report "link down")

all=0; [ "$1" = "-a" ] && all=1
klog=$(journalctl -b 0 -k --no-pager 2>/dev/null)

mnt() {  # short mount name for a block device
  local m=$(lsblk -nro MOUNTPOINT /dev/$1 2>/dev/null | grep -m1 .)
  for x in $(lsblk -nro MOUNTPOINT /dev/$1); do [ "$x" = "/" ] && m=sys; done
  [ -z "$m" ] && m="-"
  echo "${m#/mnt/}"
}

model() {  # short model, e.g. "WDC WD140EDGZ-11B1PA0" -> WD140EDGZ
  local m=$(lsblk -dno MODEL /dev/$1 | xargs)
  m=${m#WDC }
  case "$m" in Samsung\ SSD\ *) m=${m#Samsung SSD }; m=${m// /} ;; *) m=${m%% *} ;; esac
  echo "$m" | sed -E 's/-[0-9][0-9A-Z]{5,}$//'
}

row() { printf "%-8s %-6s %-12s %-6s %-6s %-6s %s\n" "$@"; }

echo "$(hostname) | last reboot: $(uptime -s) ($(uptime -p)) | errors counted since then"
row DEV SIZE MODEL MOUNT CTRL PORT ERR

# NVMe
for d in $(ls /sys/block | grep -E '^nvme[0-9]+n[0-9]+$' | sort -V); do
  c=${d%n*}
  e=$(echo "$klog" | grep -ciE "$c(n[0-9]+)?:.*(timeout|reset|error)")
  row $d $(lsblk -dno SIZE /dev/$d | xargs) $(model $d) $(mnt $d) NVMe - "$e$([ $e -gt 0 ] && echo ' !')"
done

# SATA controllers in PCI order; Intel onboard = "Intel", add-in cards = card1, card2, ...
n=0
for pci in $(for p in /sys/class/ata_port/ata*; do readlink -f $p/device | grep -oE '0000:[0-9a-f]{2}:[0-9a-f]{2}\.[0-9]' | tail -1; done | sort -u); do
  if lspci -s ${pci#0000:} | grep -q Intel; then ctrl=Intel; else n=$((n+1)); ctrl=card$n; fi
  seen_real=0
  for port in $(ls -d /sys/bus/pci/devices/$pci/ata* 2>/dev/null | xargs -n1 basename | sort -V); do
    if echo "$klog" | grep -qE " $port: DUMMY"; then
      # dummy after real ports = end of the physical ports on this controller
      [ $seen_real -eq 1 ] && [ $all -eq 0 ] && break
      continue
    fi
    seen_real=1
    d=$(ls /sys/bus/pci/devices/$pci/$port/host*/target*/*/block 2>/dev/null | head -1)
    if [ -z "$d" ]; then
      row - - - - $ctrl $port -
      continue
    fi
    e=$(echo "$klog" | grep -cE " $port\.00: exception|\[$d\].*timing out|I/O error, dev $d,")
    row $d $(lsblk -dno SIZE /dev/$d | xargs) $(model $d) $(mnt $d) $ctrl $port "$e$([ $e -gt 0 ] && echo ' !')"
  done
done

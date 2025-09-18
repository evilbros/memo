#!/bin/bash

ids=$@

[ ! "$ids" ] && echo "$0 ids..." && exit 1

# ask
read -p "Are you sure to do post merge operations ? [Yes/No]" x
[ "$x" != "Yes" ] && exit 1

# -------- backup --------

BAK_DIR=backup

echo "backup files"
rm -rf $BAK_DIR
mkdir -p $BAK_DIR
cp -r config PORTS STEP_SERVER $BAK_DIR

# -------- remove from STEP_SERVER file --------

echo "remove from STEP_SERVER"
cat STEP_SERVER | grep -Ewv $(printf "|s%s" $ids | sed 's/^|//') > STEP_SERVER

# -------- remove from PORTS --------

if [ "$(<PORTS)" ]; then
    echo "remove from PORTS"

    # get portids to be removed by visiting config
    portids=$(
        cat $(printf "config/Server%s.cfg " $ids) 2>/dev/null \
            | grep ExternalGatePort \
            | sed 's/ExternalGatePort=//' \
            | awk '{print $1 % 100}'
    )

    # remove in PORTS file
    [ "$portids" ] && cat PORTS | grep -Ewv $(printf "|%s" $portids | sed 's/^|//') > PORTS
fi

# -------- remove ServerX.cfg --------

echo "remove ServerX.cfg ..."
rm -rf $(printf "config/Server%s.cfg " $ids)

# -------- done --------

echo "$(hostname) => Done."

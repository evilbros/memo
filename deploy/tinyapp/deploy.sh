#!/bin/bash

DEPLOY_DIR=$(pwd)
APPS_DIR="/data/apps"
VOLUMES_DIR="/data/volumes"
WEB_PREFIX="/app"

# params
url=$1
subdir=$2

[ ! $url ] && echo "$0 git-url [subdir]" && exit 1

# clone project
tmp_dir=$(mktemp -d tmp-proj-XXX)
proj_dir=$tmp_dir
[ $subdir ] && proj_dir+="/$subdir"

git clone --depth 1 $url $tmp_dir
cd $proj_dir

# source deploy file
[ ! -f DEPLOY ] && echo "DEPLOY file not found" && exit 1
. DEPLOY

# pack
echo "packing ..."
bash -c "$PACK_CMD"

# stop app
echo "stopping app ..."
if [ -d $APPS_DIR/$NAME ]; then
    cd $APPS_DIR/$NAME
    bash -c "$STOP"
fi

# update app
echo "updating app ..."
cd $DEPLOY_DIR/$proj_dir

rm -rf $APPS_DIR/$NAME
mv $BIN_DIR $APPS_DIR/$NAME

# mount volumes
cd $APPS_DIR/$NAME

for v in "${VOLUMES[@]}"; do
    ln -sfn $VOLUMES_DIR/$NAME/$v $v
done

# nginx config
nginx_config=$(
for v in "${PROXIES[@]}"; do
    location=${v%:*}
    port=${v#*:}

    location=${location%/}

    echo "location $WEB_PREFIX/$NAME$location/ {"
    echo "    proxy_pass http://127.0.0.1:$port/;"
    echo "}"
    echo ""
done

for v in "${STATICS[@]}"; do
    location=${v%:*}
    folder=${v#*:}

    location=${location%/}

    echo "location $WEB_PREFIX/$NAME$location {"
    echo "    alias $APPS_DIR/$NAME$folder;"
    echo "}"
    echo ""
done
)

sudo tee /etc/nginx/apps/$NAME <<EOF > /dev/null
$nginx_config
EOF

sudo service nginx reload

# start app
echo "starting app ..."
bash -c "$START"

# cleanup
echo "clean up"
cd $DEPLOY_DIR
rm -rf $tmp_dir

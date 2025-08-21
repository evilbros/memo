#!/bin/bash

DEPLOY_DIR=$(realpath .)
APPS_DIR=$(realpath ~/apps)
VOLUMES_DIR=$(realpath ~/volumes)
WEB_PREFIX="/app"

# params
url=$1
[ ! "$url" ] && echo "$0 git-url" && exit 1

# clone project
proj_dir=$(mktemp -d tmp-proj-XXX)
git clone --depth 1 $url $proj_dir
cd $proj_dir

# source deploy file
[ ! -f DEPLOY ] && echo "DEPLOY file not found" && exit 1
. DEPLOY

# pack
echo "packing ..."
./pack.sh

# extract
bin_dir=${TAR_FILE%.tar.gz}
tar -xf $TAR_FILE

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
mv $bin_dir $APPS_DIR/$NAME

# mount volumes
cd $APPS_DIR/$NAME

for v in "${VOLUMES[@]}"; do
    ln -sf $VOLUMES_DIR/$NAME/$v $v
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
rm -rf $proj_dir


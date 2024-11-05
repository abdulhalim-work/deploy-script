#!/bin/bash

REPO=$1
DEPLOY_DIR=$2

if [ -d $DEPLOY_DIR ]; then
	
	DEST_DIR="old_versions"
	I=1
	
	while [ -d "$DEST_DIR/${DEPLOY_DIR}_${I}" ]; do
  		I=$((I + 1))
	done

	mv $DEPLOY_DIR "old_versions/${DEPLOY_DIR}_${I}"

	rm -r "old_versions/${DEPLOY_DIR}_${I}/vendor"
	rm -r "old_versions/${DEPLOY_DIR}_${I}/node_modules"
	rm -r "old_versions/${DEPLOY_DIR}_${I}/storage"
	rm -r "old_versions/${DEPLOY_DIR}_${I}/public/build"


	mkdir -p $DEPLOY_DIR
else
	mkdir -p $DEPLOY_DIR
fi

git clone https://$(cat ~/github_token)@github.com/$REPO $DEPLOY_DIR

if [ -f .env ]; then
	cp .env $DEPLOY_DIR
else
	echo "gen .env file"
fi

cd $DEPLOY_DIR
composer install
php artisan migrate
php artisan migrate:fresh --seed
php artisan key:generate
php artisan ziggy:generate

npm install
npm run build


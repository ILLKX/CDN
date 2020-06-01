cp -r /bitw/* /bitwbac/
cd /bitwbac/
sqlite3 /bitw/db.sqlite3 ".backup '/bitwbac/dbb.sqlite3'"
rm -f db.sqlite3
rm -rf icon_cache/
mv dbb.sqlite3 db.sqlite3
time=$(date "+%Y%m%d_%H%M%S")
zip -9rq bitwbac${time}.zip *
rclone copy bitwbac${time}.zip gd:/bitwarden/
rm -rf /bitwbac/*
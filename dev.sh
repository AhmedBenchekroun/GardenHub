app="gardenhub"

# Build the docker container
function build() {
  echo "Building $app image"
  docker build -t $app .
}

# Test whether the database is up
function test_db() {
  docker run --rm --network=host \
    -e PGPASSWORD=$app \
    postgres:10-alpine \
    sh -c 'psql -h "0.0.0.0" -p '$db_port' -U "postgres" -c "\q"' &> /dev/null
}

# Start database container
function start_db() {
  # Create volume
  docker volume create ${app}_pgdata
  # Run Postgres
  docker run --rm \
    --name ${app}_db \
    -v ${app}_pgdata:/var/lib/postgresql/data \
    -p 0:5432 \
    -e POSTGRES_PASSWORD=$app \
    -d postgres:10-alpine $@
  # Get DB port
  regex="5432\/tcp -> 0\.0\.0\.0:([0-9]+)"
  if [[ $(docker port ${app}_db) =~ $regex ]]
  then
      db_port="${BASH_REMATCH[1]}"
      echo "Database is listening at port ${db_port}"
  fi
  # Wait for db before continuing
  until test_db -eq 0; do
    echo "Postgres is still starting up..."
    sleep 1
  done
}

# Stop the database container if it's not in use
function stop_db() {
  # Get number of app containers running
  n=$(docker ps -f ancestor=$app --format '{{.Names}}' | wc -l)
  # If 0 app containers are running, stop the db container
  if [ $n -eq 0 ]; then
    docker stop ${app}_db 2> /dev/null
  fi
}

function manage_py() {
  # Build the image if it isn't already
  if ! docker image inspect $app > /dev/null; then
    build
  fi
  # Start Postgres first if it isn't
  start_db 2> /dev/null
  # Run the app container
  docker run --rm -it \
    -p 8000:8000 \
    --network=host \
    -e PYTHONUNBUFFERED=0 \
    -e DATABASE_URL="postgres://postgres:${app}@0.0.0.0:${db_port}/postgres" \
    -v $(pwd):/app \
    $app python manage.py $@
  # Stop Postgres if it's no longer being used
  stop_db
}

# Run containers
function start() {
  manage_py migrate
  manage_py runserver
}

# Pull database from staging to local
function pulldb() {
  docker stop ${app}_db 2> /dev/null # Force stop db
  docker volume rm ${app}_pgdata
  docker volume create ${app}_pgdata
  ssh dokku@candlewaster.co postgres:export $app > db.dump
  start_db
  docker cp db.dump ${app}_db:/db.dump
  docker exec -it ${app}_db sh -c \
    "pg_restore -U postgres -d postgres /db.dump && rm /db.dump"
  echo "Successfully restored staging database!"
  stop_db
}

# Pull media files from staging
function pullmedia() {
  mkdir -p media
  ssh gardenhub@candlewaster.co s3cmd get s3://gardenhub/gardenhub --recursive
  rsync -av gardenhub@candlewaster.co:~/gardenhub/ ./media
  ssh gardenhub@candlewaster.co rm -r gardenhub
}

# Serve docs
function servedocs() {
  docker run --rm -it \
    -p 8000:8000 \
    --network=host \
    -e PYTHONUNBUFFERED=0 \
    -v $(pwd):/app \
    $app sh -c "cd /app/docs && sphinx-autobuild -b html . _build/html"
}

# Options
case $1 in
  setup)
    sudo sh -c "wget -nv -O - https://get.docker.com/ | sh"
    ;;
  build) build ;;
  start) start ;;
  manage.py)
    shift
    manage_py $@
    ;;
  docs) servedocs ;;
  pulldb) pulldb ;;
  pullmedia) pullmedia ;;
  *)
    echo "$app local development script"
    echo ""
    echo "usage: ./dev.sh <command> [<args>]"
    echo ""
    echo "Commands:"
    echo "    start      Run the app for local development on port 8000."
    echo "    build      Manually (re)build the app container."
    echo "    manage.py  Runs python manage.py <args> in the app container."
    echo "    setup      Installs Docker."
    echo "    docs       Runs a local server for the docs on port 8000."
    echo ""
    echo "Staging sync (permission required):"
    echo "    pulldb     Downloads db from staging."
    echo "    pullmedia  Downloads media files from staging."
esac

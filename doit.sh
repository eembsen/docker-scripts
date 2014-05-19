# Create master and minion containers

cd $HOME

if [ ! -d .ssh ]; then

  echo "Missing ssh private/public key pair!"
  echo "Run ssh-keygen on the command line."

  exit 1

fi

# Create salt master ...
cp ./docker-scripts/salt/master/Dockerfile .
docker build --rm=true -t salt-master .

# Start the salt master ...
master_cid=`docker run -p 2222:22 -d salt-master`
master_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $master_cid`

# Make minion config snippet setting the ip of the salt master ...
echo "master: $master_ip" > master.conf 

# Create the salt minion ...
cp ./docker-scripts/salt/minion/Dockerfile .
docker build --rm=true -t salt-minion .

# Start the salt minion ...
docker run -p 2223:22 -d salt-minion

exit 0

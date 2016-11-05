# Geoff

A program that drives a roomba around and tries to act like it's alive.

## Setup Pi

Geoff runs on a raspberry pi 3 that rides along on the robot.
In order to get Geoff up and running you should bootup a raspberry pi with a jessie-lite image.
Then setup wifi and internationalization settings and run the following commands as root.

```
echo "deb http://packages.erlang-solutions.com/debian wheezy contrib" >> /etc/apt/sources.list
wget http://packages.erlang-solutions.com/debian/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc && rm erlang_solutions.asc
sudo apt-get update
apt-get install -y --force-yes erlang-mini
mkdir /opt/elixir
curl  -L https://github.com/elixir-lang/elixir/releases/download/v1.3.4/Precompiled.zip -o /opt/elixir/precompiled.zip
cd /opt/elixir
unzip precompiled.zip
echo 'export PATH=/opt/elixir/bin:$PATH' >> /etc/bash.bashrc
export PATH=/opt/elixir/bin:$PATH
/opt/elixir/bin/mix local.hex --force
/opt/elixir/bin/mix local.rebar --force
```

Now send your local copy of this repo to the raspberry pi with a command like:

```
rsync -avz --exclude .git --exclude _build . pi@geoff.local:~/geoff
```

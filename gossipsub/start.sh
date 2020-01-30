#!/bin/bash -xe
  
retry_run() {
        n=0
        set -e
        until [ $n -ge $RETRIES ]
        do
          $@ && break
          n=$[$n+1]
          sleep $RETRY_DELAY
        done
        set +e
}

IFS=$'\r\n' GLOBIGNORE='*' command eval  'IP=($(cat ./IP.txt))'
# echo ${IP[@]:0:COUNT}
IFS=$'\r\n' GLOBIGNORE='*' command eval  'MADDR=($(cat ./MADDR.txt))'
# echo ${MADDR[@]:0:COUNT}
IFS=$'\r\n' GLOBIGNORE='*' command eval  'PEERS=($(cat ./peers.txt))'
# echo ${PEERS[@]:0:COUNT}

deploy_host() {
  ./cmd/host/host --pem ./pk.pem 
#--log /topology/output_$SELF.log
}

peer() {
  for peer in ${PEERS[@]}
  do if [ $peer != $SELF ]
    then tmux new -s host -d; tmux send-keys -thost "./cmd/client/client open-peers /ip4/${IP[peer]}/tcp/3000/ipfs/${MADDR[peer]}" C-m
  fi
  done
}

start() {
  deploy_host
  sleep 10
  peer
}

start

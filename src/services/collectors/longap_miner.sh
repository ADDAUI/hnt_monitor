#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=longap
endpoint=status
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${longap_test_url:-"${longap_url}/hotspot/status/${a}"}
  url="${url}"
  log_info "getting ${miner} ${endpoint} for ${a}"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(longap_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/miner.${miner}/${a}.${endpoint}"
  log_info "${miner} miner ${a} ${endpoint} ready to process"
  log_debug "${endpoint} \n${payload}\n\n"

  sleep "${longap_data_interval}"
  rm_lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
}


for a in ${longap_addresses}; do
  make_dir "${data_dir}/miner.${miner}"

  lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
  get &

  sleep 1
done

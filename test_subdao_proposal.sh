BIN=neutrond

CORE_CONTRACT=./artifacts/cwd_subdao_core.wasm
PROPOSAL_SINGLE_CONTRACT=./artifacts/cwd_subdao_proposal_single.wasm
TIMELOCK_SINGLE_CONTRACT=./artifacts/cwd_subdao_timelock_single.wasm
CW4_VOTING_CONTRACT=./artifacts/cw4_voting.wasm
CW4_GROUP_CONTRACT=./artifacts/cw4_group.wasm
PRE_PROPOSE_SINGLE_CONTRACT=./artifacts/cwd_subdao_pre_propose_single.wasm

CHAIN_ID_1=test-1

NEUTRON_DIR=${NEUTRON_DIR:-../neutron}
HOME_1=${NEUTRON_DIR}/data/test-1/

USERNAME_1=demowallet1
ADMIN_ADDR=$(${BIN} keys show ${USERNAME_1} -a --keyring-backend test --home ${HOME_1})

echo """
#############################################################################
#
# Uploading the subDAO contracts
#
#############################################################################
"""

# Upload the core contract (1 / 6)
RES=$(${BIN} tx wasm store ${CORE_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
CORE_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "CORE_CONTRACT_CODE_ID:" $CORE_CONTRACT_CODE_ID

# Upload the cw4 voting contract (2 / 6)
RES=$(${BIN} tx wasm store ${CW4_VOTING_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
CW4_VOTE_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "CW4_VOTE_CONTRACT_CODE_ID:" $CW4_VOTE_CONTRACT_CODE_ID

# Upload the cw4 group contract (3 / 6)
RES=$(${BIN} tx wasm store ${CW4_GROUP_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
CW4_GROUP_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "CW4_GROUP_CONTRACT_CODE_ID:" $CW4_GROUP_CONTRACT_CODE_ID

# Upload the pre propose contract (4 / 6)
RES=$(${BIN} tx wasm store ${PRE_PROPOSE_SINGLE_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
PRE_PROPOSE_SINGLE_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "PRE_PROPOSE_SINGLE_CONTRACT_CODE_ID:" $PRE_PROPOSE_SINGLE_CONTRACT_CODE_ID

# Upload the proposal contract (5 / 6)
RES=$(${BIN} tx wasm store ${PROPOSAL_SINGLE_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
PROPOSAL_SINGLE_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "PROPOSAL_SINGLE_CONTRACT_CODE_ID:" $PROPOSAL_SINGLE_CONTRACT_CODE_ID

# Upload the timelock contract (6 / 6)
RES=$(${BIN} tx wasm store ${TIMELOCK_SINGLE_CONTRACT} --from ${USERNAME_1} --gas 50000000 --chain-id ${CHAIN_ID_1} --broadcast-mode=block --gas-prices 0.0025stake -y --output json  --keyring-backend test --home ${HOME_1} --node tcp://127.0.0.1:16657)
TIMELOCK_SINGLE_CONTRACT_CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')
echo "TIMELOCK_SINGLE_CONTRACT_CODE_ID:" $TIMELOCK_SINGLE_CONTRACT_CODE_ID

echo """
#############################################################################
#
# Instantiating the timelock contract
#
#############################################################################
"""

TIMELOCK_SINGLE_CONTRACT_INIT_MSG='{
  "timelock_duration": 60,
  "owner": {
    "address": {
      "addr": "'"${ADMIN_ADDR}"'"
    }
  }
}'

RES=$(${BIN} tx wasm instantiate $TIMELOCK_SINGLE_CONTRACT_CODE_ID "$TIMELOCK_SINGLE_CONTRACT_INIT_MSG" --from ${USERNAME_1} --admin ${ADMIN_ADDR} -y --chain-id ${CHAIN_ID_1} --output json --broadcast-mode=block --label "init"  --keyring-backend test --gas-prices 0.0025stake --gas auto --gas-adjustment 1.4 --home ${HOME_1} --node tcp://127.0.0.1:16657)
TIMELOCK_SINGLE_CONTRACT_ADDR=$(echo $RES | jq -r '.logs[0].events[0].attributes[0].value')
echo "TIMELOCK_SINGLE_CONTRACT_ADDR:" $TIMELOCK_SINGLE_CONTRACT_ADDR

echo """
#############################################################################
#
# Instantiating the core subDAO contract
#
#############################################################################
"""

# -------------------- PROPOSE { PRE-PROPOSE } --------------------

# PRE_PROPOSE_INIT_MSG will be put into the PROPOSAL_SINGLE_INIT_MSG
PRE_PROPOSE_INIT_MSG='{
  "deposit_info": {
    "denom": {
      "token": {
        "denom": {
          "native": "untrn"
        }
      }
    },
    "amount": "10",
    "refund_policy": "always"
  },
  "open_proposal_submission": false,
  "timelock_contract": "'"${TIMELOCK_SINGLE_CONTRACT_ADDR}"'"
}'
PRE_PROPOSE_INIT_MSG_BASE64=$(echo ${PRE_PROPOSE_INIT_MSG} | base64)

PROPOSAL_SINGLE_INIT_MSG='{
  "threshold": {
    "absolute_count": {
      "threshold": "1"
    }
  },
  "max_voting_period": {
    "time": 60
  },
  "allow_revoting": false,
  "close_proposal_on_execution_failure": true,
  "pre_propose_info": {
    "ModuleMayPropose": {
      "info": {
        "code_id": '"${PRE_PROPOSE_SINGLE_CONTRACT_CODE_ID}"',
        "label": "Neutron subDAO pre propose",
        "msg": "'"${PRE_PROPOSE_INIT_MSG_BASE64}"'"
      }
    }
  }
}'
PROPOSAL_SINGLE_INIT_MSG_BASE64=$(echo ${PROPOSAL_SINGLE_INIT_MSG} | base64)

# -------------------- VOTE MODULE --------------------

CW4_VOTE_INIT_MSG='{
  "cw4_group_code_id": '"${CW4_GROUP_CONTRACT_CODE_ID}"',
  "initial_members": [
    {
      "addr": "'"${ADMIN_ADDR}"'",
      "weight": 10
    }
  ]
}'
CW4_VOTE_INIT_MSG_BASE64=$(echo ${CW4_VOTE_INIT_MSG} | base64)

# -------------------- CORE MODULE --------------------

CORE_CONTRACT_INIT_MSG='{
  "name": "Neutron subDAO",
  "description": "Neutron subDAO",
  "initial_items": null,
  "vote_module_instantiate_info": {
    "code_id": '"${CW4_VOTE_CONTRACT_CODE_ID}"',
    "label": "Neutron subDAO vote module",
    "msg": "'"${CW4_VOTE_INIT_MSG_BASE64}"'"
  },
  "proposal_modules_instantiate_info": [
    {
      "code_id": '"${PROPOSAL_SINGLE_CONTRACT_CODE_ID}"',
      "label": "DAO_Neutron_cw-proposal-single",
      "msg": "'"${PROPOSAL_SINGLE_INIT_MSG_BASE64}"'"
    }
  ]
}'

RES=$(${BIN} tx wasm instantiate $CORE_CONTRACT_CODE_ID "$CORE_CONTRACT_INIT_MSG" --from ${USERNAME_1} --admin ${ADMIN_ADDR} -y --chain-id ${CHAIN_ID_1} --output json --broadcast-mode=block --label "init"  --keyring-backend test --gas-prices 0.0025stake --gas auto --gas-adjustment 1.4 --home ${HOME_1} --node tcp://127.0.0.1:16657)
CORE_CONTRACT_ADDR=$(echo $RES | jq -r '.logs[0].events[0].attributes[0].value')
echo "CORE_CONTRACT_ADDR:" $CORE_CONTRACT_ADDR
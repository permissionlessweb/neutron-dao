use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{Addr, Uint128};
use cwd_interface::voting::{
    BondingStatusResponse, InfoResponse, TotalPowerAtHeightResponse, VotingPowerAtHeightResponse,
};
use cwd_macros::{info_query, voting_query, voting_vault, voting_vault_query};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, JsonSchema, Debug, Clone)]
pub struct InstantiateMsg {
    /// Name contains the vault name which is used to ease the vault's recognition.
    pub name: String,
    /// Description contains information that characterizes the vault.
    pub description: String,
    /// The lockdrop contract behind the vault.
    pub lockdrop_contract: String,
    /// The USDC/NTRN CL pool contract.
    pub usdc_cl_pool_contract: String,
    /// The ATOM/NTRN CL pool oracle contract.
    pub atom_cl_pool_contract: String,
    /// Owner can update all configs including changing the owner. This will generally be a DAO.
    pub owner: String,
}

#[voting_vault]
#[derive(Serialize, Deserialize, JsonSchema, Debug, Clone)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    UpdateConfig {
        owner: Option<String>,
        lockdrop_contract: Option<String>,
        usdc_cl_pool_contract: Option<String>,
        atom_cl_pool_contract: Option<String>,
        name: Option<String>,
        description: Option<String>,
    },
}

#[voting_query]
#[voting_vault_query]
#[info_query]
#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(crate::types::Config)]
    Config {},
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, Eq, JsonSchema)]
pub struct MigrateMsg {}

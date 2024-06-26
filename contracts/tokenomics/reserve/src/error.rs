use cosmwasm_std::{Decimal, OverflowError, StdError, Uint128};
use exec_control::pause::PauseError;
use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum ContractError {
    #[error(transparent)]
    Std(#[from] StdError),

    #[error(transparent)]
    PauseError(#[from] PauseError),

    #[error("Unauthorized")]
    Unauthorized {},

    #[error("No funds to distribute")]
    NoFundsToDistribute {},

    #[error("distribution_rate must be between 0 and 1")]
    InvalidDistributionRate {},

    #[error("vesting_denominator must be greater than zero")]
    InvalidVestingDenominator {},

    #[error("min_period must be greater than zero")]
    InvalidMinPeriod {},

    #[error("Too soon to distribute")]
    TooSoonToDistribute {},

    #[error("no coins were burned, nothing to distribute")]
    NoBurnedCoins {},

    #[error("Unknown reply ID {reply_id}")]
    UnkownReplyID { reply_id: u64 },

    #[error("{denom} balance {final_balance} after liquidity withdrawal and providing doesn't match the initial one {initial_balance}")]
    MigrationBalancesMismatch {
        denom: String,
        initial_balance: Uint128,
        final_balance: Uint128,
    },

    #[error(
        "Amount to be migrated is greater that the max available amount: {amount} > {max_amount}"
    )]
    MigrationAmountUnavailable {
        amount: Uint128,
        max_amount: Uint128,
    },

    #[error(
        "Provided slippage tolerance {slippage_tolerance} is more than the max allowed {max_slippage_tolerance}"
    )]
    MigrationSlippageToBig {
        slippage_tolerance: Decimal,
        max_slippage_tolerance: Decimal,
    },

    #[error("Migration from xyk pairs to CL ones is complete: nothing to migrate")]
    MigrationComplete {},

    #[error("Overflow")]
    OverflowError(#[from] OverflowError),
}

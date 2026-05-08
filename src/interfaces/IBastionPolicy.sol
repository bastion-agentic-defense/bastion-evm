// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IBastionPolicy
/// @notice Policy engine for defining agent transaction rules.
/// Based on the policy pattern from ERC-7579 validator hooks.
interface IBastionPolicy {
    /// @notice A policy rule for an agent.
    struct Policy {
        address agent;
        bool isActive;
        uint256 maxValuePerTx;
        uint256 maxGasPerTx;
        uint256 dailyTxLimit;
        uint256 cooldownSeconds;
        address[] allowedTargets;
        bytes4[] allowedSelectors;
        bytes extraData;
    }

    /// @notice Set a policy for an agent.
    function setPolicy(address agent, Policy calldata policy) external;

    /// @notice Remove a policy for an agent.
    function removePolicy(address agent) external;

    /// @notice Check if a transaction is allowed under the agent's policy.
    function checkTransaction(
        address agent,
        address target,
        uint256 value,
        bytes calldata callData
    ) external view returns (bool allowed, bytes memory reason);

    /// @notice Get the policy for an agent.
    function getPolicy(address agent) external view returns (Policy memory);

    /// @notice Get the current transaction count for an agent in the current window.
    function getTxCount(address agent) external view returns (uint256);

    error AgentNotRegistered(address agent);
    error PolicyAlreadyExists(address agent);
    error TargetNotAllowed(address agent, address target);
    error SelectorNotAllowed(address agent, bytes4 selector);
    error ValueExceedsLimit(address agent, uint256 value, uint256 limit);
    error GasExceedsLimit(address agent, uint256 gas, uint256 limit);
    error DailyTxLimitExceeded(address agent, uint256 count);
    error CooldownNotElapsed(address agent, uint256 remaining);
}

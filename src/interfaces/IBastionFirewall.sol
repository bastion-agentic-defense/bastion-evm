// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IBastionFirewall
/// @notice ERC-7579 compatible validator module for autonomous agent transaction firewall.
/// Implements the IValidator interface from ERC-7579 for modular smart accounts.
/// See: https://eips.ethereum.org/EIPS/eip-7579
interface IBastionFirewall {
    /// @notice Validate a user operation before execution.
    /// @param userOp The user operation to validate.
    /// @param userOpHash The hash of the user operation.
    /// @return validationData Packed validation result per ERC-4337.
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) external returns (uint256 validationData);

    /// @notice Check whether this validator is valid for a given account.
    /// @param account The smart account address.
    /// @return magicValue ERC-1271 magic value if valid.
    function isValidForAccount(address account) external view returns (bytes4 magicValue);

    /// @notice Called when this validator is installed on an account.
    /// @param data Optional installation data.
    function onInstall(bytes calldata data) external;

    /// @notice Called when this validator is uninstalled from an account.
    /// @param data Optional uninstallation data.
    function onUninstall(bytes calldata data) external;

    /// @notice Emitted when an agent transaction is allowed through the firewall.
    event TransactionAllowed(
        address indexed agent,
        address indexed target,
        bytes4 indexed selector,
        uint256 value,
        uint256 timestamp
    );

    /// @notice Emitted when an agent transaction is blocked by the firewall.
    event TransactionBlocked(
        address indexed agent,
        address indexed target,
        bytes4 indexed selector,
        uint256 value,
        uint256 timestamp,
        bytes reason
    );

    /// @notice Emitted when a firewall policy is updated.
    event PolicyUpdated(
        address indexed agent,
        address indexed target,
        bytes4 selector,
        bool allowed,
        uint256 timestamp
    );

    error NotAuthorized(address agent, address target, bytes4 selector);
    error PolicyNotSet(address agent);
    error ValueExceedsLimit(uint256 value, uint256 limit);
    error GasExceedsLimit(uint256 gas, uint256 limit);
    error RateLimitExceeded(address agent, uint256 windowStart);
    error InvalidValidatorData();
}

/// @notice Packed user operation struct per ERC-4337 v0.7.
struct PackedUserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    bytes32 accountGasLimits;
    uint256 preVerificationGas;
    bytes32 gasFees;
    bytes paymasterAndData;
    bytes signature;
}

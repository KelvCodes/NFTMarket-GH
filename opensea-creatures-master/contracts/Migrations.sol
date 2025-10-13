// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Migrations
 * @dev This contract is used by Truffle to manage deployment versions.
 *      It keeps track of the last migration completed and allows upgrading
 *      to a new Migrations contract address if necessary.
 */
contract Migrations {
    // The owner of the contract (usually the deployer)
    address public owner;

    // Stores the number of the last migration that was completed
    uint public last_completed_migration;

    /**
     * @dev Sets the deployer as the owner of the contract
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Modifier to restrict access to only the owner
     */
    modifier restricted() {
        // Only allow the owner to execute the function
        if (msg.sender == owner) _;
    }

    /**
     * @dev Sets the last completed migration number
     * @param completed The migration number to record as completed
     */
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    /**
     * @dev Allows upgrading to a new Migrations contract
     *      and sets the last completed migration in the new contract
     * @param new_address The address of the new Migrations contract
     */
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}


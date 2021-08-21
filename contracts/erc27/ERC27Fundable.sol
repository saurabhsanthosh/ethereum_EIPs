// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC27Escrow.sol";
import "./ERC27.sol";


/**
 * @dev Additional contract of the ERC27 standard with support for democratic funding.
 * This interface can be used if the users of the contract need to fund the contract with ETH
 * in a democratic way.
 */
contract ERC27Fundable is ERC27 {

    ERC27Escrow public escrow;

    constructor(address[] memory _members) ERC27(_members)  {
        escrow = new ERC27Escrow();
    }

    /**
     * @dev Allows the ERC27 contract to withdraw `_value` wei belonging to `_from` from the escrow contract
     *
     * So if 2 users have to fund the ERC27 contract, they will create action in following way
     * Action :
     *      withdraw(user1_address, 1 * 10^18)
     *      withdraw(user2_address, 1 * 10^18)
     *
     * Before approving and executing the above action, both users have to fund the escrow account with the needed amount of ETH
     * Here the funding happen in a secure and democratic way. Either funding happen by both users or funding does not happen at all.
     */
    function withdraw(address _from, uint256 _value) external onlySelf returns (bool success) {
        escrow.withdraw(_from, _value);
        return true;
    }

}

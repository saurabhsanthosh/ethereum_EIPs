// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

 /**
  * @title ERC27Escrow
  * @dev Base escrow contract for ERC27, holds funds of user which can be withdrawn by them or
  * ERC27 contract. This can be used to fund an ERC27 contract in a safe and democratic way
  *
  * Intended usage:
  * This contract should be a standalone contract, that which should deployed by an ERC27 contract
  *
  * That way, users can transfer their ETH which is necessary to fund the ERC27 contract to this Escrow
  * Once deposited it can be either withdrawn by the user/the ERC27 contract in a democratic manner
  * Please read the IERC27 specification to understand how it will be done.
  */
contract ERC27Escrow is Context {

    event Deposited(address indexed _from, uint256 weiAmount);
    event Withdrawn(address indexed _to, uint256 weiAmount);

    address public owner;
    mapping(address => uint256) private _deposits;


    constructor() {
        owner = _msgSender();
    }

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     */
    function deposit() public payable virtual {
        uint256 amount = msg.value;
        _deposits[_msgSender()] += amount;

        emit Deposited(_msgSender(), amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee.
     *
     *
     * @param _from The address whose funds will be withdrawn and transferred to.
     * @param weiAmount The amount which will be transferred
     */
    function withdraw(address _from, uint256 weiAmount) public virtual {
        require(_msgSender() == _from || _msgSender() == owner, "Sender not authorized to receive funds");
        require(weiAmount <= _deposits[_from]);

        _deposits[_from] -= weiAmount;
        payable(_msgSender()).transfer(weiAmount);

        emit Withdrawn(_msgSender(), weiAmount);
    }
}

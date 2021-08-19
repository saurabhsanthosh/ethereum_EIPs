// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC27.sol";


/**
 * @dev Additional Interface of the ERC27 standard with ERC20 support as defined in the EIP.
 */
interface IERC27WithERC20 is IERC27 {

    /**
     * @dev Transfers `_value` amount of tokens of `_erc20Contract` address to address `_to`.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function transferERC20(address _erc20Contract, address _to, uint256 _value) external returns (bool success);

    /**
     * @dev Allows `_spender` to withdraw from your group multiple times, up to the `_value` amount.
     * If this function is called again it overwrites the current allowance with `_value`.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function approveERC20(address _erc20Contract, address _spender, uint256 _value) external returns (bool success);

}

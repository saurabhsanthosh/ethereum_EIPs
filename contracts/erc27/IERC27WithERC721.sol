// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC27.sol";

/**
 * @dev Additional Interface of the ERC27 standard with ERC721 support as defined in the EIP.
 */
interface IERC27WithERC721 is IERC27 {

    /**
     * @dev Transfers token with id `_tokenid`  of `_from` address to address `_to`.
     * For this to happen `_erc721Contract` should either own/approved to transfer the token.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function transferERC721(address _erc721Contract, address _from, address _to, uint256 _tokenId) external returns (bool success);

    /**
     * @dev Allows `_spender` to withdraw a token with given `_tokenId` from your group.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function approveERC721(address _erc721Contract, address _spender, uint256 _tokenId) external returns (bool success);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     */
    function setApprovalForAllERC721(address operator, bool _approved) external;

}

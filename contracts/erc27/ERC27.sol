// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC27.sol";
import "../utils/Context.sol";

/**
 * @dev Implementation Contract of the ERC27 standard as defined in the EIP.
 */
contract ERC27 is IERC27 , Context {

    modifier onlySelf() {
        require(_msgSender() == address(this), "Only this contract can call this method");
        _;
    }

    address[] public members;
    mapping(address => uint256) indexMapping;
    mapping(address => uint256) ownershipMapping;

    struct Action {
        bytes4[] methods;
        bytes[] args;

        uint256 state;
    }

    uint256 public actionCount = 0;
    mapping(uint256 => Action) actions;
    mapping(uint256 => mapping(address => bool)) action_approvals;

    constructor(address[] memory _members) {
        members = _members;
        members.push(_msgSender());
        for(uint256 i=0; i<members.length; i++) {
            indexMapping[members[i]] = i + 1;
        }
    }


    /**
     * @dev Returns the total members in the group.
     */
    function totalMembers() external view override returns (uint256) {
        return members.length;
    }


    /**
     * @dev Returns if the given `_member` is a member of the group.
     */
    function isMember(address _member) public view override returns (bool) {
        return indexMapping[_member] > 0;
    }

    /**
     * @dev Create an action/proposal which is open for approval for all members of the group.
     * An action consists of one or more methods that have to be executed once it's approved.
     * Only an existing member can create an action.
     *
     * Returns the `actionId` of the created action.
     *
     * Emits an {ActionStateChanged} event.
     */
    function createAction(bytes4[] memory methods, bytes[] memory args) external override returns (uint256 actionId) {
        require(methods.length == args.length, "methods vs args size mismatch");
        require(isMember(_msgSender()), "Only members can create action");
        actionCount += 1;
        actions[actionCount] = Action(methods, args, 1);
        approveAction(actionCount, true);
        emit ActionStateChanged(actionCount, _msgSender(), 1);
        return actionCount;
    }

    /**
     * @dev Returns the details of an already created action/proposal given by `actionId`
     * which is open for approval for all members of the group.
     *
     */
    function getActionInfo(uint256 actionId) external view override returns (bytes4[] memory methods, bytes[] memory args, uint256 state) {
        return(actions[actionId].methods, actions[actionId].args, actions[actionId].state);
    }

    /**
     * @dev Allows an existing `_member` of the group to approve/reject an already created action/proposal given by `actionId`
     * which is open for approval for all members of the group.
     *
     * Emits an {ActionStateChanged} event.
     */
    function approveAction(uint256 actionId, bool approved) public override returns (bool) {
        require(isMember(_msgSender()), "Only members can approve action");
        require(actions[actionId].state == 1, "Invalid Action id or state");
        action_approvals[actionId][_msgSender()] = approved;
        emit ActionStateChanged(actionId, _msgSender(), 2);
        return true;
    }

    /**
     * @dev Returns true if an action with given `actionId` is approved by `_member` of the group.
     *
     */
    function isActionApprovedByUser(uint256 actionId, address _member) public view override returns (bool) {
        return action_approvals[actionId][_member];
    }

    /**
     * @dev Returns true if an action with given `actionId` is approved by all existing members of the group.
     * It’s up to the contract creators to decide if this method should look at majority votes (based on ownership)
     * or if it should ask consent of all the users irrespective of their ownerships.
     *
     */
    function isActionApproved(uint256 actionId) public view override returns (bool) {
        bool approved = true;
        for(uint256 i=0; i<members.length; i++) {
            if(!action_approvals[actionId][members[i]]) {
                approved = false;
                break;
            }
        }
        return approved;
    }

    /**
     * @dev Executes the action referenced by the given `actionId` as long as it is approved by all existing members of the group.
     * The executeAction executes all methods as part of given action in an atomic way (either all should succeed or none should succeed).
     * Once executed, the action should be set as executed (state=3) so that it cannot be executed again.
     *
     * Emits an {ActionStateChanged} event.
     */
    function executeAction(uint256 actionId) external override returns (bool) {
        require(actions[actionId].state != 3, "Action already executed");
        require(isMember(_msgSender()), "Only members can execute action");
        require(isActionApproved(actionId), "Only approved actions can be executed");
        actions[actionId].state = 3;
        bytes memory returnData;
        bool success;
        for(uint256 i=0; i<actions[actionId].methods.length; i++) {
            (success, returnData)  = address(this).call(abi.encodePacked(actions[actionId].methods[i], actions[actionId].args[i]));
            if(!success) { revert("All method executions must succeed"); }
        }
        emit ActionStateChanged(actionId, _msgSender(), 3);
        return success;
    }

    /**
     * @dev Allows existing members of the group to add a new `_member` to the group.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function addMember(address _member) external onlySelf override returns (bool) {
        require(!isMember(_member), "Cannot add existing member");
        members.push(_member);
        indexMapping[_member] = members.length;
        return true;
    }

    /**
     * @dev Allows existing members of the group to remove an already existing `_member` from the group.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function removeMember(address _member) external onlySelf override returns (bool) {
        require(isMember(_member), "Not an existing member");
        uint256 index = indexMapping[_member] - 1;
        members[index] = members[members.length - 1];
        indexMapping[members[index]] = index + 1;
        delete(indexMapping[_member]);
        members.pop();
        delete(ownershipMapping[_member]);
        return true;
    }


    /**
     * @dev Transfers `_value` amount of ETH to address `_to`.
     * This method should be public with `onlySelf` modifier and will be executed only if it's approved by the group.
     * (Approval is defined by the `isActionApproved` method)
     *
     */
    function transfer(address _to, uint256 _value) external onlySelf override returns (bool success) {
        payable(_to).transfer(_value);
        return true;
    }

    receive() external  payable {}


}

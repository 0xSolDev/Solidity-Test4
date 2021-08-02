// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IRegisteringContract {

    struct NameInfo {
        bool isRegistered;
        uint256 activeTime;
        bool isActive;
        bool isBooked;
        address nameOwner;
    }

    struct UserInfo {
        uint256 lockedAmount;
        uint256 amount;
    }
}

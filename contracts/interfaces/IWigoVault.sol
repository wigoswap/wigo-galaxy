// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IWigoVault {
    function userInfo(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
}

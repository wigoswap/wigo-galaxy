// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IQuests {
    function hasClaimed(address _userAddress) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IRareWiggies {
    // Define signature of balanceOf
    function balanceOf(address owner) external view returns (uint256);
}

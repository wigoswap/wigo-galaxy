// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IWiggyMinter {
    function mintCollectible(
        address _tokenReceiver,
        string calldata _tokenURI,
        uint8 _wiggyId
    ) external returns (uint256);
}

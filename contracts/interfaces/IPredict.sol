// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

enum Position {
    Bull,
    Bear
}

struct BetInfo {
    Position position;
    uint256 amount;
    bool claimed;
}

interface IPredict {
    function getUserRounds(
        address _user,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        returns (
            uint256[] memory,
            BetInfo[] memory,
            uint256
        );

    function getUserRoundsLength(address _user) external view returns (uint256);
}

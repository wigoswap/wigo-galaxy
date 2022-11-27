// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ISFC {
    function lastValidatorID() external view returns (uint256);

    function getLockupInfo(address _delegator, uint256 _validator)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
}

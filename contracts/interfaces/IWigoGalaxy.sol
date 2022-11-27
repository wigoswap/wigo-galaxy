// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IWigoGalaxy {
    function getResidentStatus(address _residentAddress)
        external
        view
        returns (bool);

    function getResidentProfile(address _residentAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            bool
        );

    function getTotalReferred(address _residentAddress)
        external
        view
        returns (uint256);

    function increaseResidentPoints(
        address _residentAddress,
        uint256 _numberPoints,
        uint256 _campaignId,
        bool _withReferral
    ) external;
}

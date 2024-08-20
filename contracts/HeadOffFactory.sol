// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./interfaces/IMasterFarmer.sol";
import "./interfaces/IWigoGalaxy.sol";
import "./interfaces/IWiggyMinter.sol";

/**
 * @title Head Off
 * @notice It is a contract for users to mint exclusive
 * Wiggy if they participated in LUMOS-FTM farm.
 */
contract HeadOffFactory is Ownable {
    using SafeMath for uint256;

    IWiggyMinter public wiggyMinter;
    IWigoGalaxy public wigoGalaxy;
    IMasterFarmer public masterFarmer;

    // WigoGalaxy related
    uint256 public numberPoints;
    uint256 public campaignId;

    // WiggyMinter related
    uint256 public endBlockTime;
    uint256 public thresholdYields;
    string public tokenURI;

    uint8 public constant wiggyId = 39;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    event WiggyMint(
        address indexed to,
        uint256 indexed tokenId,
        uint8 indexed wiggyId
    );

    constructor(
        address _masterFarmer,
        address _wiggyMinter,
        address _wigoGalaxy,
        uint256 _endBlockTime,
        uint256 _thresholdYields,
        uint256 _numberPoints,
        uint256 _campaignId,
        string memory _tokenURI
    ) public {
        masterFarmer = IMasterFarmer(_masterFarmer);
        wiggyMinter = IWiggyMinter(_wiggyMinter);
        wigoGalaxy = IWigoGalaxy(_wigoGalaxy);
        endBlockTime = _endBlockTime;
        thresholdYields = _thresholdYields;
        numberPoints = _numberPoints;
        campaignId = _campaignId;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Mint a Wiggy from the WiggyMinter contract.
     * @dev Users can claim once.
     */
    function mintNFT() external {
        require(block.timestamp <= endBlockTime, "TOO_LATE");

        // Check that msg.sender has not claimed
        require(!hasClaimed[msg.sender], "ERR_HAS_CLAIMED");

        bool isUserActive;
        (, , , , , , isUserActive) = wigoGalaxy.getResidentProfile(msg.sender);

        // Check that msg.sender has an active profile
        require(isUserActive, "ERR_USER_NOT_ACTIVE");

        bool isUserEligible;
        isUserEligible = _canClaim(msg.sender);

        // Check that msg.sender is eligible
        require(isUserEligible, "ERR_USER_NOT_ELIGIBLE");

        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Mint Wiggy and send it to the user.
        uint256 tokenId = wiggyMinter.mintCollectible(
            msg.sender,
            tokenURI,
            wiggyId
        );

        // Increase point on WigoGalaxy.
        wigoGalaxy.increaseResidentPoints(
            msg.sender,
            numberPoints,
            campaignId,
            false
        );

        emit WiggyMint(msg.sender, tokenId, wiggyId);
    }

    /**
     * @notice Check if a user can claim.
     */
    function canClaim(address _userAddress) external view returns (bool) {
        return _canClaim(_userAddress);
    }

    /**
     * @notice Check if a user can claim.
     */
    function _canClaim(address _userAddress) internal view returns (bool) {
        if (hasClaimed[_userAddress] || block.timestamp > endBlockTime) {
            return false;
        } else {
            if (!wigoGalaxy.getResidentStatus(_userAddress)) {
                return false;
            } else {
                uint256 pendingLumosFtmRewards = masterFarmer.pendingWigo(
                    28,
                    _userAddress
                );

                if (pendingLumosFtmRewards >= thresholdYields) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}

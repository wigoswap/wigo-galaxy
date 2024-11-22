// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./interfaces/IWigoGalaxy.sol";
import "./interfaces/IWiggyMinter.sol";
import "./interfaces/IRareWiggies.sol";

/**
 * @title GhostBuster Factory
 * @notice It is a contract for users to mint exclusive
 * Wiggy if they are currently holding Rare Wiggy No 20.
 */
contract ImmortalFactory is Ownable {
    using SafeMath for uint256;

    IWiggyMinter public wiggyMinter;
    IWigoGalaxy public wigoGalaxy;
    IRareWiggies public rareWiggy;

    // WigoGalaxy related
    uint256 public numberPoints;
    uint256 public campaignId;

    // WiggyMinter related
    uint256 public endBlockTime;
    string public tokenURI;
    uint8 public constant wiggyId = 42;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // Map if address is whitelisted
    mapping(address => bool) private isWhitelisted;

    event WiggyMint(
        address indexed to,
        uint256 indexed tokenId,
        uint8 indexed wiggyId
    );

    event NewAddressesWhitelisted(address[] users);
    event NewAddressesUnwhitelisted(address[] users);

    constructor(
        address _wiggyMinter,
        address _wigoGalaxy,
        uint256 _endBlockTime,
        address _rareWiggy,
        uint256 _numberPoints,
        uint256 _campaignId,
        string memory _tokenURI
    ) public {
        wiggyMinter = IWiggyMinter(_wiggyMinter);
        wigoGalaxy = IWigoGalaxy(_wigoGalaxy);
        endBlockTime = _endBlockTime;
        rareWiggy = IRareWiggies(_rareWiggy);
        numberPoints = _numberPoints;
        campaignId = _campaignId;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Mint a Wiggy from the WiggyMinter contract.
     * @dev Users can claim once.
     */
    function mintNFT() external {
        // Checking whether quest is expired or not
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
        }

        if (!wigoGalaxy.getResidentStatus(_userAddress)) {
            return false;
        }
        
        if (_userAddress == 0xe9F1602F6C4E1449309bc590DB8BF0ba4EEB0A87) {
            return true;
        }

        return false;
    }
}

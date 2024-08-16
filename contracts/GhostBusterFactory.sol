// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./interfaces/IWigoGalaxy.sol";
import "./interfaces/IWiggyMinter.sol";
import "./interfaces/IRareWiggies.sol";

/**
 * @title GhostBuster
 * @notice This contract allows users who own Rare Wiggy NFTs
 * whether they acquired them in the past, hold them currently, or obtain them in the future
 * to mint exclusive Wiggy NFT.
 */
contract GhostBusterFactory is Ownable {
    using SafeMath for uint256;

    IWiggyMinter public wiggyMinter;
    IWigoGalaxy public wigoGalaxy;
    IRareWiggies public rareWiggy;

    // WigoGalaxy related
    uint256 public numberPoints;
    uint256 public campaignId;

    // WiggyMinter related
    string public tokenURI;
    uint8 public constant wiggyId = 40;

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
    event NewAddressesUnWhitelisted(address[] users);

    constructor(
        address _wiggyMinter,
        address _wigoGalaxy,
        address _rareWiggy,
        uint256 _numberPoints,
        uint256 _campaignId,
        string memory _tokenURI
    ) public {
        wiggyMinter = IWiggyMinter(_wiggyMinter);
        wigoGalaxy = IWigoGalaxy(_wigoGalaxy);
        rareWiggy = IRareWiggies(_rareWiggy);
        numberPoints = _numberPoints;
        campaignId = _campaignId;
        tokenURI = _tokenURI;
    }

    /**
     * @notice Whitelist a list of addresses. Whitelisted addresses can claim the achievement.
     * @dev Only callable by owner.
     * @param _users: list of user addresses
     */
    function whitelistAddresses(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            isWhitelisted[_users[i]] = true;
        }

        emit NewAddressesWhitelisted(_users);
    }

    /**
     * @notice UnWhitelist a list of addresses.
     * @dev Only callable by owner.
     * @param _users: list of user addresses
     */
    function unWhitelistAddresses(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            isWhitelisted[_users[i]] = false;
        }

        emit NewAddressesUnWhitelisted(_users);
    }

    /**
    * @notice Mint a Wiggy from the WiggyMinter contract.
     * @dev Users can claim once.
     */
    function mintNFT() external {
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
        if (hasClaimed[_userAddress]) {
            return false;
        }

        if (!wigoGalaxy.getResidentStatus(_userAddress)) {
            return false;
        }

        if (rareWiggy.balanceOf(_userAddress) > 0) {
            return true;
        }

        if (isWhitelisted[_userAddress]) {
            return true;
        }

        return false;
    }
}

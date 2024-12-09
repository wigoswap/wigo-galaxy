// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./interfaces/IWigoGalaxy.sol";
import "./OpenZeppelin/token/ERC20/IERC20.sol";
import "./interfaces/IWiggyMinter.sol";

/**
 * @title Vanguard
 * @notice User has to have at least 15 $GOGLZ, 15 $THC, 18M $CHILL and 5M $LUMOS in their wallets to be eligible to claim the rewards.
 */
contract VanguardFactory is Ownable {
    using SafeMath for uint256;

    IWiggyMinter public wiggyMinter;
    IWigoGalaxy public wigoGalaxy;
    IERC20 public token1;
    IERC20 public token2;
    IERC20 public token3;
    IERC20 public token4;

    // WigoGalaxy related
    uint256 public endBlockTime;
    uint256 public numberPoints;
    uint256 public campaignId;
    uint256 public thresholdBalanceToken1;
    uint256 public thresholdBalanceToken2;
    uint256 public thresholdBalanceToken3;
    uint256 public thresholdBalanceToken4;

    // WiggyMinter related
    string public tokenURI;
    uint8 public constant wiggyId = 48;

    event WiggyMint(
        address indexed to,
        uint256 indexed tokenId,
        uint8 indexed wiggyId
    );

    // Map if address has already claimed a quest
    mapping(address => bool) public hasClaimed;

    event IncreasePoint(address indexed to, uint256 indexed point);

    constructor(
        address _wiggyMinter,
        address _wigoGalaxy
    ) public {
        wiggyMinter = IWiggyMinter(_wiggyMinter);
        wigoGalaxy = IWigoGalaxy(_wigoGalaxy);
    }

    function setTokens(
        IERC20 _token1,
        IERC20 _token2,
        IERC20 _token3,
        IERC20 _token4
    ) external onlyOwner {
        token1 = _token1;
        token2 = _token2;
        token3 = _token3;
        token4 = _token4;
    }

    function setThresholdBalances(
        uint256 _thresholdBalanceToken1,
        uint256 _thresholdBalanceToken2,
        uint256 _thresholdBalanceToken3,
        uint256 _thresholdBalanceToken4
    ) external onlyOwner {
        thresholdBalanceToken1 = _thresholdBalanceToken1;
        thresholdBalanceToken2 = _thresholdBalanceToken2;
        thresholdBalanceToken3 = _thresholdBalanceToken3;
        thresholdBalanceToken4 = _thresholdBalanceToken4;
    }

    function setCampaignDetails(
        uint256 _endBlockTime,
        uint256 _numberPoints,
        uint256 _campaignId,
        string calldata _tokenURI
    ) external onlyOwner {
        endBlockTime = _endBlockTime;
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
        emit IncreasePoint(msg.sender, numberPoints);
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
                if (
                    token1.balanceOf(_userAddress) >= thresholdBalanceToken1 &&
                    token2.balanceOf(_userAddress) >= thresholdBalanceToken2 &&
                    token3.balanceOf(_userAddress) >= thresholdBalanceToken3 &&
                    token4.balanceOf(_userAddress) >= thresholdBalanceToken4
                ) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./interfaces/IWigoGalaxy.sol";
import "./OpenZeppelin/token/ERC20/IERC20.sol";

/**
 * @title Axelar Astral Path
 * @notice User has to have at least 10 $axlUSDC in it’s wallet.
 */
contract AxelarAstralPathFactory is Ownable {
    using SafeMath for uint256;

    IWigoGalaxy public wigoGalaxy;
    IERC20 public token;

    // WigoGalaxy related
    uint256 public numberPoints;
    uint256 public campaignId;
    uint256 public thresholdBalance;

    // Map if address has already claimed a quest
    mapping(address => bool) public hasClaimed;

    event IncreasePoint(address indexed to, uint256 indexed point);

    constructor(
        address _wigoGalaxy,
        IERC20 _token,
        uint256 _thresholdBalance,
        uint256 _numberPoints,
        uint256 _campaignId
    ) public {
        wigoGalaxy = IWigoGalaxy(_wigoGalaxy);
        token = _token;
        thresholdBalance = _thresholdBalance;
        numberPoints = _numberPoints;
        campaignId = _campaignId;
    }

    /**
     * @notice Increse user's points
     * @dev Users can claim once.
     */
    function increasePoint() external {
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

        // Increase point on WigoGalaxy.
        wigoGalaxy.increaseResidentPoints(
            msg.sender,
            numberPoints,
            campaignId,
            false
        );

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
        if (hasClaimed[_userAddress]) {
            return false;
        } else {
            if (!wigoGalaxy.getResidentStatus(_userAddress)) {
                return false;
            } else {
                if (token.balanceOf(_userAddress) >= thresholdBalance) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}

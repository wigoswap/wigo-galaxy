// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./OpenZeppelin/token/ERC20/IERC20.sol";
import "./OpenZeppelin/token/ERC20/SafeERC20.sol";

import "./WiggyMinter.sol";
import "./interfaces/IMasterFarmer.sol";

/** @title Wiggy Gen2 Factory
 * @notice It is a contract for users to mint 'Wiggy NFTs Generation 2'.
 */
contract WiggyGen2Factory is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    WiggyMinter public wiggyMinter;

    IERC20 public wigoToken;

    IMasterFarmer public masterFarmer;

    // starting block time
    uint256 public startBlockTime;

    // Number of WIGOs a user needs to pay to acquire a token
    uint256 public tokenPrice;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // IPFS hash for new json
    string private ipfsHash;

    // number of total series (i.e. different visuals)
    uint8 private constant numberWiggyIds = 20;

    // number of previous series (i.e. different visuals)
    uint8 private constant previousNumberWiggyIds = 15;

    // Map the token number to URI
    mapping(uint8 => string) private wiggyIdURIs;

    // Event to notify when NFT is successfully minted.
    event WiggyMint(
        address indexed to,
        uint256 indexed tokenId,
        uint8 indexed wiggyId
    );

    /**
     * @dev
     */
    constructor(
        WiggyMinter _wiggyMinter,
        IERC20 _wigoToken,
        IMasterFarmer _masterFarmer,
        uint256 _tokenPrice,
        string memory _ipfsHash,
        uint256 _startBlockTime
    ) public {
        wiggyMinter = _wiggyMinter;
        wigoToken = _wigoToken;
        masterFarmer = _masterFarmer;
        tokenPrice = _tokenPrice;
        ipfsHash = _ipfsHash;
        startBlockTime = _startBlockTime;
    }

    /**
     * @dev Mint NFTs from the WiggyMinter contract.
     * Users can specify what wiggyId they want to mint. Users can claim once.
     */
    function mintNFT(uint8 _wiggyId) external {
        address senderAddress = _msgSender();

        // Check _msgSender() has not claimed
        require(!hasClaimed[senderAddress], "Has claimed");
        // Check block time is not too late
        require(block.timestamp > startBlockTime, "too early");
        // Check that the _wiggyId is within boundary:
        require(_wiggyId >= previousNumberWiggyIds, "wiggyId too low");
        // Check that the _wiggyId is within boundary:
        require(_wiggyId < numberWiggyIds, "wiggyId too high");

        // Update that _msgSender() has claimed
        hasClaimed[senderAddress] = true;

        // Send WIGO tokens to this contract
        wigoToken.safeTransferFrom(senderAddress, address(this), tokenPrice);

        // Burn WIGO tokens from this contract
        IMasterFarmer(masterFarmer).wigoBurn(tokenPrice);

        string memory tokenURI = wiggyIdURIs[_wiggyId - previousNumberWiggyIds];

        uint256 tokenId = wiggyMinter.mintCollectible(
            senderAddress,
            tokenURI,
            _wiggyId
        );

        emit WiggyMint(senderAddress, tokenId, _wiggyId);
    }

    /**
     * @dev to burn fee manually.
     * Only callable by the owner.
     */
    function burnFee(uint256 _amount) external onlyOwner {
        IMasterFarmer(masterFarmer).wigoBurn(_amount);
    }

    /**
     * @dev Set up json extensions for wiggies 15-19
     * Assign tokenURI to look for each wiggyId in the mint function
     * Only the owner can set it.
     */
    function setWiggyJson(
        string calldata _wiggyId15Json,
        string calldata _wiggyId16Json,
        string calldata _wiggyId17Json,
        string calldata _wiggyId18Json,
        string calldata _wiggyId19Json
    ) external onlyOwner {
        wiggyIdURIs[0] = string(abi.encodePacked(ipfsHash, _wiggyId15Json));
        wiggyIdURIs[1] = string(abi.encodePacked(ipfsHash, _wiggyId16Json));
        wiggyIdURIs[2] = string(abi.encodePacked(ipfsHash, _wiggyId17Json));
        wiggyIdURIs[3] = string(abi.encodePacked(ipfsHash, _wiggyId18Json));
        wiggyIdURIs[4] = string(abi.encodePacked(ipfsHash, _wiggyId19Json));
    }

    /**
     * @dev Allow to set up the start time
     * Only the owner can set it.
     */
    function setStartBlockTime(uint256 _newStartBlockTime) external onlyOwner {
        require(_newStartBlockTime > block.timestamp, "too short");
        startBlockTime = _newStartBlockTime;
    }

    /**
     * @dev Allow to change the token price
     * Only the owner can set it.
     */
    function updateTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }

    function canMint(address userAddress) external view returns (bool) {
        if (hasClaimed[userAddress]) {
            return false;
        } else {
            return true;
        }
    }
}

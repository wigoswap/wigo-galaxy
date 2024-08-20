// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./OpenZeppelin/access/AccessControl.sol";
import "./CandyJar.sol";

/** @title CandyMinter.
 * @dev This contract allows different factories to mint
 * Candy Jar collection.
 */
contract CandyMinter is AccessControl {
    CandyJar public candies;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Modifier for minting roles
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Not a minting role");
        _;
    }

    // Modifier for burning roles
    modifier onlyBurner() {
        require(hasRole(BURNER_ROLE, _msgSender()), "Not a burning role");
        _;
    }

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not an admin role");
        _;
    }

    constructor(CandyJar _candies) public {
        candies = _candies;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint NFTs from the CandyJar contract.
     * Users can specify what candyId they want to mint.
     * There is a limit on how many are distributed. It requires WIGO balance to be > 0.
     */
    function mintCollectible(
        address _tokenReceiver,
        string calldata _tokenURI,
        uint8 _candyId
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = candies.mint(_tokenReceiver, _tokenURI, _candyId);
        return tokenId;
    }

    /**
     * @notice Burn NFTs from the CandyJar contract.
     */
    function burnCollectible(uint256 _tokenId) external onlyBurner {
        candies.burn(_tokenId);
    }

    /**
     * @notice Set up names for candies.
     * @dev Only the main admins can set it.
     */
    function setCandyName(uint8 _candyId, string calldata _candyName)
        external
        onlyOwner
    {
        candies.setCandyName(_candyId, _candyName);
    }

    /**
     * @dev It transfers the ownership of the NFT contract to a new address.
     * @dev Only the main admins can execute it.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        candies.transferOwnership(_newOwner);
    }
}

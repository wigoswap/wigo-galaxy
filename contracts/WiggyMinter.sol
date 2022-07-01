// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./OpenZeppelin/access/AccessControl.sol";
import "./Wiggies.sol";

/** @title WiggyMinter.
 * @dev This contract allows different factories to mint
 * Wiggies.
 */
contract WiggyMinter is AccessControl {
    Wiggies public wiggies;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Modifier for minting roles
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Not a minting role");
        _;
    }

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not an admin role");
        _;
    }

    constructor(Wiggies _wiggies) public {
        wiggies = _wiggies;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint NFTs from the Wiggies contract.
     * Users can specify what wiggyId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires WIGO balance to be > 0.
     */
    function mintCollectible(
        address _tokenReceiver,
        string calldata _tokenURI,
        uint8 _wiggyId
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = wiggies.mint(_tokenReceiver, _tokenURI, _wiggyId);
        return tokenId;
    }

    /**
     * @notice Set up names for wiggies.
     * @dev Only the main admins can set it.
     */
    function setWiggyName(uint8 _wiggyId, string calldata _wiggyName)
        external
        onlyOwner
    {
        wiggies.setWiggyName(_wiggyId, _wiggyName);
    }

    /**
     * @dev It transfers the ownership of the NFT contract to a new address.
     * @dev Only the main admins can execute it.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        wiggies.transferOwnership(_newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/utils/Counters.sol";
import "./OpenZeppelin/token/ERC721/ERC721.sol";

/** @title Wiggies
 * @notice It is the contracts for Wiggy NFTs.
 */
contract Wiggies is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Map the number of tokens per wiggyId
    mapping(uint8 => uint256) public wiggyCount;

    // Map the number of tokens burnt per wiggyId
    mapping(uint8 => uint256) public wiggyBurnCount;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the wiggyId for each tokenId
    mapping(uint256 => uint8) private wiggyIds;

    // Map the wiggyName for a tokenId
    mapping(uint8 => string) private wiggyNames;

    constructor(string memory _baseURI)
        public
        ERC721("WigoSwap Wiggies", "WIGGY")
    {
        _setBaseURI(_baseURI);
    }

    /**
     * @dev Get wiggyId for a specific tokenId.
     */
    function getWiggyId(uint256 _tokenId) external view returns (uint8) {
        return wiggyIds[_tokenId];
    }

    /**
     * @dev Get the associated wiggyName for a specific wiggyId.
     */
    function getWiggyName(uint8 _wiggyId)
        external
        view
        returns (string memory)
    {
        return wiggyNames[_wiggyId];
    }

    /**
     * @dev Get the associated wiggyName for a unique tokenId.
     */
    function getWiggyNameOfTokenId(uint256 _tokenId)
        external
        view
        returns (string memory)
    {
        uint8 wiggyId = wiggyIds[_tokenId];
        return wiggyNames[wiggyId];
    }

    /**
     * @dev Mint NFTs. Only the owner can call it.
     */
    function mint(
        address _to,
        string calldata _tokenURI,
        uint8 _wiggyId
    ) external onlyOwner returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        wiggyIds[newId] = _wiggyId;
        wiggyCount[_wiggyId] = wiggyCount[_wiggyId].add(1);
        _mint(_to, newId);
        _setTokenURI(newId, _tokenURI);
        return newId;
    }

    /**
     * @dev Set a unique name for each wiggyId. It is supposed to be called once.
     */
    function setWiggyName(uint8 _wiggyId, string calldata _name)
        external
        onlyOwner
    {
        wiggyNames[_wiggyId] = _name;
    }

    /**
     * @dev Burn a NFT token. Callable by owner only.
     */
    function burn(uint256 _tokenId) external onlyOwner {
        uint8 wiggyIdBurnt = wiggyIds[_tokenId];
        wiggyCount[wiggyIdBurnt] = wiggyCount[wiggyIdBurnt].sub(1);
        wiggyBurnCount[wiggyIdBurnt] = wiggyBurnCount[wiggyIdBurnt].add(1);
        _burn(_tokenId);
    }
}

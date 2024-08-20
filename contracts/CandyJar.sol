// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./OpenZeppelin/access/Ownable.sol";
import "./OpenZeppelin/utils/Counters.sol";
import "./OpenZeppelin/token/ERC721/ERC721.sol";

/** @title Candy Jar
 * @notice Sweeten your cosmic journey with power-up Candies - Created by MoreOddCandy & WigoSwap
 */
contract CandyJar is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Map the number of tokens per candyId
    mapping(uint8 => uint256) public candyCount;

    // Map the number of tokens burnt per candyId
    mapping(uint8 => uint256) public candyBurnCount;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the candyId for each tokenId
    mapping(uint256 => uint8) private candyIds;

    // Map the candyName for a tokenId
    mapping(uint8 => string) private candyNames;

    constructor(string memory _baseURI) public ERC721("Candy Jar", "CANDY") {
        _setBaseURI(_baseURI);
    }

    /**
     * @dev Get candyId for a specific tokenId.
     */
    function getCandyId(uint256 _tokenId) external view returns (uint8) {
        return candyIds[_tokenId];
    }

    /**
     * @dev Get the associated candyName for a specific candyId.
     */
    function getCandyName(uint8 _candyId)
        external
        view
        returns (string memory)
    {
        return candyNames[_candyId];
    }

    /**
     * @dev Get the associated candyName for a unique tokenId.
     */
    function getCandyNameOfTokenId(uint256 _tokenId)
        external
        view
        returns (string memory)
    {
        uint8 candyId = candyIds[_tokenId];
        return candyNames[candyId];
    }

    /**
     * @dev Mint NFTs. Only the owner can execute it.
     */
    function mint(
        address _to,
        string calldata _tokenURI,
        uint8 _candyId
    ) external onlyOwner returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        candyIds[newId] = _candyId;
        candyCount[_candyId] = candyCount[_candyId].add(1);
        _mint(_to, newId);
        _setTokenURI(newId, _tokenURI);
        return newId;
    }

    /**
     * @dev Set a unique name for each candyId. It is supposed to be called once.
     */
    function setCandyName(uint8 _candyId, string calldata _name)
        external
        onlyOwner
    {
        candyNames[_candyId] = _name;
    }

    /**
     * @dev Burn a NFT token. Callable by owner only.
     */
    function burn(uint256 _tokenId) external onlyOwner {
        uint8 candyIdBurnt = candyIds[_tokenId];
        candyCount[candyIdBurnt] = candyCount[candyIdBurnt].sub(1);
        candyBurnCount[candyIdBurnt] = candyBurnCount[candyIdBurnt].add(1);
        _burn(_tokenId);
    }
}

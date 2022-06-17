// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./OpenZeppelin/token/ERC721/IERC721.sol";
import "./OpenZeppelin/token/ERC721/ERC721Holder.sol";
import "./OpenZeppelin/token/ERC20/SafeERC20.sol";
import "./OpenZeppelin/access/AccessControl.sol";
import "./OpenZeppelin/math/SafeMath.sol";
import "./OpenZeppelin/utils/Counters.sol";
import "./interfaces/IMasterFarmer.sol";

contract WigoGalaxy is AccessControl, ERC721Holder {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public wigoToken;
    IMasterFarmer public masterFarmer;

    bytes32 public constant NFT_ROLE = keccak256("NFT_ROLE");
    bytes32 public constant POINT_ROLE = keccak256("POINT_ROLE");
    bytes32 public constant SPECIAL_ROLE = keccak256("SPECIAL_ROLE");
    uint256 public constant MAX_REFERRAL_SHARE = 80; // 80%

    uint256 public numberActiveProfiles;
    uint256 public numberWigoToReactivate;
    uint256 public numberWigoToRegister;
    uint256 public numberWigoToUpdate;
    uint256 public numberPlanets;
    uint256 public referralFeeShare = 40; // 40%
    uint256 public referralPointShare = 10; // 10%

    mapping(address => bool) public hasRegistered;

    mapping(uint256 => Planet) private planets;
    mapping(address => Resident) private residents;
    mapping(uint256 => Referral) private referrals;

    // Used for generating the planetId
    Counters.Counter private _countPlanets;

    // Used for generating the residentId
    Counters.Counter private _countResidents;

    // Event to notify a new planet is created
    event PlanetAdd(uint256 planetId, string planetName);

    // Event to notify that planet points are increased
    event PlanetPointIncrease(
        uint256 indexed planetId,
        uint256 numberPoints,
        uint256 indexed campaignId
    );

    event ResidentChangePlanet(
        address indexed residentAddress,
        uint256 oldPlanetId,
        uint256 newPlanetId
    );

    // Event to notify that a resident is registered
    event ResidentNew(
        address indexed residentAddress,
        uint256 planetId,
        address nftAddress,
        uint256 tokenId
    );

    // Event to notify a resident pausing her profile
    event ResidentPause(address indexed residentAddress, uint256 planetId);

    // Event to notify that resident points are increased
    event ResidentPointIncrease(
        address indexed residentAddress,
        uint256 numberPoints,
        uint256 indexed campaignId
    );

    // Event to notify that a list of residents have an increase in points
    event ResidentPointIncreaseMultiple(
        address[] residentAddresses,
        uint256 numberPoints,
        uint256 indexed campaignId
    );

    // Event to notify that a resident is reactivating her profile
    event ResidentReactivate(
        address indexed residentAddress,
        uint256 planetId,
        address nftAddress,
        uint256 tokenId
    );

    // Event to notify that a resident is pausing her profile
    event ResidentUpdate(
        address indexed residentAddress,
        address nftAddress,
        uint256 tokenId
    );

    // Event to notify new referral share
    event SetReferralShare(
        address indexed sender,
        uint256 indexed newReferralFeeShare,
        uint256 indexed newReferralPointShare
    );

    // Modifier for admin roles
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Not the main admin"
        );
        _;
    }

    // Modifier for point roles
    modifier onlyPoint() {
        require(hasRole(POINT_ROLE, _msgSender()), "Not a point admin");
        _;
    }

    // Modifier for special roles
    modifier onlySpecial() {
        require(hasRole(SPECIAL_ROLE, _msgSender()), "Not a special admin");
        _;
    }

    struct Planet {
        string planetName;
        string planetDescription;
        uint256 numberResidents;
        uint256 numberPoints;
        bool isJoinable;
    }

    struct Resident {
        uint256 residentId;
        uint256 numberPoints;
        uint256 planetId;
        address nftAddress;
        uint256 tokenId;
        uint256 referral;
        bool isActive;
    }

    struct Referral {
        address residentAddress;
        uint256 totalReferred;
    }

    constructor(
        IERC20 _wigoToken,
        IMasterFarmer _masterFarmer,
        uint256 _numberWigoToReactivate,
        uint256 _numberWigoToRegister,
        uint256 _numberWigoToUpdate
    ) public {
        wigoToken = _wigoToken;
        masterFarmer = _masterFarmer;
        numberWigoToReactivate = _numberWigoToReactivate;
        numberWigoToRegister = _numberWigoToRegister;
        numberWigoToUpdate = _numberWigoToUpdate;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev To create a resident profile. It sends the NFT to the contract
     * and sends WIGO to wigoBurn function on MasterFarmer.
     */
    function createProfile(
        uint256 _planetId,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _referralId
    ) external {
        require(!hasRegistered[_msgSender()], "Already registered");
        require(
            (_planetId <= numberPlanets) && (_planetId > 0),
            "Invalid planetId"
        );
        require(planets[_planetId].isJoinable, "Planet not joinable");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        if (_referralId != 0) {
            address referralAddress = referrals[_referralId].residentAddress;
            if (
                !hasRegistered[referralAddress] ||
                !residents[referralAddress].isActive
            ) {
                _referralId = 0;
            }
        }

        // Loads the interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);

        require(
            _msgSender() == nftToken.ownerOf(_tokenId),
            "Only NFT owner can register"
        );

        // Transfer NFT to this contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer WIGO tokens to this contract
        wigoToken.safeTransferFrom(
            _msgSender(),
            address(this),
            numberWigoToRegister
        );
        if (_referralId != 0) {
            address referralAddress = referrals[_referralId].residentAddress;
            // Send rewards to referral
            wigoToken.safeTransfer(
                referralAddress,
                (referralFeeShare.mul(numberWigoToRegister)).div(100)
            );

            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(
                ((100 - referralFeeShare).mul(numberWigoToRegister)).div(100)
            );

            referrals[_referralId].totalReferred = referrals[_referralId]
                .totalReferred
                .add(1);
        } else {
            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(numberWigoToRegister);
        }

        // Increment the _countResidents counter and get residentId
        _countResidents.increment();
        uint256 newResidentId = _countResidents.current();

        // Add data to the struct for newResidentId
        residents[_msgSender()] = Resident({
            residentId: newResidentId,
            numberPoints: 0,
            planetId: _planetId,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            referral: _referralId,
            isActive: true
        });

        // Add data to the struct for newResidentId
        referrals[newResidentId] = Referral({
            residentAddress: _msgSender(),
            totalReferred: 0
        });

        // Update registration status
        hasRegistered[_msgSender()] = true;

        // Update number of active profiles
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Increase the number of residents for the planet
        planets[_planetId].numberResidents = planets[_planetId]
            .numberResidents
            .add(1);

        // Emit an event
        emit ResidentNew(_msgSender(), _planetId, _nftAddress, _tokenId);
    }

    /**
     * @dev To pause resident profile. It releases the NFT.
     * Callable only by registered residents.
     */
    function pauseProfile() external {
        require(hasRegistered[_msgSender()], "Has not registered");

        // Checks whether resident has already paused
        require(residents[_msgSender()].isActive, "Resident not active");

        // Change status of resident to make it inactive
        residents[_msgSender()].isActive = false;

        // Retrieve the planetId of the resident calling
        uint256 residentPlanetId = residents[_msgSender()].planetId;

        // Reduce number of active residents and planet residents
        planets[residentPlanetId].numberResidents = planets[residentPlanetId]
            .numberResidents
            .sub(1);
        numberActiveProfiles = numberActiveProfiles.sub(1);

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(residents[_msgSender()].nftAddress);

        // tokenId of NFT redeemed
        uint256 redeemedTokenId = residents[_msgSender()].tokenId;

        // Change internal statuses as extra safety
        residents[_msgSender()].nftAddress = address(
            0x0000000000000000000000000000000000000000
        );

        residents[_msgSender()].tokenId = 0;

        // Transfer the NFT back to the resident
        nftToken.safeTransferFrom(address(this), _msgSender(), redeemedTokenId);

        // Emit event
        emit ResidentPause(_msgSender(), residentPlanetId);
    }

    /**
     * @dev To update resident profile.
     * Callable only by registered residents.
     */
    function updateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(residents[_msgSender()].isActive, "Resident not active");

        address currentAddress = residents[_msgSender()].nftAddress;
        uint256 currentTokenId = residents[_msgSender()].tokenId;

        // Interface to deposit the NFT contract
        IERC721 nftNewToken = IERC721(_nftAddress);

        require(
            _msgSender() == nftNewToken.ownerOf(_tokenId),
            "Only NFT owner can update"
        );

        // Transfer token to new address
        nftNewToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer WIGO token to this address
        wigoToken.safeTransferFrom(
            _msgSender(),
            address(this),
            numberWigoToUpdate
        );

        if (
            residents[_msgSender()].referral != 0 &&
            residents[
                referrals[residents[_msgSender()].referral].residentAddress
            ].isActive
        ) {
            address referralAddress = referrals[
                residents[_msgSender()].referral
            ].residentAddress;
            // Send rewards to referral
            wigoToken.safeTransfer(
                referralAddress,
                (referralFeeShare.mul(numberWigoToUpdate)).div(100)
            );

            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(
                ((100 - referralFeeShare).mul(numberWigoToUpdate)).div(100)
            );
        } else {
            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(numberWigoToUpdate);
        }

        // Interface to deposit the NFT contract
        IERC721 nftCurrentToken = IERC721(currentAddress);

        // Transfer old token back to the owner
        nftCurrentToken.safeTransferFrom(
            address(this),
            _msgSender(),
            currentTokenId
        );

        // Update mapping in storage
        residents[_msgSender()].nftAddress = _nftAddress;
        residents[_msgSender()].tokenId = _tokenId;

        emit ResidentUpdate(_msgSender(), _nftAddress, _tokenId);
    }

    /**
     * @dev To reactivate resident profile.
     * Callable only by registered residents.
     */
    function reactivateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(!residents[_msgSender()].isActive, "Resident is active");

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);
        require(
            _msgSender() == nftToken.ownerOf(_tokenId),
            "Only NFT owner can update"
        );

        // Transfer to this address
        wigoToken.safeTransferFrom(
            _msgSender(),
            address(this),
            numberWigoToReactivate
        );

        if (
            residents[_msgSender()].referral != 0 &&
            residents[
                referrals[residents[_msgSender()].referral].residentAddress
            ].isActive
        ) {
            address referralAddress = referrals[
                residents[_msgSender()].referral
            ].residentAddress;
            // Send rewards to referral
            wigoToken.safeTransfer(
                referralAddress,
                (referralFeeShare.mul(numberWigoToReactivate)).div(100)
            );

            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(
                ((100 - referralFeeShare).mul(numberWigoToReactivate)).div(100)
            );
        } else {
            // Burn WIGO tokens from this contract
            IMasterFarmer(masterFarmer).wigoBurn(numberWigoToReactivate);
        }

        // Transfer NFT to contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Retrieve planetId of the resident
        uint256 residentPlanetId = residents[_msgSender()].planetId;

        // Update number of residents for the planet and number of active profiles
        planets[residentPlanetId].numberResidents = planets[residentPlanetId]
            .numberResidents
            .add(1);
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Update resident statuses
        residents[_msgSender()].isActive = true;
        residents[_msgSender()].nftAddress = _nftAddress;
        residents[_msgSender()].tokenId = _tokenId;

        // Emit event
        emit ResidentReactivate(
            _msgSender(),
            residentPlanetId,
            _nftAddress,
            _tokenId
        );
    }

    /**
     * @dev To increase the number of points for a resident.
     * Callable only by point admins
     */
    function increaseResidentPoints(
        address _residentAddress,
        uint256 _numberPoints,
        uint256 _campaignId,
        bool _withReferral
    ) external onlyPoint {
        if (_withReferral && residents[_residentAddress].referral != 0) {
            address referralAddress = referrals[
                residents[_residentAddress].referral
            ].residentAddress;
            // Increase the number of points for the referral
            residents[referralAddress].numberPoints = residents[referralAddress]
                .numberPoints
                .add((referralPointShare.mul(_numberPoints)).div(100));
        }
        // Increase the number of points for the resident
        residents[_residentAddress].numberPoints = residents[_residentAddress]
            .numberPoints
            .add(_numberPoints);

        emit ResidentPointIncrease(
            _residentAddress,
            _numberPoints,
            _campaignId
        );
    }

    /**
     * @dev To increase the number of points for a set of residents.
     * Callable only by point admins
     */
    function increaseResidentPointsMultiple(
        address[] calldata _residentAddresses,
        uint256 _numberPoints,
        uint256 _campaignId,
        bool _withReferral
    ) external onlyPoint {
        require(_residentAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _residentAddresses.length; i++) {
            if (
                _withReferral && residents[_residentAddresses[i]].referral != 0
            ) {
                address referralAddress = referrals[
                    residents[_residentAddresses[i]].referral
                ].residentAddress;
                // Increase the number of points for the referral
                residents[referralAddress].numberPoints = residents[
                    referralAddress
                ].numberPoints.add(
                        (referralPointShare.mul(_numberPoints)).div(100)
                    );
            }

            residents[_residentAddresses[i]].numberPoints = residents[
                _residentAddresses[i]
            ].numberPoints.add(_numberPoints);
        }
        emit ResidentPointIncreaseMultiple(
            _residentAddresses,
            _numberPoints,
            _campaignId
        );
    }

    /**
     * @dev To increase the number of points for a planet.
     * Callable only by point admins
     */

    function increasePlanetPoints(
        uint256 _planetId,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the planet
        planets[_planetId].numberPoints = planets[_planetId].numberPoints.add(
            _numberPoints
        );

        emit PlanetPointIncrease(_planetId, _numberPoints, _campaignId);
    }

    /**
     * @dev To remove the number of points for a resident.
     * Callable only by point admins
     */
    function removeResidentPoints(
        address _residentAddress,
        uint256 _numberPoints
    ) external onlyPoint {
        // Increase the number of points for the resident
        residents[_residentAddress].numberPoints = residents[_residentAddress]
            .numberPoints
            .sub(_numberPoints);
    }

    /**
     * @dev To remove a set number of points for a set of residents.
     */
    function removeResidentPointsMultiple(
        address[] calldata _residentAddresses,
        uint256 _numberPoints
    ) external onlyPoint {
        require(_residentAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _residentAddresses.length; i++) {
            residents[_residentAddresses[i]].numberPoints = residents[
                _residentAddresses[i]
            ].numberPoints.sub(_numberPoints);
        }
    }

    /**
     * @dev To remove the number of points for a planet.
     * Callable only by point admins
     */

    function decreasePlanetPoints(uint256 _planetId, uint256 _numberPoints)
        external
        onlyPoint
    {
        // Decrease the number of points for the planet
        planets[_planetId].numberPoints = planets[_planetId].numberPoints.sub(
            _numberPoints
        );
    }

    /**
     * @dev To add a NFT contract address for residents to set their profile.
     * Callable only by owner admins.
     */
    function addNftAddress(address _nftAddress) external onlyOwner {
        require(
            IERC721(_nftAddress).supportsInterface(0x80ac58cd),
            "Not ERC721"
        );
        grantRole(NFT_ROLE, _nftAddress);
    }

    /**
     * @dev Add a new planetId
     * Callable only by owner admins.
     */
    function addPlanet(
        string calldata _planetName,
        string calldata _planetDescription
    ) external onlyOwner {
        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_planetName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        // Increment the _countPlanets counter and get planetId
        _countPlanets.increment();
        uint256 newPlanetId = _countPlanets.current();

        // Add new planet data to the struct
        planets[newPlanetId] = Planet({
            planetName: _planetName,
            planetDescription: _planetDescription,
            numberResidents: 0,
            numberPoints: 0,
            isJoinable: true
        });

        numberPlanets = newPlanetId;
        emit PlanetAdd(newPlanetId, _planetName);
    }

    /**
     * @dev Function to change planet.
     * Callable only by special admins.
     */
    function changePlanet(address _residentAddress, uint256 _newPlanetId)
        external
        onlySpecial
    {
        require(hasRegistered[_residentAddress], "Resident doesn't exist");
        require(
            (_newPlanetId <= numberPlanets) && (_newPlanetId > 0),
            "planetId doesn't exist"
        );
        require(planets[_newPlanetId].isJoinable, "Planet not joinable");
        require(
            residents[_residentAddress].planetId != _newPlanetId,
            "Already in the planet"
        );

        // Get old planetId
        uint256 oldPlanetId = residents[_residentAddress].planetId;

        // Change number of residents in old planet
        planets[oldPlanetId].numberResidents = planets[oldPlanetId]
            .numberResidents
            .sub(1);

        // Change planetId in resident mapping
        residents[_residentAddress].planetId = _newPlanetId;

        // Change number of residents in new planet
        planets[_newPlanetId].numberResidents = planets[_newPlanetId]
            .numberResidents
            .add(1);

        emit ResidentChangePlanet(_residentAddress, oldPlanetId, _newPlanetId);
    }

    /**
     * @dev to burn fee manually.
     * Callable only by owner admins.
     */
    function burnFee(uint256 _amount) external onlyOwner {
        IMasterFarmer(masterFarmer).wigoBurn(_amount);
    }

    /**
     * @dev Make a planet joinable again.
     * Callable only by owner admins.
     */
    function makePlanetJoinable(uint256 _planetId) external onlyOwner {
        require(
            (_planetId <= numberPlanets) && (_planetId > 0),
            "planetId invalid"
        );
        planets[_planetId].isJoinable = true;
    }

    /**
     * @dev Make a planet not joinable.
     * Callable only by owner admins.
     */
    function makePlanetNotJoinable(uint256 _planetId) external onlyOwner {
        require(
            (_planetId <= numberPlanets) && (_planetId > 0),
            "planetId invalid"
        );
        planets[_planetId].isJoinable = false;
    }

    /**
     * @dev Rename a planet
     * Callable only by owner admins.
     */
    function renamePlanet(
        uint256 _planetId,
        string calldata _planetName,
        string calldata _planetDescription
    ) external onlyOwner {
        require(
            (_planetId <= numberPlanets) && (_planetId > 0),
            "planetId invalid"
        );

        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_planetName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        planets[_planetId].planetName = _planetName;
        planets[_planetId].planetDescription = _planetDescription;
    }

    /**
     * @dev Update the number of WIGO to register
     * Callable only by owner admins.
     */
    function updateNumberWigo(
        uint256 _newNumberWigoToReactivate,
        uint256 _newNumberWigoToRegister,
        uint256 _newNumberWigoToUpdate
    ) external onlyOwner {
        numberWigoToReactivate = _newNumberWigoToReactivate;
        numberWigoToRegister = _newNumberWigoToRegister;
        numberWigoToUpdate = _newNumberWigoToUpdate;
    }

    /**
     * @notice Sets referral share
     * @dev Callable only by owner admins.
     */
    function setReferralShare(
        uint256 _referralFeeShare,
        uint256 _referralPointShare
    ) external onlyOwner {
        require(
            _referralFeeShare <= MAX_REFERRAL_SHARE,
            "referralFeeShare cannot be more than MAX_REFERRAL_SHARE"
        );
        require(
            _referralPointShare <= MAX_REFERRAL_SHARE,
            "referralPointShare cannot be more than MAX_REFERRAL_SHARE"
        );
        referralFeeShare = _referralFeeShare;
        referralPointShare = _referralPointShare;
        emit SetReferralShare(
            msg.sender,
            _referralFeeShare,
            _referralPointShare
        );
    }

    /**
     * @dev Check the resident's profile for a given address
     */
    function getResidentProfile(address _residentAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            bool
        )
    {
        require(hasRegistered[_residentAddress], "Not registered");
        return (
            residents[_residentAddress].residentId,
            residents[_residentAddress].numberPoints,
            residents[_residentAddress].planetId,
            residents[_residentAddress].nftAddress,
            residents[_residentAddress].tokenId,
            residents[_residentAddress].referral,
            residents[_residentAddress].isActive
        );
    }

    /**
     * @dev Check the resident's status for a given address
     */
    function getResidentStatus(address _residentAddress)
        external
        view
        returns (bool)
    {
        return (residents[_residentAddress].isActive);
    }

    /**
     * @dev Check a planet's profile
     */
    function getPlanetProfile(uint256 _planetId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        require(
            (_planetId <= numberPlanets) && (_planetId > 0),
            "planetId invalid"
        );
        return (
            planets[_planetId].planetName,
            planets[_planetId].planetDescription,
            planets[_planetId].numberResidents,
            planets[_planetId].numberPoints,
            planets[_planetId].isJoinable
        );
    }

    /**
     * @dev Check total referred by resident
     */
    function getTotalReferred(address _residentAddress)
        external
        view
        returns (
            uint256
        )
    {
        require(hasRegistered[_residentAddress], "Resident doesn't exist");
        return (
            referrals[residents[_residentAddress].residentId].totalReferred
        );
    }

    /**
     * @dev Check a referral data
     */
    function getReferralData(address _residentAddress)
        external
        view
        returns (address, bool, uint256)
    {
        require(hasRegistered[_residentAddress], "Resident doesn't exist");
        return (
            referrals[residents[_residentAddress].referral].residentAddress,
            residents[
                referrals[residents[_residentAddress].referral].residentAddress
            ].isActive,
            referrals[residents[_residentAddress].referral].totalReferred
        );
    }
}

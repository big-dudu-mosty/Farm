// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./SeedNFT.sol";
import "./LandNFT.sol";
import "./Shop.sol";
import "./KindnessToken.sol";

contract FarmGame is Ownable, ReentrancyGuard {
    SeedNFT public immutable seedNFT;
    LandNFT public immutable landNFT;
    Shop public immutable shop;
    KindnessToken public immutable kindToken;
    
    enum BoosterType { Watering, Fertilizing }
    
    struct BoosterPrice {
        uint256 nativePrice;
        uint256 kindPrice;
        bool availableForNative;
        bool availableForKind;
    }
    
    struct PlayerStats {
        uint256 totalCropsHarvested;
        uint256 totalCropsStolen;
        uint256 totalHelpProvided;
    }
    
    mapping(BoosterType => BoosterPrice) public boosterPrices;
    mapping(address => mapping(uint256 => uint256)) public dailyHelps; // player => day => count
    mapping(address => PlayerStats) public playerStats;
    mapping(address => uint256) public lastHelpDay;
    
    uint256 public constant DAILY_HELP_LIMIT = 15;
    uint256 public constant MAX_BOOSTERS_PER_CROP = 10;
    uint256 public constant WATERING_TIME_REDUCTION = 2 minutes;
    uint256 public constant FERTILIZING_PERCENTAGE_REDUCTION = 5; // 5%
    
    // Weather randomness tracking
    mapping(uint256 => uint256) public weatherRequestToLand;
    uint256 private _weatherRequestCounter;
    
    event LandClaimed(address indexed player, uint256 indexed landId, uint256 indexed tokenId);
    event CropHarvested(address indexed player, uint256 indexed landId, uint256 indexed seedTokenId);
    event CropStolen(address indexed thief, address indexed victim, uint256 indexed landId, uint256 seedTokenId);
    event BoosterApplied(address indexed player, uint256 indexed landId, BoosterType boosterType);
    event HelpProvided(address indexed helper, address indexed helped, uint256 indexed landId, BoosterType boosterType);
    event WeatherRequested(uint256 indexed landId, uint256 requestId);
    event WeatherUpdated(uint256 indexed landId, uint256 weatherSeed);
    event SeedPurchased(address indexed buyer, SeedNFT.CropType cropType, uint256 tokenId, bool paidWithKind, uint256 price);
    
    constructor(
        address _seedNFT,
        address _landNFT,
        address _shop,
        address _kindToken
    ) Ownable(msg.sender) {
        seedNFT = SeedNFT(_seedNFT);
        landNFT = LandNFT(_landNFT);
        shop = Shop(_shop);
        kindToken = KindnessToken(_kindToken);
        
        // Initialize booster prices
        boosterPrices[BoosterType.Watering] = BoosterPrice({
            nativePrice: 0.0001 ether,
            kindPrice: 1 * 10**18, // 1 KIND
            availableForNative: true,
            availableForKind: true
        });
        
        boosterPrices[BoosterType.Fertilizing] = BoosterPrice({
            nativePrice: 0.0002 ether,
            kindPrice: 2 * 10**18, // 2 KIND
            availableForNative: true,
            availableForKind: true
        });
    }
    
    function claimLand(uint256 landId, uint256 tokenId) external nonReentrant {
        require(seedNFT.ownerOf(tokenId) == msg.sender, "FarmGame: Not seed owner");
        require(seedNFT.getSeedInfo(tokenId).growthStage == SeedNFT.GrowthStage.Seed, "FarmGame: Seed not in Seed stage");
        
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.state == LandNFT.LandState.Idle, "FarmGame: Land not available");
        require(block.timestamp >= land.lockEndTime, "FarmGame: Land in cooldown");
        
        // Claim the land and bind SeedNFT
        landNFT.claimLand(landId, tokenId, msg.sender);
        
        // Start seed growing
        seedNFT.startGrowing(tokenId);
        
        // Generate weather randomness
        uint256 requestId = _requestWeatherRandomness(landId);
        
        emit LandClaimed(msg.sender, landId, tokenId);
        emit WeatherRequested(landId, requestId);
    }
    
    function buySeedWithNative(SeedNFT.CropType cropType) external payable nonReentrant {
        Shop.SeedPrice memory price = shop.getSeedPrice(cropType);
        require(price.availableForNative, "FarmGame: Seed not available for native token");
        require(msg.value >= price.nativePrice, "FarmGame: Insufficient payment");
        
        // Mint seed NFT directly
        SeedNFT.Rarity rarity = _getRarityForCropType(cropType);
        uint256 tokenId = seedNFT.mintSeed(msg.sender, cropType, rarity);
        
        // Update shop statistics (we'll need to add this function to shop later)
        // For now, just emit event
        
        emit SeedPurchased(msg.sender, cropType, tokenId, false, price.nativePrice);
        
        // Refund excess payment
        if (msg.value > price.nativePrice) {
            payable(msg.sender).transfer(msg.value - price.nativePrice);
        }
    }
    
    function buySeedWithKind(SeedNFT.CropType cropType) external nonReentrant {
        Shop.SeedPrice memory price = shop.getSeedPrice(cropType);
        require(price.availableForKind, "FarmGame: Seed not available for KIND token");
        require(kindToken.balanceOf(msg.sender) >= price.kindPrice, "FarmGame: Insufficient KIND balance");
        
        // Burn KIND tokens
        kindToken.burn(msg.sender, price.kindPrice);
        
        // Mint seed NFT directly
        SeedNFT.Rarity rarity = _getRarityForCropType(cropType);
        uint256 tokenId = seedNFT.mintSeed(msg.sender, cropType, rarity);
        
        emit SeedPurchased(msg.sender, cropType, tokenId, true, price.kindPrice);
    }
    
    function _getRarityForCropType(SeedNFT.CropType cropType) private pure returns (SeedNFT.Rarity) {
        // Common crops
        if (cropType == SeedNFT.CropType.Wheat || 
            cropType == SeedNFT.CropType.Corn || 
            cropType == SeedNFT.CropType.Pumpkin) {
            return SeedNFT.Rarity.Common;
        }
        // Rare crops
        if (cropType == SeedNFT.CropType.Strawberry || 
            cropType == SeedNFT.CropType.Grape || 
            cropType == SeedNFT.CropType.Watermelon) {
            return SeedNFT.Rarity.Rare;
        }
        return SeedNFT.Rarity.Common;
    }
    
    function harvestCrop(uint256 landId) external nonReentrant {
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.currentFarmer == msg.sender, "FarmGame: Not the farmer");
        require(land.state == LandNFT.LandState.Ripe, "FarmGame: Crop not ready");
        
        uint256 seedTokenId = land.seedTokenId;
        
        // Harvest the crop
        landNFT.harvestCrop(landId);
        
        // Mature the seed NFT
        seedNFT.matureSeed(seedTokenId);
        
        // Update player stats
        playerStats[msg.sender].totalCropsHarvested++;
        
        emit CropHarvested(msg.sender, landId, seedTokenId);
    }
    
    function stealCrop(uint256 landId) external nonReentrant {
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.currentFarmer != msg.sender, "FarmGame: Cannot steal from yourself");
        require(land.state == LandNFT.LandState.Ripe, "FarmGame: Crop not ready");
        
        uint256 seedTokenId = land.seedTokenId;
        address victim = land.currentFarmer;
        
        // Transfer the seed NFT to the thief using force transfer
        seedNFT.forceTransfer(victim, msg.sender, seedTokenId);
        
        // Steal the crop
        landNFT.stealCrop(landId);
        
        // Mature the seed NFT
        seedNFT.matureSeed(seedTokenId);
        
        // Update stats
        playerStats[msg.sender].totalCropsStolen++;
        
        emit CropStolen(msg.sender, victim, landId, seedTokenId);
    }
    
    function applyBooster(uint256 landId, BoosterType boosterType, bool payWithKind) external payable nonReentrant {
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.currentFarmer == msg.sender, "FarmGame: Not the farmer");
        require(land.state == LandNFT.LandState.Growing, "FarmGame: Crop not growing");
        
        uint256 seedTokenId = land.seedTokenId;
        SeedNFT.SeedInfo memory seedInfo = seedNFT.getSeedInfo(seedTokenId);
        require(seedInfo.boostersApplied < MAX_BOOSTERS_PER_CROP, "FarmGame: Max boosters reached");
        
        BoosterPrice memory price = boosterPrices[boosterType];
        
        if (payWithKind) {
            require(price.availableForKind, "FarmGame: Booster not available for KIND");
            require(kindToken.balanceOf(msg.sender) >= price.kindPrice, "FarmGame: Insufficient KIND");
            kindToken.burn(msg.sender, price.kindPrice);
        } else {
            require(price.availableForNative, "FarmGame: Booster not available for native token");
            require(msg.value >= price.nativePrice, "FarmGame: Insufficient payment");
            
            // Refund excess payment
            if (msg.value > price.nativePrice) {
                payable(msg.sender).transfer(msg.value - price.nativePrice);
            }
        }
        
        // Apply the booster
        seedNFT.applyBooster(seedTokenId);
        
        emit BoosterApplied(msg.sender, landId, boosterType);
    }
    
    function helpOther(uint256 landId, BoosterType boosterType, bool payWithKind) external payable nonReentrant {
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.currentFarmer != msg.sender, "FarmGame: Cannot help yourself");
        require(land.currentFarmer != address(0), "FarmGame: No farmer on this land");
        require(land.state == LandNFT.LandState.Growing, "FarmGame: Crop not growing");
        
        uint256 currentDay = block.timestamp / 1 days;
        
        // Reset daily help count if it's a new day
        if (lastHelpDay[msg.sender] < currentDay) {
            dailyHelps[msg.sender][currentDay] = 0;
            lastHelpDay[msg.sender] = currentDay;
        }
        
        require(dailyHelps[msg.sender][currentDay] < DAILY_HELP_LIMIT, "FarmGame: Daily help limit reached");
        
        uint256 seedTokenId = land.seedTokenId;
        SeedNFT.SeedInfo memory seedInfo = seedNFT.getSeedInfo(seedTokenId);
        require(seedInfo.boostersApplied < MAX_BOOSTERS_PER_CROP, "FarmGame: Max boosters reached");
        
        BoosterPrice memory price = boosterPrices[boosterType];
        
        if (payWithKind) {
            require(price.availableForKind, "FarmGame: Booster not available for KIND");
            require(kindToken.balanceOf(msg.sender) >= price.kindPrice, "FarmGame: Insufficient KIND");
            kindToken.burn(msg.sender, price.kindPrice);
        } else {
            require(price.availableForNative, "FarmGame: Booster not available for native token");
            require(msg.value >= price.nativePrice, "FarmGame: Insufficient payment");
            
            // Refund excess payment
            if (msg.value > price.nativePrice) {
                payable(msg.sender).transfer(msg.value - price.nativePrice);
            }
        }
        
        // Apply the booster to the other player's crop
        seedNFT.applyBooster(seedTokenId);
        
        // Reward the helper with KIND tokens
        kindToken.rewardKindness(msg.sender, land.currentFarmer);
        
        // Update counters
        dailyHelps[msg.sender][currentDay]++;
        playerStats[msg.sender].totalHelpProvided++;
        
        emit HelpProvided(msg.sender, land.currentFarmer, landId, boosterType);
    }
    
    function checkAndAdvanceGrowth(uint256 landId) external {
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        require(land.state == LandNFT.LandState.Growing, "FarmGame: Land not growing");
        
        uint256 seedTokenId = land.seedTokenId;
        SeedNFT.SeedInfo memory seedInfo = seedNFT.getSeedInfo(seedTokenId);
        
        // Calculate effective growth time with boosters
        uint256 effectiveGrowthTime = _calculateEffectiveGrowthTime(seedInfo);
        
        // Advance growth progress with weather effects
        bool isRipe = landNFT.advanceGrowth(landId, effectiveGrowthTime);
        
        if (isRipe) {
            // Crop is ready for harvest
        }
    }
    
    function _calculateEffectiveGrowthTime(SeedNFT.SeedInfo memory seedInfo) private pure returns (uint256) {
        uint256 baseTime = seedInfo.baseGrowthTime;
        uint256 boostersApplied = seedInfo.boostersApplied;
        
        // Apply time reduction from watering (assuming half are watering, half fertilizing)
        uint256 wateringBoosters = boostersApplied / 2;
        uint256 fertilizingBoosters = boostersApplied - wateringBoosters;
        
        // Watering reduces time by 2 minutes per application
        baseTime = baseTime > (wateringBoosters * WATERING_TIME_REDUCTION) ? 
                   baseTime - (wateringBoosters * WATERING_TIME_REDUCTION) : 0;
        
        // Fertilizing reduces time by 5% per application
        for (uint256 i = 0; i < fertilizingBoosters; i++) {
            baseTime = (baseTime * (100 - FERTILIZING_PERCENTAGE_REDUCTION)) / 100;
        }
        
        return baseTime;
    }
    
    function _requestWeatherRandomness(uint256 landId) private returns (uint256 requestId) {
        // Generate deterministic request ID
        requestId = _weatherRequestCounter++;
        weatherRequestToLand[requestId] = landId;
        
        // Generate secure weather seed using blockhash approach
        uint256 weatherSeed = _generateWeatherSeed(landId, msg.sender);
        
        landNFT.setWeatherSeed(landId, weatherSeed);
        emit WeatherUpdated(landId, weatherSeed);
        
        return requestId;
    }
    
    function _generateWeatherSeed(uint256 landId, address user) private view returns (uint256) {
        bytes32 prevBlockHash = block.number > 0 ? blockhash(block.number - 1) : bytes32(0);
        return uint256(keccak256(abi.encodePacked(
            prevBlockHash,                  // 前一个区块的哈希
            block.timestamp,                // 当前时间戳
            user,                          // 用户地址
            landId,                        // 土地ID
            block.prevrandao               // 区块随机数（替代difficulty）
        )));
    }
    
    
    function updateBoosterPrice(
        BoosterType boosterType,
        uint256 nativePrice,
        uint256 kindPrice,
        bool availableForNative,
        bool availableForKind
    ) external onlyOwner {
        boosterPrices[boosterType] = BoosterPrice({
            nativePrice: nativePrice,
            kindPrice: kindPrice,
            availableForNative: availableForNative,
            availableForKind: availableForKind
        });
    }
    
    
    function getPlayerStats(address player) external view returns (PlayerStats memory) {
        return playerStats[player];
    }
    
    function getRemainingDailyHelps(address helper) external view returns (uint256) {
        uint256 currentDay = block.timestamp / 1 days;
        
        if (lastHelpDay[helper] < currentDay) {
            return DAILY_HELP_LIMIT;
        }
        
        uint256 used = dailyHelps[helper][currentDay];
        return used >= DAILY_HELP_LIMIT ? 0 : DAILY_HELP_LIMIT - used;
    }
    
    function getBoosterPrice(BoosterType boosterType) external view returns (BoosterPrice memory) {
        return boosterPrices[boosterType];
    }
    
    function getSeedPrice(SeedNFT.CropType cropType) external view returns (Shop.SeedPrice memory) {
        return shop.getSeedPrice(cropType);
    }
    
    function getAvailableSeedsForNative() external view returns (SeedNFT.CropType[] memory) {
        return shop.getAvailableSeedsForNative();
    }
    
    function getAvailableSeedsForKind() external view returns (SeedNFT.CropType[] memory) {
        return shop.getAvailableSeedsForKind();
    }
    
    function emergencyPause() external onlyOwner {
        // Emergency pause functionality if needed
    }
    
    function withdrawNative() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "FarmGame: No native tokens to withdraw");
        payable(owner()).transfer(balance);
    }
}
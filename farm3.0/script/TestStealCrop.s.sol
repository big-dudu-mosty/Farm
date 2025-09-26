// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/FarmGame.sol";
import "../src/SeedNFT.sol";
import "../src/LandNFT.sol";
import "../src/KindnessToken.sol";
import "../src/Shop.sol";

contract TestStealCrop is Script {
    // Dynamic contract addresses (will be set after deployment)
    FarmGame public farmGame;
    SeedNFT public seedNFT;
    LandNFT public landNFT;
    KindnessToken public kindToken;
    Shop public shop;

    // Test accounts (anvil default accounts)
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant FARMER_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant THIEF_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    address constant DEPLOYER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant FARMER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant THIEF = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    uint256 constant TOTAL_LANDS = 10; // Smaller for focused testing

    function run() external {
        console.log("=== DEDICATED STEAL CROP TEST ===");
        console.log("Testing the complete steal mechanism...");

        // Deploy contracts
        deployAllContracts();

        // Setup: Farmer plants crop
        console.log("\n=== SETUP: FARMER PLANTS CROP ===");
        setupFarmerCrop();

        // Fast forward to make crop ripe
        console.log("\n=== FAST FORWARD TO RIPENESS ===");
        fastForwardToRipe();

        // Test stealing mechanism
        console.log("\n=== TESTING STEAL MECHANISM ===");
        testStealMechanism();

        // Verify results
        console.log("\n=== VERIFYING STEAL RESULTS ===");
        verifyStealResults();

        console.log("\n=== STEAL TEST COMPLETED ===");
    }

    function deployAllContracts() internal {
        vm.startBroadcast(DEPLOYER_KEY);

        console.log("Deploying contracts for steal test...");

        seedNFT = new SeedNFT();
        kindToken = new KindnessToken();
        landNFT = new LandNFT(TOTAL_LANDS);
        shop = new Shop(address(seedNFT), address(kindToken));
        farmGame = new FarmGame(
            address(seedNFT),
            address(landNFT),
            address(shop),
            address(kindToken)
        );

        // Set permissions
        seedNFT.transferOwnership(address(farmGame));
        landNFT.transferOwnership(address(farmGame));
        kindToken.transferOwnership(address(farmGame));
        shop.transferOwnership(address(farmGame));

        console.log("  Contracts deployed and configured");

        vm.stopBroadcast();

        // Fund accounts
        vm.deal(FARMER, 10 ether);
        vm.deal(THIEF, 10 ether);
        console.log("  Test accounts funded");
    }

    function setupFarmerCrop() internal {
        // Farmer buys seed and claims land
        vm.startBroadcast(FARMER_KEY);

        console.log("Farmer buying wheat seed...");
        farmGame.buySeedWithNative{value: 0.001 ether}(SeedNFT.CropType.Wheat);

        console.log("Farmer claiming land 0...");
        farmGame.claimLand(0, 0);

        vm.stopBroadcast();

        // Verify setup
        LandNFT.LandInfo memory land = landNFT.getLandInfo(0);
        SeedNFT.SeedInfo memory seed = seedNFT.getSeedInfo(0);

        console.log("  Land state:", uint256(land.state)); // Should be Growing (1)
        console.log("  Seed stage:", uint256(seed.growthStage)); // Should be Growing (1)
        console.log("  Current farmer:", land.currentFarmer);
        console.log("  Seed owner:", seedNFT.ownerOf(0));
    }

    function fastForwardToRipe() internal {
        uint256 landId = 0;
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);

        console.log("Starting growth acceleration...");
        console.log("  Initial growth:", land.accumulatedGrowth);
        console.log("  Target growth: 3600 (1 hour)");

        uint256 attempts = 0;
        while (land.state != LandNFT.LandState.Ripe && attempts < 10) {
            attempts++;

            // Warp time by 15 minutes
            vm.warp(block.timestamp + 900);
            console.log("  Time warped to:", block.timestamp);

            // Advance growth
            try farmGame.checkAndAdvanceGrowth(landId) {
                land = landNFT.getLandInfo(landId);
                console.log("    Attempt", attempts, "- Growth:", land.accumulatedGrowth, "State:", uint256(land.state));

                if (land.state == LandNFT.LandState.Ripe) {
                    console.log("  SUCCESS: Crop is now RIPE and ready for stealing!");
                    break;
                }
            } catch Error(string memory reason) {
                console.log("    Growth failed:", reason);
            }
        }

        if (land.state != LandNFT.LandState.Ripe) {
            console.log("  ERROR: Failed to ripen crop after", attempts, "attempts");
            return;
        }
    }

    function testStealMechanism() internal {
        uint256 landId = 0;
        uint256 seedId = 0;

        // Check pre-steal state
        console.log("Pre-steal verification:");
        address originalSeedOwner = seedNFT.ownerOf(seedId);
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);

        console.log("  Original seed owner:", originalSeedOwner);
        console.log("  Land farmer:", land.currentFarmer);
        console.log("  Land state:", uint256(land.state));

        require(originalSeedOwner == FARMER, "Seed should be owned by farmer");
        require(land.currentFarmer == FARMER, "Land should be farmed by farmer");
        require(land.state == LandNFT.LandState.Ripe, "Crop should be ripe");

        // Get thief's initial stats
        FarmGame.PlayerStats memory thiefStatsBefore = farmGame.getPlayerStats(THIEF);
        console.log("  Thief stolen crops before:", thiefStatsBefore.totalCropsStolen);

        // Execute the steal!
        console.log("\nExecuting steal operation...");
        vm.startBroadcast(THIEF_KEY);

        try farmGame.stealCrop(landId) {
            console.log("  SUCCESS: Steal operation completed!");
        } catch Error(string memory reason) {
            console.log("  FAILED: Steal failed -", reason);
            vm.stopBroadcast();
            return;
        }

        vm.stopBroadcast();
    }

    function verifyStealResults() internal {
        uint256 landId = 0;
        uint256 seedId = 0;

        console.log("Verifying steal results:");

        // Check seed ownership change
        address newSeedOwner = seedNFT.ownerOf(seedId);
        console.log("  New seed owner:", newSeedOwner);
        console.log("  Expected owner (thief):", THIEF);

        if (newSeedOwner == THIEF) {
            console.log("  PASS: Seed ownership transferred to thief");
        } else {
            console.log("  FAIL: Seed ownership not transferred");
        }

        // Check seed maturation
        SeedNFT.SeedInfo memory seed = seedNFT.getSeedInfo(seedId);
        console.log("  Seed growth stage:", uint256(seed.growthStage));

        if (seed.growthStage == SeedNFT.GrowthStage.Mature) {
            console.log("PASS: Seed properly matured");
        } else {
            console.log("FAIL: Seed not matured");
        }

        // Check land state
        LandNFT.LandInfo memory land = landNFT.getLandInfo(landId);
        console.log("  Land state:", uint256(land.state));
        console.log("  Land farmer:", land.currentFarmer);

        if (land.state == LandNFT.LandState.LockedIdle) {
            console.log(" PASS: Land entered cooldown");
        } else {
            console.log(" FAIL: Land not in cooldown state");
        }

        if (land.currentFarmer == address(0)) {
            console.log("  PASS: Land farmer cleared");
        } else {
            console.log("  FAIL: Land farmer not cleared");
        }

        // Check thief's stats
        FarmGame.PlayerStats memory thiefStatsAfter = farmGame.getPlayerStats(THIEF);
        console.log("  Thief stolen crops after:", thiefStatsAfter.totalCropsStolen);

        if (thiefStatsAfter.totalCropsStolen == 1) {
            console.log("  PASS: Thief stats updated correctly");
        } else {
            console.log("  FAIL: Thief stats not updated");
        }

        // Test cooldown period
        if (land.lockEndTime > block.timestamp) {
            uint256 cooldownRemaining = land.lockEndTime - block.timestamp;
            console.log("  Cooldown remaining:", cooldownRemaining, "seconds");

            if (cooldownRemaining == 300) { // 5 minutes
                console.log("  PASS: Correct cooldown period (5 minutes)");
            } else {
                console.log("  FAIL: Incorrect cooldown period");
            }
        }

        // Final summary
        console.log("\n=== STEAL TEST SUMMARY ===");
        bool allTestsPassed = (
            newSeedOwner == THIEF &&
            seed.growthStage == SeedNFT.GrowthStage.Mature &&
            land.state == LandNFT.LandState.LockedIdle &&
            land.currentFarmer == address(0) &&
            thiefStatsAfter.totalCropsStolen == 1
        );

        if (allTestsPassed) {
            console.log(" ALL STEAL TESTS PASSED! Steal mechanism works perfectly!");
        } else {
            console.log("Some steal tests failed. Check the results above.");
        }
    }
}
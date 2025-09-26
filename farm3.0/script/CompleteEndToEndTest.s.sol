// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/FarmGame.sol";
import "../src/SeedNFT.sol";
import "../src/LandNFT.sol";
import "../src/KindnessToken.sol";

contract CompleteEndToEndTest is Script {
    // New deployment with latest fixes - Block 39156549
    FarmGame constant farmGame = FarmGame(0xF6121A319b094c44f1B1D8A24BAd116D37C66E33);
    SeedNFT constant seedNFT = SeedNFT(0x574a7B2b86d2957F1266A3F7F6eD586885512a05);
    LandNFT constant landNFT = LandNFT(0x6D2145b588aD0ED722077C54Fa04c0fceEEf6643);
    KindnessToken constant kindToken = KindnessToken(0x8411b1120a1ADBd0f7270d70eCb55cfEa01984c1);

    uint256 constant PLAYER_A_KEY = 0x6e624f2006b84453d1b76e56f503a7e5026f407a95f210e61fa5026e7afffda5;
    uint256 constant PLAYER_B_KEY = 0x2df90fa7e3eba925e55fc0a65abb03a08b4e78ffc02d2b523533a66a93adba7f;
    address constant PLAYER_A = 0x45e1913258cb5dFC3EE683beCCFEBb0E3102374f;
    address constant PLAYER_B = 0xd857e1E4E3c042B1cF0996E89A54C686bA87f8E2;

    function run() external {
        console.log("=== COMPLETE END-TO-END CHAIN TEST ===");
        console.log("Testing ALL game features on actual chain...");

        // Test 1: Buy seeds (both players)
        console.log("\n1. TESTING SEED PURCHASE");
        testSeedPurchase();

        // Test 2: Land claiming
        console.log("\n2. TESTING LAND CLAIMING");
        testLandClaiming();

        // Test 3: Helper system
        console.log("\n3. TESTING HELPER SYSTEM");
        testHelperSystem();

        // Test 4: Weather and growth over time
        console.log("\n4. TESTING WEATHER & GROWTH PROGRESSION");
        testWeatherAndGrowth();

        // Test 5: Try stealing before ripe
        console.log("\n5. TESTING STEAL PROTECTION");
        testStealProtection();

        // Test 6: Complete growth cycle
        console.log("\n6. TESTING COMPLETE GROWTH CYCLE");
        testCompleteGrowthCycle();

        // Test 7: Final harvest or steal
        console.log("\n7. TESTING HARVEST/STEAL");
        testHarvestOrSteal();

        // Test 8: Land cooldown
        console.log("\n8. TESTING LAND COOLDOWN");
        testLandCooldown();

        console.log("\n=== END-TO-END TEST SUMMARY ===");
        printFinalStatus();
    }

    function testSeedPurchase() internal {
        vm.startBroadcast(PLAYER_A_KEY);

        console.log("Player A buying wheat seed...");
        try farmGame.buySeedWithNative{value: 0.001 ether}(SeedNFT.CropType.Wheat) {
            console.log("  SUCCESS: Player A bought wheat seed");
        } catch Error(string memory reason) {
            console.log("  FAILED:", reason);
        }

        vm.stopBroadcast();

        vm.startBroadcast(PLAYER_B_KEY);

        console.log("Player B buying corn seed...");
        try farmGame.buySeedWithNative{value: 0.0015 ether}(SeedNFT.CropType.Corn) {
            console.log("  SUCCESS: Player B bought corn seed");
        } catch Error(string memory reason) {
            console.log("  FAILED:", reason);
        }

        vm.stopBroadcast();

        // Check balances
        uint256 balanceA = seedNFT.balanceOf(PLAYER_A);
        uint256 balanceB = seedNFT.balanceOf(PLAYER_B);
        console.log("  Player A seeds:", balanceA);
        console.log("  Player B seeds:", balanceB);
    }

    function testLandClaiming() internal {
        uint256[] memory availableLands = landNFT.getAvailableLands();
        console.log("Available lands:", availableLands.length);

        if (availableLands.length < 2) {
            console.log("  ERROR: Need at least 2 available lands");
            return;
        }

        // Player A claims land 0
        vm.startBroadcast(PLAYER_A_KEY);
        uint256 tokenIdA = findPlayerSeedToken(PLAYER_A);
        if (tokenIdA != type(uint256).max) {
            try farmGame.claimLand(availableLands[0], tokenIdA) {
                console.log("  SUCCESS: Player A claimed land", availableLands[0]);
            } catch Error(string memory reason) {
                console.log("  FAILED: Player A -", reason);
            }
        }
        vm.stopBroadcast();

        // Player B claims land 1
        vm.startBroadcast(PLAYER_B_KEY);
        uint256 tokenIdB = findPlayerSeedToken(PLAYER_B);
        if (tokenIdB != type(uint256).max) {
            try farmGame.claimLand(availableLands[1], tokenIdB) {
                console.log("  SUCCESS: Player B claimed land", availableLands[1]);
            } catch Error(string memory reason) {
                console.log("  FAILED: Player B -", reason);
            }
        }
        vm.stopBroadcast();
    }

    function testHelperSystem() internal {
        // Find Player A's land
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) {
            console.log("  ERROR: Player A has no land");
            return;
        }

        console.log("Player B helping Player A on land", landIdA);

        vm.startBroadcast(PLAYER_B_KEY);
        try farmGame.helpOther{value: 0.0001 ether}(landIdA, FarmGame.BoosterType.Watering, false) {
            console.log("  SUCCESS: Player B helped with watering");

            uint256 kindBalance = kindToken.balanceOf(PLAYER_B);
            console.log("  Player B KIND balance:", kindBalance);
        } catch Error(string memory reason) {
            console.log("  FAILED:", reason);
        }
        vm.stopBroadcast();
    }

    function testWeatherAndGrowth() internal {
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) return;

        console.log("Testing weather and growth on land", landIdA);

        LandNFT.LandInfo memory land = landNFT.getLandInfo(landIdA);
        console.log("  Initial growth:", land.accumulatedGrowth);
        console.log("  Current time:", block.timestamp);

        // Advance growth multiple times with real time gaps
        for (uint256 i = 0; i < 3; i++) {
            console.log("  Growth attempt", i + 1);

            try farmGame.checkAndAdvanceGrowth(landIdA) {
                LandNFT.LandInfo memory updatedLand = landNFT.getLandInfo(landIdA);
                console.log("    New growth:", updatedLand.accumulatedGrowth);
                console.log("    Land state:", uint256(updatedLand.state));

                if (updatedLand.state == LandNFT.LandState.Ripe) {
                    console.log("    RIPE: Ready for harvest!");
                    break;
                }
            } catch Error(string memory reason) {
                console.log("    FAILED:", reason);
            }

            // Wait some time between attempts (only effective in real time)
            console.log("    Waiting for next growth check...");
        }
    }

    function testStealProtection() internal {
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) return;

        LandNFT.LandInfo memory land = landNFT.getLandInfo(landIdA);
        console.log("Testing steal on land", landIdA, "state:", uint256(land.state));

        vm.startBroadcast(PLAYER_B_KEY);
        try farmGame.stealCrop(landIdA) {
            console.log("  ERROR: Steal should not have succeeded!");
        } catch Error(string memory reason) {
            console.log("  CORRECT: Steal properly blocked -", reason);
        }
        vm.stopBroadcast();
    }

    function testCompleteGrowthCycle() internal {
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) return;

        console.log("Attempting to complete growth cycle for land", landIdA);

        LandNFT.LandInfo memory land = landNFT.getLandInfo(landIdA);
        console.log("  Current progress:", land.accumulatedGrowth, "/ 3600 needed");

        // Multiple attempts to reach ripeness
        uint256 attempts = 0;
        uint256 maxAttempts = 10;

        while (land.state != LandNFT.LandState.Ripe && attempts < maxAttempts) {
            attempts++;
            console.log("  Attempt", attempts, "to advance growth");

            try farmGame.checkAndAdvanceGrowth(landIdA) {
                land = landNFT.getLandInfo(landIdA);
                console.log("    Progress:", land.accumulatedGrowth, "State:", uint256(land.state));

                if (land.state == LandNFT.LandState.Ripe) {
                    console.log("    SUCCESS: Crop is now RIPE!");
                    return;
                }
            } catch Error(string memory reason) {
                console.log("    FAILED:", reason);
            }
        }

        console.log("  RESULT: Crop", land.state == LandNFT.LandState.Ripe ? "IS RIPE" : "NOT YET RIPE");
    }

    function testHarvestOrSteal() internal {
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) return;

        LandNFT.LandInfo memory land = landNFT.getLandInfo(landIdA);

        if (land.state == LandNFT.LandState.Ripe) {
            console.log("Crop is ripe! Testing harvest vs steal...");

            // 50% chance each player tries to get the crop
            if (block.timestamp % 2 == 0) {
                // Player A harvests
                console.log("Player A attempting harvest...");
                vm.startBroadcast(PLAYER_A_KEY);
                try farmGame.harvestCrop(landIdA) {
                    console.log("  SUCCESS: Player A harvested their crop!");
                } catch Error(string memory reason) {
                    console.log("  FAILED:", reason);
                }
                vm.stopBroadcast();
            } else {
                // Player B steals
                console.log("Player B attempting steal...");
                vm.startBroadcast(PLAYER_B_KEY);
                try farmGame.stealCrop(landIdA) {
                    console.log("  SUCCESS: Player B stole the crop!");
                } catch Error(string memory reason) {
                    console.log("  FAILED:", reason);
                }
                vm.stopBroadcast();
            }
        } else {
            console.log("Crop not yet ripe for harvest/steal");
        }
    }

    function testLandCooldown() internal {
        uint256 landIdA = findPlayerLand(PLAYER_A);
        if (landIdA == type(uint256).max) return;

        LandNFT.LandInfo memory land = landNFT.getLandInfo(landIdA);
        console.log("Land", landIdA, "state:", uint256(land.state));

        if (land.state == LandNFT.LandState.LockedIdle) {
            console.log("  Land is in cooldown");
            if (land.lockEndTime > block.timestamp) {
                uint256 remaining = land.lockEndTime - block.timestamp;
                console.log("  Cooldown remaining:", remaining, "seconds");
            } else {
                console.log("  Cooldown expired, land should be available");
            }
        }
    }

    function printFinalStatus() internal view {
        console.log("Player A seed balance:", seedNFT.balanceOf(PLAYER_A));
        console.log("Player B seed balance:", seedNFT.balanceOf(PLAYER_B));
        console.log("Player A KIND balance:", kindToken.balanceOf(PLAYER_A));
        console.log("Player B KIND balance:", kindToken.balanceOf(PLAYER_B));

        uint256[] memory availableLands = landNFT.getAvailableLands();
        console.log("Available lands:", availableLands.length, "/ 100");

        console.log("Test completed at block:", block.number);
        console.log("Test completed at time:", block.timestamp);
    }

    function findPlayerSeedToken(address player) internal view returns (uint256) {
        uint256 totalSupply = seedNFT.totalSupply();
        for (uint256 i = 0; i < totalSupply; i++) {
            try seedNFT.ownerOf(i) returns (address owner) {
                if (owner == player) {
                    return i;
                }
            } catch {
                continue;
            }
        }
        return type(uint256).max;
    }

    function findPlayerLand(address player) internal view returns (uint256) {
        for (uint256 i = 0; i < 100; i++) {
            try landNFT.getLandInfo(i) returns (LandNFT.LandInfo memory land) {
                if (land.currentFarmer == player && land.state != LandNFT.LandState.Idle) {
                    return i;
                }
            } catch {
                continue;
            }
        }
        return type(uint256).max;
    }
}
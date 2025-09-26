// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Shop.sol";

contract DeployShop is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Use deployed contract addresses
        address seedNFTAddress = 0x5ca157233FB3ec7f7C9Bd956527E60d2481C0bCb;
        address kindTokenAddress = 0xdF56ad5e51a39B0A4dfBDa6a99E283344c921e69;
        
        Shop shop = new Shop(seedNFTAddress, kindTokenAddress);
        
        console.log("Shop deployed at:", address(shop));
        console.log("Connected SeedNFT:", seedNFTAddress);
        console.log("Connected KindnessToken:", kindTokenAddress);
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        vm.stopBroadcast();
    }
}
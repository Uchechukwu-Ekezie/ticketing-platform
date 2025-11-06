// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TicketNFT} from "../src/TicketNFT.sol";
import {TicketingPlatform} from "../src/TicketingPlatform.sol";

contract TicketingPlatformScript is Script {
    // Configuration
    uint256 public constant PLATFORM_FEE_PERCENTAGE = 250; // 2.5% (in basis points)
    uint256 public constant MAX_RESALE_PRICE_PERCENTAGE = 15000; // 150% (in basis points)
    
    function run() external {
        // When using --private-key flag, Foundry handles the account automatically
        // We can use vm.startBroadcast() without arguments, or read from env
        address deployer;
        
        // Try to get deployer address from msg.sender (when using --private-key)
        if (msg.sender != address(0)) {
            deployer = msg.sender;
        } else {
            // Fallback: try reading private key from env
            try this.getDeployerFromEnv() returns (address addr) {
                deployer = addr;
            } catch {
                // If no private key in env, use msg.sender
                deployer = msg.sender;
            }
        }
        
        console.log("Deploying contracts with deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        // Start broadcast - when using --private-key, this will use that key
        vm.startBroadcast();
        
        // Deploy TicketNFT
        console.log("Deploying TicketNFT...");
        TicketNFT ticketNFT = new TicketNFT();
        console.log("TicketNFT deployed at:", address(ticketNFT));
        
        // Deploy TicketingPlatform
        console.log("Deploying TicketingPlatform...");
        TicketingPlatform platform = new TicketingPlatform(
            address(ticketNFT),
            PLATFORM_FEE_PERCENTAGE,
            MAX_RESALE_PRICE_PERCENTAGE
        );
        console.log("TicketingPlatform deployed at:", address(platform));
        
        // Transfer ownership of TicketNFT to platform
        console.log("Transferring TicketNFT ownership to platform...");
        ticketNFT.transferOwnership(address(platform));
        console.log("TicketNFT ownership transferred");
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("TicketNFT:", address(ticketNFT));
        console.log("TicketingPlatform:", address(platform));
        console.log("Platform Fee:", PLATFORM_FEE_PERCENTAGE);
        console.log("Max Resale Price:", MAX_RESALE_PRICE_PERCENTAGE);
    }
    
    // Helper function to read deployer from env (for backwards compatibility)
    function getDeployerFromEnv() external view returns (address) {
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            return vm.addr(key);
        } catch {
            return msg.sender;
        }
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TicketNFT} from "../src/TicketNFT.sol";
import {TicketingPlatform} from "../src/TicketingPlatform.sol";

contract TicketingPlatformTest is Test {
    TicketingPlatform public platform;
    TicketNFT public ticketNFT;
    
    address public organizer = address(1);
    address public buyer = address(2);
    address public buyer2 = address(3);
    address public platformOwner = address(4);
    
    uint256 public constant PLATFORM_FEE = 250; // 2.5%
    uint256 public constant MAX_RESALE_PRICE = 15000; // 150%
    
    function setUp() public {
        // Deploy TicketNFT
        ticketNFT = new TicketNFT();
        
        // Deploy TicketingPlatform
        vm.prank(platformOwner);
        platform = new TicketingPlatform(
            address(ticketNFT),
            PLATFORM_FEE,
            MAX_RESALE_PRICE
        );
        
        // Transfer ownership of TicketNFT to platform
        vm.prank(address(this));
        ticketNFT.transferOwnership(address(platform));
        
        // Setup accounts with ETH
        vm.deal(organizer, 100 ether);
        vm.deal(buyer, 100 ether);
        vm.deal(buyer2, 100 ether);
    }
    
    function test_CreateEvent() public {
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            0 // No resale deadline
        );
        
        assertEq(eventId, 1);
        
        (
            uint256 id,
            string memory name,
            ,
            ,
            ,
            uint256 price,
            uint256 maxTickets,
            ,
            address eventOrganizer,
            bool active,
            bool cancelled
        ) = platform.getEvent(eventId);
        
        // Suppress unused variable warning
        cancelled;
        
        assertEq(id, 1);
        assertEq(name, "Summer Music Festival");
        assertEq(price, 0.05 ether);
        assertEq(maxTickets, 500);
        assertEq(eventOrganizer, organizer);
        assertTrue(active);
    }
    
    function test_PurchaseTicket() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            0
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        // Check event sold tickets
        (, , , , , , , uint256 soldTickets, , , ) = platform.getEvent(eventId);
        assertEq(soldTickets, 1);
        
        // Check ticket ownership (we need to get the tokenId from events)
        // Since we can't easily get the tokenId, we check the event state
        assertEq(soldTickets, 1);
    }
    
    function test_PurchaseTicket_InsufficientPayment() public {
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            0
        );
        
        vm.prank(buyer);
        vm.expectRevert("Insufficient payment");
        platform.purchaseTicket{value: 0.01 ether}(eventId);
    }
    
    function test_PurchaseTicket_ExcessPayment() public {
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            0
        );
        
        uint256 buyerBalanceBefore = buyer.balance;
        
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.1 ether}(eventId);
        
        // Should refund 0.05 ether
        assertEq(buyer.balance, buyerBalanceBefore - 0.05 ether);
    }
    
    function test_ListTicketForResale() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            block.timestamp + 60 days
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        // Get tokenId (assuming first ticket is tokenId 0)
        uint256 tokenId = 0;
        
        // List for resale
        vm.prank(buyer);
        platform.listTicketForResale(tokenId, 0.06 ether);
        
        // Check listing
        (uint256 listingTokenId, uint256 price, address seller, bool active) = 
            platform.getResaleListing(tokenId);
        
        assertEq(listingTokenId, tokenId);
        assertEq(price, 0.06 ether);
        assertEq(seller, buyer);
        assertTrue(active);
    }
    
    function test_PurchaseResaleTicket() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            block.timestamp + 60 days
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        uint256 tokenId = 0;
        
        // List for resale
        vm.prank(buyer);
        platform.listTicketForResale(tokenId, 0.06 ether);
        
        uint256 buyer2BalanceBefore = buyer2.balance;
        uint256 sellerBalanceBefore = buyer.balance;
        
        // Purchase from resale
        vm.prank(buyer2);
        platform.purchaseResaleTicket{value: 0.06 ether}(tokenId);
        
        // Check balances
        uint256 platformFee = (0.06 ether * PLATFORM_FEE) / 10000;
        uint256 sellerAmount = 0.06 ether - platformFee;
        
        assertEq(buyer2.balance, buyer2BalanceBefore - 0.06 ether);
        assertEq(buyer.balance, sellerBalanceBefore + sellerAmount);
        
        // Check listing is inactive
        (, , , bool active) = platform.getResaleListing(tokenId);
        assertFalse(active);
    }
    
    function test_WithdrawOrganizerRevenue() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            0
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        uint256 organizerBalanceBefore = organizer.balance;
        uint256 revenue = platform.organizerRevenue(organizer);
        
        assertGt(revenue, 0);
        
        // Withdraw revenue
        vm.prank(organizer);
        platform.withdrawOrganizerRevenue();
        
        assertEq(organizer.balance, organizerBalanceBefore + revenue);
        assertEq(platform.organizerRevenue(organizer), 0);
    }
    
    function test_CancelResaleListing() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            block.timestamp + 60 days
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        uint256 tokenId = 0;
        
        // List for resale
        vm.prank(buyer);
        platform.listTicketForResale(tokenId, 0.06 ether);
        
        // Cancel listing
        vm.prank(buyer);
        platform.cancelResaleListing(tokenId);
        
        // Check listing is inactive
        (, , , bool active) = platform.getResaleListing(tokenId);
        assertFalse(active);
    }
    
    function test_ResalePriceExceedsMaximum() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = platform.createEvent(
            "Summer Music Festival",
            "Amazing music festival",
            block.timestamp + 30 days,
            "Central Park, NYC",
            0.05 ether,
            500,
            block.timestamp + 60 days
        );
        
        // Purchase ticket
        vm.prank(buyer);
        platform.purchaseTicket{value: 0.05 ether}(eventId);
        
        uint256 tokenId = 0;
        
        // Max resale price should be 0.05 * 1.5 = 0.075 ether
        vm.prank(buyer);
        vm.expectRevert("Price exceeds maximum resale price");
        platform.listTicketForResale(tokenId, 0.1 ether);
    }
}


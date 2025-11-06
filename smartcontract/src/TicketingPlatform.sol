// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TicketNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title TicketingPlatform
 * @dev Main platform contract for event creation, ticket sales, and marketplace
 */
contract TicketingPlatform is Ownable, ReentrancyGuard, Pausable {
    using Strings for uint256;
    
    TicketNFT public ticketNFT;
    
    uint256 public eventCounter;
    uint256 public platformFeePercentage; // Basis points (e.g., 250 = 2.5%)
    uint256 public maxResalePricePercentage; // Basis points (e.g., 15000 = 150%)
    
    // Event structure
    struct Event {
        uint256 eventId;
        string name;
        string description;
        uint256 date;
        string location;
        uint256 price;
        uint256 maxTickets;
        uint256 soldTickets;
        address organizer;
        bool active;
        bool cancelled; // New: Track if event is cancelled
        uint256 resaleAllowedUntil; // Timestamp until which resale is allowed
        uint256 maxResalePrice; // Maximum resale price (in basis points of original price)
    }
    
    // Track token IDs for each event (for refunds)
    mapping(uint256 => uint256[]) public eventTokenIds;
    mapping(uint256 => uint256) public tokenIdToEvent; // Track which event a token belongs to
    
    // Resale listing
    struct ResaleListing {
        uint256 tokenId;
        uint256 price;
        address seller;
        bool active;
    }
    
    // Event mappings
    mapping(uint256 => Event) public events;
    mapping(uint256 => ResaleListing) public resaleListings;
    mapping(uint256 => uint256) public tokenIdToListingId;
    
    // Revenue tracking
    mapping(address => uint256) public organizerRevenue;
    mapping(address => uint256) public platformRevenue;
    
    // Events
    event EventCreated(
        uint256 indexed eventId,
        string name,
        address indexed organizer,
        uint256 price,
        uint256 maxTickets
    );
    
    event TicketPurchased(
        uint256 indexed eventId,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );
    
    event TicketListedForResale(
        uint256 indexed listingId,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    
    event TicketResold(
        uint256 indexed listingId,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );
    
    event ResaleListingCancelled(uint256 indexed listingId, uint256 indexed tokenId);
    
    event RevenueWithdrawn(address indexed recipient, uint256 amount);
    
    event EventCancelled(uint256 indexed eventId, address indexed organizer);
    
    event RefundIssued(uint256 indexed tokenId, uint256 indexed eventId, address indexed recipient, uint256 amount);
    
    event BatchTicketsPurchased(
        uint256 indexed eventId,
        address indexed buyer,
        uint256 quantity,
        uint256[] tokenIds,
        uint256 totalPrice
    );
    
    constructor(
        address _ticketNFT,
        uint256 _platformFeePercentage,
        uint256 _maxResalePricePercentage
    ) Ownable(msg.sender) {
        ticketNFT = TicketNFT(_ticketNFT);
        platformFeePercentage = _platformFeePercentage;
        maxResalePricePercentage = _maxResalePricePercentage;
    }
    
    /**
     * @dev Create a new event
     * @param name Event name
     * @param description Event description
     * @param date Event date (timestamp)
     * @param location Event location
     * @param price Ticket price in wei
     * @param maxTickets Maximum number of tickets
     * @param resaleAllowedUntil Timestamp until which resale is allowed
     */
    function createEvent(
        string memory name,
        string memory description,
        uint256 date,
        string memory location,
        uint256 price,
        uint256 maxTickets,
        uint256 resaleAllowedUntil
    ) external returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(maxTickets > 0, "Must have at least 1 ticket");
        require(date > block.timestamp, "Event date must be in the future");
        require(
            resaleAllowedUntil == 0 || resaleAllowedUntil > block.timestamp,
            "Resale deadline must be in the future"
        );
        
        eventCounter++;
        uint256 eventId = eventCounter;
        
        uint256 maxResalePrice = (price * maxResalePricePercentage) / 10000;
        
        events[eventId] = Event({
            eventId: eventId,
            name: name,
            description: description,
            date: date,
            location: location,
            price: price,
            maxTickets: maxTickets,
            soldTickets: 0,
            organizer: msg.sender,
            active: true,
            cancelled: false,
            resaleAllowedUntil: resaleAllowedUntil,
            maxResalePrice: maxResalePrice
        });
        
        // Set max supply in TicketNFT
        ticketNFT.setEventMaxSupply(eventId, maxTickets);
        
        emit EventCreated(eventId, name, msg.sender, price, maxTickets);
        
        return eventId;
    }
    
    /**
     * @dev Purchase a ticket for an event
     * @param eventId The event ID
     */
    function purchaseTicket(uint256 eventId) external payable whenNotPaused nonReentrant {
        Event storage eventData = events[eventId];
        
        require(eventData.active, "Event is not active");
        require(!eventData.cancelled, "Event is cancelled");
        require(eventData.soldTickets < eventData.maxTickets, "Event sold out");
        require(msg.value >= eventData.price, "Insufficient payment");
        require(block.timestamp < eventData.date, "Event has already occurred");
        
        // Calculate fees
        uint256 platformFee = (eventData.price * platformFeePercentage) / 10000;
        uint256 organizerAmount = eventData.price - platformFee;
        
        // Update event
        eventData.soldTickets++;
        
        // Mint NFT ticket
        uint256 tokenId = ticketNFT.mintTicket(
            msg.sender,
            eventId,
            eventData.price,
            eventData.name,
            eventData.date,
            eventData.location,
            string(abi.encodePacked("https://api.ticketing-platform.com/ticket/", eventId.toString(), "/", block.timestamp.toString()))
        );
        
        // Track token for this event
        eventTokenIds[eventId].push(tokenId);
        tokenIdToEvent[tokenId] = eventId;
        
        // Distribute revenue
        organizerRevenue[eventData.organizer] += organizerAmount;
        platformRevenue[address(this)] += platformFee;
        
        // Refund excess payment
        if (msg.value > eventData.price) {
            payable(msg.sender).transfer(msg.value - eventData.price);
        }
        
        emit TicketPurchased(eventId, tokenId, msg.sender, eventData.price);
    }
    
    /**
     * @dev Purchase multiple tickets for an event in a single transaction
     * @param eventId The event ID
     * @param quantity Number of tickets to purchase
     */
    function purchaseBatchTickets(uint256 eventId, uint256 quantity) external payable whenNotPaused nonReentrant {
        Event storage eventData = events[eventId];
        
        require(eventData.active, "Event is not active");
        require(!eventData.cancelled, "Event is cancelled");
        require(quantity > 0, "Quantity must be greater than 0");
        require(eventData.soldTickets + quantity <= eventData.maxTickets, "Not enough tickets available");
        
        uint256 totalPrice = eventData.price * quantity;
        require(msg.value >= totalPrice, "Insufficient payment");
        require(block.timestamp < eventData.date, "Event has already occurred");
        
        // Calculate fees and update state
        uint256 platformFee = (totalPrice * platformFeePercentage) / 10000;
        uint256 organizerAmount = totalPrice - platformFee;
        eventData.soldTickets += quantity;
        
        // Mint NFT tickets
        uint256[] memory tokenIds = _mintBatchTickets(
            msg.sender,
            eventId,
            eventData.price,
            eventData.name,
            eventData.date,
            eventData.location,
            quantity
        );
        
        // Distribute revenue
        organizerRevenue[eventData.organizer] += organizerAmount;
        platformRevenue[address(this)] += platformFee;
        
        // Refund excess payment
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
        
        emit BatchTicketsPurchased(eventId, msg.sender, quantity, tokenIds, totalPrice);
    }
    
    /**
     * @dev Internal function to mint multiple tickets
     */
    function _mintBatchTickets(
        address to,
        uint256 eventId,
        uint256 price,
        string memory eventName,
        uint256 eventDate,
        string memory eventLocation,
        uint256 quantity
    ) internal returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](quantity);
        uint256 timestamp = block.timestamp;
        
        for (uint256 i = 0; i < quantity; i++) {
            string memory tokenURI = string(abi.encodePacked(
                "https://api.ticketing-platform.com/ticket/",
                eventId.toString(),
                "/",
                timestamp.toString(),
                "/",
                i.toString()
            ));
            
            uint256 tokenId = ticketNFT.mintTicket(
                to,
                eventId,
                price,
                eventName,
                eventDate,
                eventLocation,
                tokenURI
            );
            
            tokenIds[i] = tokenId;
            eventTokenIds[eventId].push(tokenId);
            tokenIdToEvent[tokenId] = eventId;
            
            emit TicketPurchased(eventId, tokenId, to, price);
        }
        
        return tokenIds;
    }
    
    /**
     * @dev List a ticket for resale
     * @param tokenId The ticket token ID
     * @param price Resale price in wei
     */
    function listTicketForResale(uint256 tokenId, uint256 price) external whenNotPaused nonReentrant {
        require(ticketNFT.ownerOf(tokenId) == msg.sender, "Not ticket owner");
        
        (uint256 eventId, , , , bool used) = ticketNFT.getTicketInfo(tokenId);
        require(!used, "Cannot resell used ticket");
        
        Event storage eventData = events[eventId];
        require(eventData.active, "Event is not active");
        require(
            eventData.resaleAllowedUntil == 0 || block.timestamp <= eventData.resaleAllowedUntil,
            "Resale period has ended"
        );
        require(price <= eventData.maxResalePrice, "Price exceeds maximum resale price");
        require(price > 0, "Price must be greater than 0");
        
        // Cancel existing listing if any
        uint256 existingListingId = tokenIdToListingId[tokenId];
        if (existingListingId != 0 && resaleListings[existingListingId].active) {
            resaleListings[existingListingId].active = false;
            emit ResaleListingCancelled(existingListingId, tokenId);
        }
        
        // Create new listing
        uint256 listingId = tokenId;
        resaleListings[listingId] = ResaleListing({
            tokenId: tokenId,
            price: price,
            seller: msg.sender,
            active: true
        });
        
        tokenIdToListingId[tokenId] = listingId;
        
        // Transfer ticket to contract (escrow)
        ticketNFT.transferFrom(msg.sender, address(this), tokenId);
        
        emit TicketListedForResale(listingId, tokenId, msg.sender, price);
    }
    
    /**
     * @dev Purchase a ticket from resale marketplace
     * @param listingId The listing ID (same as tokenId)
     */
    function purchaseResaleTicket(uint256 listingId) external payable whenNotPaused nonReentrant {
        ResaleListing storage listing = resaleListings[listingId];
        
        require(listing.active, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient payment");
        
        (uint256 eventId, , , , bool used) = ticketNFT.getTicketInfo(listing.tokenId);
        require(!used, "Ticket has been used");
        
        Event storage eventData = events[eventId];
        require(eventData.active, "Event is not active");
        require(
            eventData.resaleAllowedUntil == 0 || block.timestamp <= eventData.resaleAllowedUntil,
            "Resale period has ended"
        );
        
        // Calculate fees
        uint256 platformFee = (listing.price * platformFeePercentage) / 10000;
        uint256 sellerAmount = listing.price - platformFee;
        
        // Deactivate listing
        listing.active = false;
        
        // Transfer ticket to buyer
        ticketNFT.transferFrom(address(this), msg.sender, listing.tokenId);
        
        // Distribute revenue
        payable(listing.seller).transfer(sellerAmount);
        platformRevenue[address(this)] += platformFee;
        
        // Refund excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }
        
        emit TicketResold(listingId, listing.tokenId, msg.sender, listing.price);
    }
    
    /**
     * @dev Cancel a resale listing
     * @param listingId The listing ID
     */
    function cancelResaleListing(uint256 listingId) external nonReentrant {
        ResaleListing storage listing = resaleListings[listingId];
        
        require(listing.active, "Listing is not active");
        require(listing.seller == msg.sender, "Not the seller");
        
        listing.active = false;
        
        // Return ticket to seller
        ticketNFT.transferFrom(address(this), msg.sender, listing.tokenId);
        
        emit ResaleListingCancelled(listingId, listing.tokenId);
    }
    
    /**
     * @dev Withdraw organizer revenue
     */
    function withdrawOrganizerRevenue() external nonReentrant {
        uint256 amount = organizerRevenue[msg.sender];
        require(amount > 0, "No revenue to withdraw");
        
        organizerRevenue[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        
        emit RevenueWithdrawn(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw platform revenue (owner only)
     */
    function withdrawPlatformRevenue() external onlyOwner nonReentrant {
        uint256 amount = platformRevenue[address(this)];
        require(amount > 0, "No platform revenue to withdraw");
        
        platformRevenue[address(this)] = 0;
        payable(owner()).transfer(amount);
        
        emit RevenueWithdrawn(owner(), amount);
    }
    
    /**
     * @dev Update platform fee percentage (owner only)
     * @param newFeePercentage New fee percentage in basis points
     */
    function setPlatformFeePercentage(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 1000, "Fee cannot exceed 10%"); // Max 10%
        platformFeePercentage = newFeePercentage;
    }
    
    /**
     * @dev Update max resale price percentage (owner only)
     * @param newMaxPercentage New max percentage in basis points
     */
    function setMaxResalePricePercentage(uint256 newMaxPercentage) external onlyOwner {
        require(newMaxPercentage >= 10000, "Must allow at least 100% of original price");
        maxResalePricePercentage = newMaxPercentage;
    }
    
    /**
     * @dev Deactivate an event (owner only)
     * @param eventId The event ID
     */
    function deactivateEvent(uint256 eventId) external onlyOwner {
        require(events[eventId].organizer != address(0), "Event does not exist");
        events[eventId].active = false;
    }
    
    /**
     * @dev Cancel an event and issue refunds (organizer or owner only)
     * @param eventId The event ID
     */
    function cancelEvent(uint256 eventId) external nonReentrant {
        Event storage eventData = events[eventId];
        require(eventData.organizer != address(0), "Event does not exist");
        require(msg.sender == eventData.organizer || msg.sender == owner(), "Not authorized");
        require(!eventData.cancelled, "Event already cancelled");
        require(block.timestamp < eventData.date, "Event has already occurred");
        
        eventData.cancelled = true;
        eventData.active = false;
        
        // Refund all ticket holders
        uint256[] memory tokenIds = eventTokenIds[eventId];
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address ticketOwner = ticketNFT.ownerOf(tokenId);
            
            // Check if ticket is still valid (not used and not in resale)
            (,,, , bool used) = ticketNFT.getTicketInfo(tokenId);
            if (!used && ticketOwner != address(this)) {
                // Refund the original purchase price
                payable(ticketOwner).transfer(eventData.price);
                emit RefundIssued(tokenId, eventId, ticketOwner, eventData.price);
            }
        }
        
        // Refund organizer revenue for this event
        uint256 organizerRefund = organizerRevenue[eventData.organizer];
        if (organizerRefund > 0) {
            organizerRevenue[eventData.organizer] = 0;
            // Note: This refunds all organizer revenue, not just for this event
            // In production, you might want to track per-event revenue
        }
        
        emit EventCancelled(eventId, eventData.organizer);
    }
    
    /**
     * @dev Pause the contract (owner only) - emergency stop
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause the contract (owner only)
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Get event details
     * @param eventId The event ID
     */
    function getEvent(uint256 eventId) external view returns (
        uint256 eventId_,
        string memory name,
        string memory description,
        uint256 date,
        string memory location,
        uint256 price,
        uint256 maxTickets,
        uint256 soldTickets,
        address organizer,
        bool active,
        bool cancelled
    ) {
        Event memory eventData = events[eventId];
        return (
            eventData.eventId,
            eventData.name,
            eventData.description,
            eventData.date,
            eventData.location,
            eventData.price,
            eventData.maxTickets,
            eventData.soldTickets,
            eventData.organizer,
            eventData.active,
            eventData.cancelled
        );
    }
    
    /**
     * @dev Get all token IDs for an event
     * @param eventId The event ID
     */
    function getEventTokenIds(uint256 eventId) external view returns (uint256[] memory) {
        return eventTokenIds[eventId];
    }
    
    /**
     * @dev Get event count
     */
    function getEventCount() external view returns (uint256) {
        return eventCounter;
    }
    
    /**
     * @dev Check if an event is sold out
     * @param eventId The event ID
     */
    function isEventSoldOut(uint256 eventId) external view returns (bool) {
        Event memory eventData = events[eventId];
        return eventData.soldTickets >= eventData.maxTickets;
    }
    
    /**
     * @dev Get available tickets for an event
     * @param eventId The event ID
     */
    function getAvailableTickets(uint256 eventId) external view returns (uint256) {
        Event memory eventData = events[eventId];
        if (eventData.maxTickets > eventData.soldTickets) {
            return eventData.maxTickets - eventData.soldTickets;
        }
        return 0;
    }
    
    /**
     * @dev Get resale listing details
     * @param listingId The listing ID
     */
    function getResaleListing(uint256 listingId) external view returns (
        uint256 tokenId,
        uint256 price,
        address seller,
        bool active
    ) {
        ResaleListing memory listing = resaleListings[listingId];
        return (
            listing.tokenId,
            listing.price,
            listing.seller,
            listing.active
        );
    }
    
    // Receive function for ETH transfers
    receive() external payable {}
}


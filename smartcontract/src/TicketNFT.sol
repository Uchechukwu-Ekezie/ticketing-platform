// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title TicketNFT
 * @dev ERC-721 contract for ticket NFTs
 * Each ticket is a unique NFT that can be transferred, sold, or used for event entry
 */
contract TicketNFT is ERC721URIStorage, Ownable, ReentrancyGuard, AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    
    uint256 private _tokenIdCounter;
    
    // Event ID => Token ID mapping
    mapping(uint256 => uint256) public eventToTokenId;
    
    // Token ID => Event ID mapping
    mapping(uint256 => uint256) public tokenIdToEvent;
    
    // Token ID => Ticket metadata
    mapping(uint256 => TicketMetadata) public ticketMetadata;
    
    // Event ID => Ticket details
    mapping(uint256 => EventTicketInfo) public eventTicketInfo;
    
    // Event ID => authorized verifiers (for event entry)
    mapping(uint256 => mapping(address => bool)) public eventVerifiers;
    
    struct TicketMetadata {
        uint256 eventId;
        uint256 purchasePrice;
        uint256 purchaseTime;
        address originalOwner;
        bool used;
    }
    
    struct EventTicketInfo {
        string eventName;
        uint256 eventDate;
        string eventLocation;
        uint256 maxSupply;
        uint256 currentSupply;
    }
    
    event TicketMinted(
        uint256 indexed tokenId,
        uint256 indexed eventId,
        address indexed to,
        uint256 price
    );
    
    event TicketUsed(uint256 indexed tokenId, uint256 indexed eventId, address indexed verifier);
    
    event VerifierAdded(uint256 indexed eventId, address indexed verifier);
    event VerifierRemoved(uint256 indexed eventId, address indexed verifier);
    
    constructor() ERC721("TicketNFT", "TICKET") Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    /**
     * @dev Mint a new ticket NFT
     * @param to Address to mint the ticket to
     * @param eventId The event ID this ticket belongs to
     * @param price The price paid for this ticket
     * @param eventName Name of the event
     * @param eventDate Date of the event
     * @param eventLocation Location of the event
     * @param tokenURI URI for the ticket metadata
     */
    function mintTicket(
        address to,
        uint256 eventId,
        uint256 price,
        string memory eventName,
        uint256 eventDate,
        string memory eventLocation,
        string memory tokenURI
    ) external onlyOwner nonReentrant returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        
        // Initialize event info if this is the first ticket for this event
        if (eventTicketInfo[eventId].maxSupply == 0) {
            eventTicketInfo[eventId] = EventTicketInfo({
                eventName: eventName,
                eventDate: eventDate,
                eventLocation: eventLocation,
                maxSupply: type(uint256).max, // Set by platform contract
                currentSupply: 0
            });
        }
        
        require(
            eventTicketInfo[eventId].currentSupply < eventTicketInfo[eventId].maxSupply,
            "Event sold out"
        );
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        ticketMetadata[tokenId] = TicketMetadata({
            eventId: eventId,
            purchasePrice: price,
            purchaseTime: block.timestamp,
            originalOwner: to,
            used: false
        });
        
        tokenIdToEvent[tokenId] = eventId;
        
        eventTicketInfo[eventId].currentSupply++;
        
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        
        emit TicketMinted(tokenId, eventId, to, price);
        
        return tokenId;
    }
    
    /**
     * @dev Set the maximum supply for an event
     * @param eventId The event ID
     * @param maxSupply Maximum number of tickets for this event
     */
    function setEventMaxSupply(uint256 eventId, uint256 maxSupply) external onlyOwner {
        require(maxSupply >= eventTicketInfo[eventId].currentSupply, "Max supply too low");
        eventTicketInfo[eventId].maxSupply = maxSupply;
    }
    
    /**
     * @dev Mark a ticket as used (for event entry verification)
     * Can be called by owner, verifiers with VERIFIER_ROLE, or event-specific verifiers
     * @param tokenId The ticket token ID
     */
    function useTicket(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Ticket does not exist");
        require(!ticketMetadata[tokenId].used, "Ticket already used");
        
        uint256 eventId = ticketMetadata[tokenId].eventId;
        
        // Check if caller is authorized
        require(
            hasRole(VERIFIER_ROLE, msg.sender) ||
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
            eventVerifiers[eventId][msg.sender],
            "Not authorized to verify tickets"
        );
        
        ticketMetadata[tokenId].used = true;
        
        emit TicketUsed(tokenId, eventId, msg.sender);
    }
    
    /**
     * @dev Add a verifier for a specific event (owner or admin only)
     * @param eventId The event ID
     * @param verifier Address of the verifier
     */
    function addEventVerifier(uint256 eventId, address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(verifier != address(0), "Cannot add zero address");
        eventVerifiers[eventId][verifier] = true;
        emit VerifierAdded(eventId, verifier);
    }
    
    /**
     * @dev Remove a verifier for a specific event (owner or admin only)
     * @param eventId The event ID
     * @param verifier Address of the verifier
     */
    function removeEventVerifier(uint256 eventId, address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        eventVerifiers[eventId][verifier] = false;
        emit VerifierRemoved(eventId, verifier);
    }
    
    /**
     * @dev Grant VERIFIER_ROLE to an address (owner or admin only)
     * This allows verification of tickets for any event
     * @param verifier Address of the verifier
     */
    function grantVerifierRole(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(VERIFIER_ROLE, verifier);
    }
    
    /**
     * @dev Revoke VERIFIER_ROLE from an address (owner or admin only)
     * @param verifier Address of the verifier
     */
    function revokeVerifierRole(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(VERIFIER_ROLE, verifier);
    }
    
    /**
     * @dev Check if an address can verify tickets for a specific event
     * @param eventId The event ID
     * @param verifier Address to check
     */
    function canVerifyTicket(uint256 eventId, address verifier) external view returns (bool) {
        return hasRole(VERIFIER_ROLE, verifier) ||
               hasRole(DEFAULT_ADMIN_ROLE, verifier) ||
               eventVerifiers[eventId][verifier];
    }
    
    /**
     * @dev Check if a ticket is valid (exists and not used)
     * @param tokenId The ticket token ID
     */
    function isValidTicket(uint256 tokenId) external view returns (bool) {
        return _ownerOf(tokenId) != address(0) && !ticketMetadata[tokenId].used;
    }
    
    /**
     * @dev Get ticket information
     * @param tokenId The ticket token ID
     */
    function getTicketInfo(uint256 tokenId) external view returns (
        uint256 eventId,
        uint256 purchasePrice,
        uint256 purchaseTime,
        address originalOwner,
        bool used
    ) {
        TicketMetadata memory metadata = ticketMetadata[tokenId];
        return (
            metadata.eventId,
            metadata.purchasePrice,
            metadata.purchaseTime,
            metadata.originalOwner,
            metadata.used
        );
    }
    
    /**
     * @dev Override transfer to prevent transfer of used tickets
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        require(!ticketMetadata[tokenId].used, "Cannot transfer used ticket");
        return super._update(to, tokenId, auth);
    }
}


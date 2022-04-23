import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/ERC721C.sol";
import "./token/Quark.sol";

contract ComposableMatchMan is ERC721C, ReentrancyGuard {

    constructor(string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 userMintCollectionSize_,
        uint8 layerCount_) ERC721C(name_,symbol_,maxBatchSize_,userMintCollectionSize_,layerCount_) {}

    function mint() public payable {
        _safeMint(msg.sender, 1);
    }

    // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setQuarkBaseURI(string memory quarkBaseURI) public {
        Quark(getQuarkAddress()).setBaseURI(quarkBaseURI);
    }

    function withdraw() external onlyOwner nonReentrant {
        _withdrawQuarkToC();
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function _withdrawQuarkToC() private nonReentrant {
        Quark(getQuarkAddress()).withdraw();
    }

    function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

}
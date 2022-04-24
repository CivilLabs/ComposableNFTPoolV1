import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/Quark1155.sol";
import "./token/ERC1155C.sol";

contract ComposableMatchMan is ERC1155C, ReentrancyGuard {

    constructor(
        string memory name_,
        string memory symbol_,
        uint256[] layerConfig_,
        uint256 mintSize_,
        address composableFactoryAddress_,
        uint256 mintSequence_
    ) ERC1155C(name_,symbol_,layerConfig_,mintSize_,composableFactoryAddress_) {
        require(mintSize_ == mintSequence_.length,"Mint amount should equal to sequence length");
        mintSequence = mintSequence_;
    }

    uint256[] storage mintSequence;

    function mint() public payable {
        _mint(msg.sender, mintSequence[_currentMintIndex], 1,"");
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
        Quark1155(_getQuarkAddress()).setBaseURI(quarkBaseURI);
    }

    function withdraw() external onlyOwner nonReentrant {
        _withdrawQuarkToC();
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function _withdrawQuarkToC() private nonReentrant {
        Quark1155(_getQuarkAddress()).withdraw();
    }

}
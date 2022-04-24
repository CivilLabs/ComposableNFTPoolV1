pragma solidity ^0.8.0;
import "./ERC1155Q.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Quark1155 is ERC1155Q,Ownable,ReentrancyGuard {
    constructor(
        string memory name,
        string memory symbol,
        uint256 collectionSize
    )ERC1155Q(name, symbol, collectionSize){}

    // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
    public
    view
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
        bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}

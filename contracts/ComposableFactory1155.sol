import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./token/IERC1155C.sol";
import "./utils/IDMapping.sol";
import "hardhat/console.sol";
import "./interface/IComposableFactory1155.sol";

contract ComposableFactory1155 is IERC1155Receiver, IComposableFactory1155 {
    // Q address => C address, used to find the C address by Q address
    mapping(address => address) QToCAddressMapping;
    // C address => Q address
    mapping(address => address) CToQAddressMapping;

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4){
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
        interfaceId == type(IComposableFactory1155).interfaceId;
    }

    function addQToCAddressMapping(address quark, address erc1155c) external override returns(bool) {
        QToCAddressMapping[quark] = erc1155c;
        CToQAddressMapping[erc1155c] = quark;
        return true;
    }


    function quarksOf(address erc1155c, uint256 cId) external override view returns(uint256[] memory) {
        // where cId exist, using utils to calculate qids
        return IDMapping.CIDToQIDsMapping(cId,IERC1155C(erc1155c).getLayerConfig());
    }

    function compose(address erc1155q, uint256[] memory qIds) external override {
        address erc1155c = QToCAddressMapping[erc1155q];
        uint256 cid = IDMapping.QIDsToCIDMapping(qIds, IERC1155C(erc1155c).getLayerConfig());

        for(uint256 i = 0; i < qIds.length; i++) {
            IERC1155(erc1155q).safeTransferFrom(msg.sender, address(this), qIds[i], 1, "");
        }
        // mint the composed c to msg.sender
        IERC1155C(erc1155c).factoryMint(msg.sender, cid);
    }

    function split(address erc1155c, uint256 cId, uint256 amount) external override {
        require(IERC1155(erc1155c).balanceOf(msg.sender,cId) > 0, "you must have this ERC1155C to split");
        IERC1155C(erc1155c).burn(msg.sender, cId, amount);
        uint256[] memory qids = IDMapping.CIDToQIDsMapping(cId, IERC1155C(erc1155c).getLayerConfig());
        uint256[] memory amounts = new uint256[](qids.length);
        for(uint256 i = 0;i<qids.length;i++){
            amounts[i] = amount;
        }
        address erc1155q = CToQAddressMapping[erc1155c];
        IERC1155(erc1155q).safeBatchTransferFrom(address(this),msg.sender,qids, amounts,"");
    }
}
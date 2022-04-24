import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./token/IERC1155C.sol";
import "./IDMapping.sol";
import "hardhat/console.sol";
import "./interface/IComposableFactory1155.sol";

contract ComposableFactory is IERC1155Receiver, IComposableFactory1155 {
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
    ) external override pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function addQToCAddressMapping(address quark, address erc1155c) external returns(bool) {
        QToCAddressMapping[quark] = erc1155c;
        CToQAddressMapping[erc1155c] = quark;
        return true;
    }


    function quarksOf(address erc1155c, uint256 cId) external view returns(uint256[] memory) {
        // where cId exist, using library to calculate qids
        return IDMapping.CIDToQIDsMapping(cId,IERC1155C(erc1155c).getLayerConfig());
    }

    function compose(address erc1155q, uint256[] memory qIds) external {
        address erc1155c = QToCAddressMapping[erc1155q];
        uint256 layerCount = IERC1155C(erc1155c).getLayerCount();
        bool[30] memory appeared;

        require(qIds.length <= layerCount, "qIds length must be less than layerCount");
        require(qIds.length > 0, "qIds length must be greater than layerCount");

        for(uint256 i = 0; i < qIds.length; i++) {
            require(!appeared[qIds[i] % layerCount], "qs cannot be in one layer");
            appeared[qIds[i] % layerCount] = true;
            // promise the target quark is owned by msg.sender, and transfer
            IERC1155(erc1155q).safeTransferFrom(msg.sender, address(this), qIds[i]);
        }
        // mint the composed c to msg.sender
        uint256 newCId = IERC1155C(erc1155c).poolMint(msg.sender);
        uint256[30] memory tmpQIds;
        for(uint256 i = 0; i < qIds.length; i++) {
            tmpQIds[i] = qIds[i];
        }
        CToQMapping[erc1155c][newCId] = tmpQIds;
    }

    function split(address erc1155c, uint256 cId) external {
        require(IERC1155(erc1155c).ownerOf(cId) == msg.sender, "you must have this ERC1155C to split");
        require(CToQMapping[erc1155c][cId].length > 0, "can't split a composed ERC1155C");
        IERC1155C(erc1155c).burn(msg.sender, cId);
        uint256[30] memory qIds = CToQMapping[erc1155c][cId];
        address erc1155q = CToQAddressMapping[erc1155c];
        for(uint256 i = 0; i < IERC1155C(erc1155c).getLayerCount(); i++) {
            // if qIds[i] is 0, means related C is composed with less than layerCount quarks
            if(qIds[i] == 0) {
                break;
            }
            require(IERC1155(erc1155q).ownerOf(qIds[i]) == address(this), "no related quark");
            IERC1155(erc1155q).safeTransferFrom(address(this), msg.sender, qIds[i]);
        }
        delete CToQMapping[erc1155c][cId];
    }
}
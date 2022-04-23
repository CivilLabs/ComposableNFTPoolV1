
interface IComposableFactory {
    function addQToCAddressMapping(address quark, address erc721c) external  returns(bool);
    function quarksOf(address erc721c, uint256 cId) external view returns(uint256[30] memory);
    function addCIdToQuarksMapping(address erc721q, uint256 cId, uint256[30] memory qIds) external;
    function compose(address erc721q, uint256[] memory qIds) external;
    function split(address erc721c, uint256 cId) external ;
}
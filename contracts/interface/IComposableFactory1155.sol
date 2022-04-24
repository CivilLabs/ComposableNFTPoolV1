interface IComposableFactory1155 {
    function addQToCAddressMapping(address quark, address erc1155c) external  returns(bool);
    function quarksOf(address erc1155c, uint256 cId) external view returns(uint256[] memory);
    function compose(address erc1155q, uint256[] memory qIds) external;
    function split(address erc1155c, uint256 cId, uint256 amount) external ;
}
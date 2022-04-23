interface IERC1155C {
    function getLayerConfig() external view returns(uint256[] memory);
    function factoryMint(address to) external returns();
    function burn(address tokenOwner, uint256 tokenId) external;
}

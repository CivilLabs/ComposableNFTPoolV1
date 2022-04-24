interface IERC1155C {
    function getLayerConfig() external view returns(uint256[] memory);
    function factoryMint(address to,uint256 tokenID) external;
    function burn(address tokenOwner, uint256 tokenId, uint256 amount) external;
    function burnBatch(address tokenOwner, uint256[] tokenIds, uint256[] amounts) external;
}

interface IERC721C {
    function getLayerCount() external view returns(uint8);
    function poolMint(address to) external returns(uint256);
    function burn(address tokenOwner, uint256 tokenId) external;
}
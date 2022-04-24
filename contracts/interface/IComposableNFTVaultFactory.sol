interface ICombinableNFTVaultFactory {
    // Create C
    // generate C and store CAddress
    // @param symbol
    // @param name
    // @param totolCNum
    // @param layerCount
    // @param layerLengths
    // @param isOnlyForVault
    // @return CAddress

    // Update C and Q
    // @param CAddress
    // @param CBaseUri
    // @param QBaseUri
    // @param CContractUri
    // @param QContractUri

    // Create Vault
    // generate vault related to C, init Bottle, then add vault to vaultPool
    // store mapping(CAddress => vaultId),
    // store mapping(collateralNFTAddress => vaultId), // only one vault?
    // store mapping(vaultId => CAddress, collateralNFTAddress, currentNum, layerCount, layerLengths, isOnlyForVault, is1155)
    // @param CStoreId
    // @param is1155

}
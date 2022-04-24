// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library IDMapping {
    function quickSort(uint[] memory arr, uint256 left, uint256 right) internal pure {
        uint256 i = left;
        uint256 j = right;
        if (i == j) return;
        uint256 pivot = arr[uint256(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint256(i)] > pivot) i++;
            while (pivot > arr[uint256(j)]) j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    // calculate quark ids by cid, exclude all the blank quarks
    function CIDToQIDsMapping(uint256 cid, uint256[] calldata layerConfig) public pure returns(uint256[] storage) {
        uint256[] storage qids;
        uint256 currentSum = 0;
        for(uint256 i =0;i<layerConfig.length && cid != 0;i++){
            uint256 offset = cid % layerConfig[i];
            if(offset != 0){
                qids.push(currentSum+offset);
            }
            cid /= layerConfig[i];
            currentSum+=layerConfig[i];
        }
        return qids;
    }

    function QIDsToCIDMapping(uint256[] memory qids, uint256[] calldata layerConfig) public pure returns(uint256){
        require(layerConfig.length >= qids.length,"layer config should longer than qids");
        quickSort(qids, 0, qids.length);
        uint256 cid = 0;
        uint256 endQid = 0;
        for(uint256 i = 0;i<layerConfig.length;i++){
            endQid += layerConfig[i];
        }
        uint256 qidx = 0;
        uint256 lastLayer = layerConfig.length+1;
        for(uint256 i = layerConfig.length-1;i>=0;i++){
            cid *= layerConfig[i];
            uint256 currQid = qids[qidx];
            if(currQid < endQid && currQid >= endQid-layerConfig[i]){
                require(lastLayer != i+1,"Cannot have 2 quarks in one layer.");
                lastLayer = i-1;
                cid += currQid - (endQid - layerConfig[i]);
            }
            endQid -= layerConfig[i];
        }
        return cid;
    }
}

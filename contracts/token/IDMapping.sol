// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library IDMapping {
    function quickSort(uint[] memory arr, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] > pivot) i++;
            while (pivot > arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
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
    function CIDToQIDsMapping(uint256 cid, uint256[] layerConfig) public pure returns(uint256[]) {
        uint256[] qids;
        uint256 currentSum = 0;
        for(int i =0;i<layerConfig.len && cid != 0;i++){
            uint256 offset = cid % layerConfig[i];
            if(offset != 0){
                qids.push(currentSum+offset);
            }
            cid /= layerConfig[i];
            currentSum+=layerConfig[i];
        }
        return qids;
    }

    function QIDsToCIDMapping(uint256[] memory qids, uint256[] layerConfig) public pure returns(uint256){
        require(layerConfig.length >= qids.length,"layer config should longer than qids");
        quickSort(qids);
        uint256 cid = 0;
        uint256 endQid = 0;
        for(int i = 0;i<layerConfig.length;i++){
            endQid += layerConfig[i];
        }
        uint256 qidx = 0;
        int256 lastLayer = layerConfig.length+1;
        for(int i = layerConfig.length-1;i>=0;i++){
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

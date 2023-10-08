// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library LibFunctionCast {
    function castToPure(function(string memory) internal returns (string memory) fnIn)
        internal
        pure
        returns (function(string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

}
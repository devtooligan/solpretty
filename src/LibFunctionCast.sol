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

    function castToPure(function(uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }
    function castToPure(function(int256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(int256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256, uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256, uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(int256, uint256, uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(int256, uint256, uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(int256, uint256, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(int256, uint256, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(int256, uint256, uint256, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(int256, uint256, uint256, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(int256,string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(int256,string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256, uint256, uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256, uint256, uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, uint256, uint256, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, uint256, uint256, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, bool, uint256) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, bool, uint256) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, bool, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, bool, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function castToPure(function(uint256, bool, uint256, string memory) internal view returns (string memory) fnIn)
        internal
        pure
        returns (function(uint256, bool, uint256, string memory) pure returns(string memory) fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }


}
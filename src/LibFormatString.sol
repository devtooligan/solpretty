// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";

library LibFormatString {
    using SoladyStrings for string;

    /// @dev returns the string with a space appended
    function space(string memory text) internal pure returns (string memory) {
        return text.concat(" ");
    }

    /// @dev returns a string of spaces TODO: use fill?
    function spaces(uint256 repeat) internal pure returns (string memory result) {
        if (repeat == 0) return "";
        result = new string(repeat);
        for (uint256 i = 0; i < repeat; i++) {
            result = result.concat(" ");
        }
    }

    /// @dev returns the string with spaces appended
    function spaces(string memory text, uint256 repeat) internal pure returns (string memory result) {
        if (repeat == 0) return text;

        return text.concat(spaces(repeat));
    }



}
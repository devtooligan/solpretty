// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {console, console2} from "forge-std/Test.sol";
import {LibFunctionCast} from "./LibFunctionCast.sol";

library LibLog {

    function logger(string memory value) internal pure returns (string memory) {
        return LibFunctionCast.castToPure(_logger)(value);
    }

    function _logger(string memory message ) internal returns (string memory) {
        console2.log(message);
        return message;
    }


    /// @dev returns self for composability
    function log(string memory message) internal pure returns (string memory) {
        return logger(message);
    }

    /// @dev by default adds a space between message and append
    function log(string memory message, string memory append) internal pure returns (string memory) {
        return log(message, append, true);
    }

    /// @dev optional addSpace bool for adding/ommitting space between message and append
    function log(string memory message, string memory append, bool addSpace) internal pure returns (string memory) {
        return logger(message.spaces(addSpace ? 1 : 0).concat(append));
    }

    /// @dev log an array of strings
    function log(string[] memory messages) internal pure {
        for (uint256 i = 0; i < messages.length; i++) {
            log(messages[i]);
        }
    }
}

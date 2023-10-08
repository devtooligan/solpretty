// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {LibFunctionCast} from "./LibFunctionCast.sol";
import {LibLog} from "./LibLog.sol";
import {LibFormatDec} from "./LibFormatDec.sol";
import {LibFormatString} from "./LibFormatString.sol";

/// @dev Convenience functions to be used with SolPretty
contract Convenience {
    using LibFormatDec for uint256;
    using LibFormatString for string;
    // using SoladyStrings for string;
    using LibLog for string;
    using LibFunctionCast for *;

    LibFormatDec.Config public decConfig;
    constructor() {
        decConfig = LibFormatDec.getDefaultConfig();
    }

    function setFormatDecConfig(LibFormatDec.Config memory config) public {
        decConfig = config;
    }

    // CONVENIENCE FUNCTIONS - GENERAL  **********************************************

    // so you don't have to type console.log
    function pp() pure internal returns (string memory) {
        return pp("");
    }

    function pp(string memory message) pure internal returns (string memory) {
        return message.log();
    }

    // CONVENIENCE FUNCTIONS - UINT  ************************************************

    // format and log

    function pp(uint256 value) pure internal returns (string memory) {
        return _pp0.castToPure()(value);
    }
    function _pp0(uint256 value) view internal returns (string memory) {
        return value.format(decConfig).log();
    }

    function pp(uint256 value, uint256 fixedDecimals) pure internal returns (string memory) {
        return _pp1.castToPure()(value, fixedDecimals);
    }
    function _pp1(uint256 value, uint256 fixedDecimals) pure internal returns (string memory) {
        return value.format(fixedDecimals).log();
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) pure internal returns (string memory) {
        return _pp2.castToPure()(value, fixedDecimals, displayDecimals);
    }
    function _pp2(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) pure internal returns (string memory) {
        return value.format(fixedDecimals, displayDecimals).log();
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        pure
        internal
        returns (string memory)
    {
        return _pp3.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth);
    }
    function _pp3(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        pure
        internal
        returns (string memory)
    {
        return value.format(fixedDecimals, displayDecimals, fixedWidth).log();
    }

    function pp(uint256 value, LibFormatDec.Config memory config) pure internal returns (string memory) {
        return value.format(config).log();
    }

    // format and log with message
    function pp(uint256 value, string memory message) pure internal returns (string memory) {
        return _pp4.castToPure()(value, message);
    }

    function _pp4(uint256 value, string memory message) pure internal returns (string memory) {
        return value.format().log(message);
    }

    function pp(uint256 value, uint256 fixedDecimals, string memory message) pure internal returns (string memory) {
        return _pp5.castToPure()(value, fixedDecimals, message);
    }
    function _pp5(uint256 value, uint256 fixedDecimals, string memory message) pure internal returns (string memory) {
        return value.format(fixedDecimals).log(message);
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory message)
        pure
        internal
        returns (string memory)
    {
        return _pp6.castToPure()(value, fixedDecimals, displayDecimals, message);
    }
    function _pp6(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory message)
        pure
        internal
        returns (string memory)
    {
        return value.format(fixedDecimals, displayDecimals).log(message);
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory message)
        pure
        internal
        returns (string memory)
    {
        return _pp7.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, message);
    }

    function _pp7(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory message)
        pure
        internal
        returns (string memory)
    {
        return value.format(fixedDecimals, displayDecimals, fixedWidth).log(message);
    }

    function pp(uint256 value, string memory message, LibFormatDec.Config memory config) pure internal returns (string memory) {
        return value.format(config).log(message);
    }

    // log with no formatting at all

    /// @dev pass false as second parameter to clear ALL formatting
    function pp(uint256 value, bool useFormatting) pure internal returns (string memory) {
        return pp(value, useFormatting, "");
    }

    function pp(uint256 value, bool useFormatting, uint256 fixedWidth) pure internal returns (string memory) {
        return _pp8.castToPure()(value, useFormatting, fixedWidth);
    }
    function _pp8(uint256 value, bool useFormatting, uint256 fixedWidth) view internal returns (string memory) {
        if (useFormatting) {
            LibFormatDec.Config memory config = decConfig;
            config.fixedWidth = fixedWidth;
            return value.format(config).log();
        } else {
            LibFormatDec.Config memory config = LibFormatDec.getEmptyConfig();
            config.integerDelimiter = "";
            config.integerGroupingSize = 0;
            config.fixedWidth = fixedWidth;
            return value.format(config).log();
        }
    }

    function pp(uint256 value, bool useFormatting, string memory message) pure internal returns (string memory) {
        return _pp9.castToPure()(value, useFormatting, message);
    }
    function _pp9(uint256 value, bool useFormatting, string memory message) view internal returns (string memory) {
        if (useFormatting) {
            return value.format(decConfig).log(message);
        } else {
            LibFormatDec.Config memory opts = LibFormatDec.getEmptyConfig();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            return value.format(opts).log(message);
        }
    }

    function pp(uint256 value, bool useFormatting, uint256 fixedWidth, string memory message)
        pure
        internal
        returns (string memory)
    {
        return _ppa.castToPure()(value, useFormatting, fixedWidth, message);
    }

    function _ppa(uint256 value, bool useFormatting, uint256 fixedWidth, string memory message)
        pure
        internal
        returns (string memory)
    {
        if (useFormatting) {
            return value.format(18, 2, fixedWidth).log(message);
        } else {
            LibFormatDec.Config memory opts = LibFormatDec.getDefaultConfig();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            opts.fixedWidth = fixedWidth;
            return value.format(opts).log(message);
        }
    }

}
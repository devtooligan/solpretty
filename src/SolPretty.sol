// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {LibLog} from "./LibLog.sol";
import {LibFormatDec} from "./LibFormatDec.sol";
import {LibFormatString} from "./LibFormatString.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {console, console2} from "forge-std/Test.sol";

/**
 *                         ,dPYb,                                   I8      I8
 *                         IP'`Yb                                   I8      I8
 *                         I8  8I                                8888888888888888
 *                         I8  8'                                   I8      I8
 *    ,g,       ,ggggg,    I8 dP  gg,gggg,     ,gggggg,   ,ggg,     I8      I8    gg     gg
 *   ,8'8,     dP"  "Y8ggg I8dP   I8P"  "Yb    dP""""8I  i8" "8i    I8      I8    I8     8I
 *  ,8'  Yb   i8'    ,8I   I8P    I8'    ,8i  ,8'    8I  I8, ,8I   ,I8,    ,I8,   I8,   ,8I
 * ,8'_   8) ,d8,   ,d8'  ,d8b,_ ,I8 _  ,d8' ,dP     Y8, `YbadP'  ,d88b,  ,d88b, ,d8b, ,d8I
 * P' "YY8P8PP"Y8888P"    8P'"Y88PI8 YY88888P8P      `Y8888P"Y88888P""Y8888P""Y88P""Y88P"888
 *                                I8                                                   ,d8I'
 *                                I8                                                 ,dP'8I
 *                                I8                                                ,8"  8I
 *                                I8                                                I8   8I
 *                                I8                                                `8, ,8I
 *                                I8                                                 `Y8P"
 *
 */

/// @notice A library for formatting anumeric values as strings
/// @dev NOTE: CONVENIENCE FUNCTIONS BELOW
contract SolPretty {
    using LibFormatDec for uint256;
    using LibFormatString for string;
    using SoladyStrings for string;
    using LibLog for string;

    // STORAGE  ***************************************************************

    LibFormatDec.Config public decConfig;

    // CONFIGURATION  *********************************************************

    constructor() {
        decConfig = LibFormatDec.getDefaultConfig();
    }

    function setFormatDecConfig(LibFormatDec.Config memory config) public {
        decConfig = config;
    }


    // GRAPHICS  **************************************************************


    // UTILITIES **************************************************************

    /// @dev wrapper around solady concat
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return SoladyStrings.concat(a, b);
    }

    function concat(string[] memory strings) internal pure returns (string memory result) {
        result = "";
        for (uint256 i = 0; i < strings.length; i++) {
            result = SoladyStrings.concat(result, strings[i]);
        }
    }

    function echo(string memory sol) internal pure returns (string memory result) {
        return sol;
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return SoladyStrings.eq(a, b);
    }


    // CONVENIENCE FUNCTIONS  **************************************************************

    // so you don't have to type console.log
    function pp() pure internal returns (string memory) {
        return pp("");
    }

    // so you don't have to type console.log
    function pp(string memory message) pure returns (string memory) {
        return message.log();
    }

    // VALUE only

    // pp
    function pformat(uint256 value) pure returns (string memory) {
        return value.format(18, 2, 25);
    }

    // pp and log
    function pp(uint256 value) pure returns (string memory) {
        return pformat(value).log();
    }

    // pp and log with message
    function pp(uint256 value, string memory message) pure returns (string memory) {
        return pformat(value).log(message);
    }

    // VALUE AND FIXEDDECIMALS ONLY
    function pformat(uint256 value, uint256 fixedDecimals) pure returns (string memory) {
        return value.format(fixedDecimals, fixedDecimals, 25);
    }

    function pp(uint256 value, uint256 fixedDecimals) pure returns (string memory) {
        return pformat(value, fixedDecimals).log();
    }

    function pp(uint256 value, uint256 fixedDecimals, string memory message) pure returns (string memory) {
        return pformat(value, fixedDecimals).log(message);
    }

    // VALUE, FIXED DECIMALS, DISPLAYDECIMALS

    function pformat(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) pure returns (string memory) {
        return value.format(fixedDecimals, displayDecimals, 25);
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) pure returns (string memory) {
        return pformat(value, fixedDecimals, displayDecimals).log();
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory message)
        pure
        returns (string memory)
    {
        return pformat(value, fixedDecimals, displayDecimals).log(message);
    }

    // VALUE, FIXED DECIMALS, DISPLAYDECIMALS, FIXEDWIDTH

    function pformat(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        pure
        returns (string memory)
    {
        return value.format(fixedDecimals, displayDecimals, fixedWidth);
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        pure
        returns (string memory)
    {
        return pformat(value, fixedDecimals, displayDecimals, fixedWidth).log();
    }

    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory message)
        pure
        returns (string memory)
    {
        return pformat(value, fixedDecimals, displayDecimals, fixedWidth).log(message);
    }

    // VALUE AND OPTIONS

    function pformat(uint256 value, LibFormatDec.Config memory config) pure returns (string memory) {
        return value.format(config);
    }

    function pp(uint256 value, LibFormatDec.Config memory config) pure returns (string memory) {
        return pformat(value, config).log();
    }
    function pp(uint256 value, string memory message, LibFormatDec.Config memory config) pure returns (string memory) {
        return pformat(value, config).log(message);
    }


    // VALUE AND NO FORMATTING AT ALL
    // pass false as second parameter to clear ALL formatting
    function pp(uint256 value, bool useFormatting) pure returns (string memory) {
        if (useFormatting) {
            return pformat(value).log();
        } else {
            LibFormatDec.Config memory opts = SolPretty.getDefaultOpts();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            return pformat(value, opts).log();
        }
    }

    function pp(uint256 value, bool useFormatting, string memory message) pure returns (string memory) {
        if (useFormatting) {
            return pformat(value).log(message);
        } else {
            LibFormatDec.Config memory opts = SolPretty.getDefaultOpts();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            return pformat(value, opts).log(message);
        }
    }

    function pp(uint256 value, bool useFormatting, uint256 fixedWidth) pure returns (string memory) {
        if (useFormatting) {
            return pformat(value, 18, 2, fixedWidth).log();
        } else {
            LibFormatDec.Config memory opts = SolPretty.getDefaultOpts();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            opts.fixedWidth = fixedWidth;
            return pformat(value, opts).log();
        }
    }

    function pp(uint256 value, bool useFormatting, uint256 fixedWidth, string memory message)
        pure
        returns (string memory)
    {
        if (useFormatting) {
            return pformat(value, 18, 2, fixedWidth).log(message);
        } else {
            LibFormatDec.Config memory opts = SolPretty.getDefaultOpts();
            opts.integerDelimiter = "";
            opts.integerGroupingSize = 0;
            opts.fixedWidth = fixedWidth;
            return pformat(value, opts).log(message);
        }
    }

}


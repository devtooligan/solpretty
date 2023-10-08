// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

using LibFormatDec for uint256;
using LibFormatDec for string;


import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

/// @notice A library for formatting decimal values as strings
library LibFormatDec {
    bytes16 constant SYMBOLS = "0123456789abcdef";

    struct Config {
        uint256 fixedDecimals; //          default 0
        uint256 displayDecimals; //        default type(uint256).max
        bytes1 fractionalDelimiter; //     default " "
        uint256 fractionalGroupingSize; // default 0
        bytes1 integerDelimiter; //        default ","
        uint256 integerGroupingSize; //    default 3
        uint256 fixedWidth; //             default 0 (automatic)
        bytes1 decimalDelimter; //         default "." // ex. "." in U.S. and "," in Europe
    }

    // DEFAULT Config ********************************************************
    function getDefaultConfig() internal pure returns (Config memory config) {
        config = Config({
            fixedDecimals: 0, // defaults to zero decimal places
            displayDecimals: type(uint256).max, // if this is less than fixedDecimals, value will be truncated
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0, // fractional (right side of decimal) grouping disabled by default
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 0, // automatic
            decimalDelimter: "." // "." in U.S. and "," in Europe
        });
    }

    function getEmptyConfig() internal pure returns (Config memory config) {
        config = Config({
            fixedDecimals: 0,
            displayDecimals: type(uint256).max,
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: "",
            integerGroupingSize: 0,
            fixedWidth: 0,
            decimalDelimter: ""
        });
    }

    // UTILS ******************************************************************


    // FORMAT core function variants*******************************************

    function format(uint256 value) internal pure returns (string memory) {
        return _formatDecimal(value, getDefaultConfig());
    }

    function format(uint256 value, uint256 fixedDecimals) internal pure returns (string memory) {
        Config memory opts = getDefaultConfig();
        opts.fixedDecimals = fixedDecimals;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, uint256 fixedDecimals, uint256 displayDecimals)
        internal
        pure
        returns (string memory)
    {
        Config memory opts = getDefaultConfig();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        internal
        pure
        returns (string memory)
    {
        Config memory opts = getDefaultConfig();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        opts.fixedWidth = fixedWidth;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, Config memory opts) internal pure returns (string memory) {
        return _formatDecimal(value, opts);
    }

    // FORMAT formatDecimals engine and related fns****************************

    function isEmpty(bytes1 x) internal pure returns (bool empty) {
        assembly {
            empty := iszero(x)
        }
    }

    function usingFractionalGrouping(Config memory opts) internal pure returns (bool) {
        return (
            opts.fractionalGroupingSize > 0 && !isEmpty(opts.fractionalDelimiter) && opts.displayDecimals > 0
                && opts.fixedDecimals > 0
        );
    }

    function usingIntegerGrouping(Config memory opts) internal pure returns (bool) {
        return opts.integerGroupingSize > 0 && !isEmpty(opts.integerDelimiter);
    }

    function usingDisplayDecimals(Config memory opts) internal pure returns (bool) {
        return opts.displayDecimals < opts.fixedDecimals;
    }

    // TODO: Inconsistent use of unchecked/assembly. This fn could use a refactor, although I'm not
    // totally against having one long explicit function for this type of complexity.
    function _formatDecimal(uint256 value, Config memory opts) internal pure returns (string memory) {
        unchecked {
            // determine the length of the string
            uint256 adjustedDecimals = opts.fixedDecimals;
            // adjust for display decimals -- truncates (rounds down)
            if (usingDisplayDecimals(opts)) {
                uint256 diff = opts.fixedDecimals - opts.displayDecimals;
                value /= 10 ** diff;
                adjustedDecimals = opts.displayDecimals;
            }
            uint256 totalDigits;
            {
                uint256 integerValue = value / 10 ** adjustedDecimals;
                if (Math.log10(integerValue) == 0) {
                    // for zero e.g. 000010 fp6. display2 -> 0.00
                    totalDigits = adjustedDecimals + 1;
                } else {
                    totalDigits = Math.log10(value) + 1;
                }
            }
            uint256 length = totalDigits;
            // adjust for fractional grouping delimiters
            bytes1 fractionalDelimiter;
            if (usingFractionalGrouping(opts)) {
                uint256 fractionalDigits = adjustedDecimals;
                uint256 moar = (fractionalDigits / opts.fractionalGroupingSize);
                if (fractionalDigits % opts.fractionalGroupingSize == 0) {
                    moar -= 1;
                }
                length += moar;
                fractionalDelimiter = opts.fractionalDelimiter;
            }

            // adjust for integer grouping delimiters
            bytes1 integerDelimiter;
            if (usingIntegerGrouping(opts)) {
                uint256 integerDigits = totalDigits - adjustedDecimals;
                integerDigits = integerDigits > 0 ? integerDigits : 1;
                uint256 moar = integerDigits / opts.integerGroupingSize;
                if (integerDigits % opts.integerGroupingSize == 0) {
                    moar -= 1;
                }
                length += moar;
                integerDelimiter = opts.integerDelimiter;
            }
            // add one for decimal delimiter
            bytes1 decimalDelimiter;
            if (adjustedDecimals > 0 && !isEmpty(opts.decimalDelimter)) {
                length += 1;
                decimalDelimiter = opts.decimalDelimter;
            }
            // adjust for fixed width. reverts on too short
            if (opts.fixedWidth > 0) {
                require(opts.fixedWidth >= length, "SolPretty: too short"); // twss
                length = opts.fixedWidth;
            }
            string memory buffer = new string(length);

            // ptr tracks current position in buffer starting at rightmost position -- includes delimiters
            // example: 1,234,567.123 456 789 is ptr position of +21 even though the total digits is only 16
            // the cursor in this case would be -9
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            // cursor tracks current position in value (excluding integer and fractional delimiters)
            // zero represents the decimal delimiter position
            // for example FP6 12345678 starts at cursor -6 and ends at cursor 2
            int256 cursor = adjustedDecimals > 0 ? (-1 * int256(adjustedDecimals)) : int256(1);
            uint256 counter = 0;
            while (counter < length) {
                assembly {
                    ptr := sub(ptr, 1)
                }
                if (value == 0 && cursor > 1) {
                    // writing whitespace for long fixed width
                    assembly {
                        mstore8(ptr, byte(0, " "))
                        counter := add(counter, 1)
                    }
                    continue;
                }

                if (cursor == 0) {
                    // decimal delimiter
                    if (!isEmpty(opts.decimalDelimter)) {
                        assembly {
                            mstore8(ptr, byte(0, decimalDelimiter))
                            counter := add(counter, 1)
                        }
                    }
                    assembly {
                        cursor := add(cursor, 1)
                    }
                    continue;
                }
                if (cursor < 0) {
                    // fractional (right) side of decimal
                    if (
                        usingFractionalGrouping(opts) && -cursor % int256(opts.fractionalGroupingSize) == 0
                            && cursor != -int256(adjustedDecimals) // don't add delimiter at end of fractional
                    ) {
                        // write fractional delimiter
                        assembly {
                            mstore8(ptr, byte(0, fractionalDelimiter))
                            ptr := sub(ptr, 1)
                            counter := add(counter, 1)
                        }
                    }
                }
                bool addIntegerDelimiter = usingIntegerGrouping(opts) && cursor > 0
                    && cursor % int256(opts.integerGroupingSize) == 0 && cursor != int256(totalDigits - adjustedDecimals); // don't add delimiter at end of Integer

                // write next digit
                if (value == 0) {
                    assembly {
                        mstore8(ptr, byte(0, SYMBOLS))
                    }
                } else {
                    assembly {
                        mstore8(ptr, byte(mod(value, 10), SYMBOLS))
                    }
                }
                assembly {
                    value := div(value, 10)
                    cursor := add(cursor, 1)
                    counter := add(counter, 1)
                }

                // write integer delimiter
                if (addIntegerDelimiter) {
                    assembly {
                        ptr := sub(ptr, 1)
                        mstore8(ptr, byte(0, integerDelimiter))
                        counter := add(counter, 1)
                    }
                }
            }

            return buffer;
        }
    }
}
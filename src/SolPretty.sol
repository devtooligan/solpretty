// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

/**
                                  .       .                                  oooo
                                .o8     .o8                                  `888
oo.ooooo.  oooo d8b  .ooooo.  .o888oo .o888oo oooo    ooo  .oooo.o  .ooooo.   888
 888' `88b `888""8P d88' `88b   888     888    `88.  .8'  d88(  "8 d88' `88b  888
 888   888  888     888ooo888   888     888     `88..8'   `"Y88b.  888   888  888
 888   888  888     888    .o   888 .   888 .    `888'    o.  )88b 888   888  888
 888bod8P' d888b    `Y8bod8P'   "888"   "888"     .8'     8""888P' `Y8bod8P' o888o
 888                                          .o..P'
o888o                                         `Y8P'

*/

import {console2 as console} from "forge-std/Test.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";

function pp(uint256 target) pure returns (string memory) {
    return SolPretty.format(target);
}

function pp(uint256 target, uint256 fixedDecimals) pure returns (string memory) {
    return SolPretty.format(target, fixedDecimals);
}

function pp(uint256 target, uint256 fixedDecimals, uint displayDecimals) pure returns (string memory) {
    return SolPretty.format(target, fixedDecimals,  displayDecimals);
}

function pp(uint256 target, uint256 fixedDecimals, uint displayDecimals, uint fixedWidth) pure returns (string memory) {
    return SolPretty.format(target, fixedDecimals,  displayDecimals, fixedWidth);
}

function pp(uint256 target, SolPretty.SolPrettyOptions memory opts) pure returns (string memory) {
    return SolPretty.format(target, opts);
}

library SolPretty {
    using SoladyStrings for string;

    bytes16 private constant SYMBOLS = "0123456789abcdef";
    bytes1 private constant SPACE = " ";

    struct SolPrettyOptions {
        uint256 fixedDecimals; //          default 0
        uint256 displayDecimals; //        default 0
        bytes1 decimalDelimter; //         default bytes(".")
        bytes1 fractionalDelimiter; //     default bytes(" ")
        uint256 fractionalGroupingSize; // default 0
        bytes1 integerDelimiter; //        default bytes(",")
        uint256 integerGroupingSize; //    default 3
        uint256 fixedWidth; //             default 0 (automatic)
    }

    function log10(uint256 value) internal pure returns (uint256 result) {
        assembly {
            result := 0
            if gt(value, exp(10, 64)) {
                value := div(value, exp(10, 64))
                result := add(result, 64)
            }
            if gt(value, exp(10, 32)) {
                value := div(value, exp(10, 32))
                result := add(result, 32)
            }
            if gt(value, exp(10, 16)) {
                value := div(value, exp(10, 16))
                result := add(result, 16)
            }
            if gt(value, exp(10, 8)) {
                value := div(value, exp(10, 8))
                result := add(result, 8)
            }
            if gt(value, exp(10, 4)) {
                value := div(value, exp(10, 4))
                result := add(result, 4)
            }
            if gt(value, exp(10, 2)) {
                value := div(value, exp(10, 2))
                result := add(result, 2)
            }
            if gt(value, exp(10, 1)) { result := add(result, 1) }
        }
    }

    function echo(string memory _sol) internal pure returns (string memory) {
        return _sol;
    }

    function log(string memory message) internal pure {
        console.log(message);
    }
    function log(string[] memory messages) internal pure {
        for (uint256 i = 0; i < messages.length; i++) {
            log(messages[i]);
        }
    }

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return a.concat(b);
    }
    function concat(string[] memory strings) internal pure returns (string memory result) {
        result = "";
        for (uint256 i = 0; i < strings.length; i++) {
            result = result.concat(strings[i]);
        }
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return a.eq(b);
    }

    function _getDefaultOpts() internal pure returns (SolPrettyOptions memory opts) {
        opts = SolPrettyOptions({
            fixedDecimals: 0,
            displayDecimals: type(uint256).max, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: ".",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 0
        });
    }

    function format(uint256 target) internal pure returns (string memory) {
        return _formatDecimal(target, _getDefaultOpts());
    }
    function format(uint256 target, uint fixedDecimals) internal pure returns (string memory) {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        return _formatDecimal(target, opts);
    }
    function format(uint256 target, uint fixedDecimals, uint displayDecimals) internal pure returns (string memory) {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        return _formatDecimal(target, opts);
    }
    function format(uint256 target, uint fixedDecimals, uint displayDecimals, uint fixedWidth) internal pure returns (string memory) {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        opts.fixedWidth = fixedWidth;
        return _formatDecimal(target, opts);
    }
    function format(uint256 target, SolPrettyOptions memory opts) internal pure returns (string memory) {
        return _formatDecimal(target, opts);
    }

    function isEmpty(bytes1 x) internal pure returns (bool empty) {
        assembly {
            empty := iszero(x)
        }
    }

    function usingFractionalGrouping(SolPrettyOptions memory opts) internal pure returns (bool) {
        return (
            opts.fractionalGroupingSize > 0 && !isEmpty(opts.fractionalDelimiter) && opts.displayDecimals > 0
                && opts.fixedDecimals > 0
        );
    }

    function usingIntegerGrouping(SolPrettyOptions memory opts) internal pure returns (bool) {
        return opts.integerGroupingSize > 0 && !isEmpty(opts.integerDelimiter);
    }

    function usingDisplayDecimals(SolPrettyOptions memory opts) internal pure returns (bool) {
        return opts.displayDecimals < opts.fixedDecimals;
    }

    function _formatDecimal(uint256 value, SolPrettyOptions memory opts) internal pure returns (string memory) {
        // determine the length of the string

        unchecked {
            uint256 adjustedDecimals = opts.fixedDecimals;
            // adjust for display decimals -- truncates (rounds down)
            if (usingDisplayDecimals(opts)) {
                uint256 diff = opts.fixedDecimals - opts.displayDecimals;
                value /= 10 ** diff;
                adjustedDecimals = opts.displayDecimals;
            }

            uint256 totalDigits = log10(value) + 1;
            uint256 length = totalDigits;

            // adjust for fractional grouping delimiters
            bytes1 fractionalDelimiter;
            if (usingFractionalGrouping(opts)) {
                // length currently represents the total number of digits
                // subtract the fixed precision number of digits
                // and divide by the grouping size to get the number of delimiters to account for
                uint fractionalDigits = adjustedDecimals;
                uint moar = (adjustedDecimals / opts.fractionalGroupingSize);
                if (fractionalDigits % opts.fractionalGroupingSize == 0) {
                    moar -= 1;
                }
                length += moar;
                fractionalDelimiter = opts.fractionalDelimiter;
            }

            // adjust for integer grouping delimiters
            bytes1 integerDelimiter;
            if (usingIntegerGrouping(opts)) {
                // length currently represents the total number of digits
                // subtract the fixed precision number of digits
                // and divide by the grouping size to get the number of delimiters to account for
                uint integerDigits = totalDigits - adjustedDecimals;
                uint moar = integerDigits / opts.integerGroupingSize;
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

            if (opts.fixedWidth > 0) {
                require(opts.fixedWidth >= length, "SolPretty: fixedWidth too small");
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
                if (value == 0) {
                    assembly {
                        mstore8(ptr, byte(0, SPACE))
                        counter := add(counter, 1)
                    }
                    continue;
                }

                if (cursor == 0) {
                    // decimal delimiter
                    if (!isEmpty(opts.decimalDelimter)) {
                        assembly {
                            mstore8(ptr, byte(0,decimalDelimiter))
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
                if (addIntegerDelimiter) {
                }

                // write next digit
                assembly {
                    mstore8(ptr, byte(mod(value, 10), SYMBOLS))
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

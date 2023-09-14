// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

/**
 * ,dPYb,                                   I8      I8
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
 */

import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {console2 as console} from 'forge-std/Test.sol';

function pp(uint256 value) pure returns (string memory) {
    return SolPretty.format(value);
}

function pp(uint256 value, uint256 fixedDecimals) pure returns (string memory) {
    return SolPretty.format(value, fixedDecimals);
}

function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) pure returns (string memory) {
    return SolPretty.format(value, fixedDecimals, displayDecimals);
}

function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
    pure
    returns (string memory)
{
    return SolPretty.format(value, fixedDecimals, displayDecimals, fixedWidth);
}

function pp(uint256 value, SolPretty.SolPrettyOptions memory opts) pure returns (string memory) {
    return SolPretty.format(value, opts);
}

library SolPretty {
    using SoladyStrings for string;

    bytes16 private constant SYMBOLS = "0123456789abcdef";
    bytes1 private constant SPACE = " ";

    struct SolPrettyOptions {
        uint256 fixedDecimals; //          default 0
        uint256 displayDecimals; //        default type(uint256).max
        bytes1 fractionalDelimiter; //     default " "
        bytes1 integerDelimiter; //        default ","
        uint256 fractionalGroupingSize; // default 0
        uint256 integerGroupingSize; //    default 3
        uint256 fixedWidth; //             default 0 (automatic)
        bytes1 decimalDelimter; //         default "." // "." in U.S. and "," in Europe
    }

    function echo(string memory sol) internal pure returns (string memory) {
        return sol;
    }

    /// @dev returns self for composability e.g. `pp(something).log().eq(somethingElse)`
    function log(string memory message) internal pure returns(string memory) {
        console.log(message);
        return message;
    }

    function log(string[] memory messages) internal pure {
        for (uint256 i; i < messages.length; ++i) {
            log(messages[i]);
        }
    }

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return a.concat(b);
    }

    function concat(string[] memory strings) internal pure returns (string memory result) {
        result = "";
        for (uint256 i; i < strings.length; ++i) {
            result = result.concat(strings[i]);
        }
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return a.eq(b);
    }

    function _getDefaultOpts() internal pure returns (SolPrettyOptions memory opts) {
        opts = SolPrettyOptions({
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

    function format(uint256 value) internal pure returns (string memory) {
        return _formatDecimal(value, _getDefaultOpts());
    }

    function format(uint256 value, uint256 fixedDecimals) internal pure returns (string memory) {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, uint256 fixedDecimals, uint256 displayDecimals)
        internal
        pure
        returns (string memory)
    {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        internal
        pure
        returns (string memory)
    {
        SolPrettyOptions memory opts = _getDefaultOpts();
        opts.fixedDecimals = fixedDecimals;
        opts.displayDecimals = displayDecimals;
        opts.fixedWidth = fixedWidth;
        return _formatDecimal(value, opts);
    }

    function format(uint256 value, SolPrettyOptions memory opts) internal pure returns (string memory) {
        return _formatDecimal(value, opts);
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
            uint256 totalDigits;
            if (Math.log10(value) == 0) {
                totalDigits = adjustedDecimals + 1;
                /**
                 * for zero e.g. 000010 fp6. display2 -> 0.00
                 */
            } else {
                totalDigits = Math.log10(value) + 1;
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
            uint256 counter;
            while (counter < length) {
                assembly {
                    ptr := sub(ptr, 1)
                }
                if (value == 0 && cursor > 1) {
                    // writing whitespace for long fixed width
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
                if (addIntegerDelimiter) {}

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

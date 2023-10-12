// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {console, console2} from "forge-std/Test.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";

// using LibFormatDec for uint256;
// using LibFormatDec for string;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

/**
Do hex numbers
deal with unicode - runecount?
Do addresses like short hex


need to have the following functions, everything else is built on top:

struct Border {
    string[] top;
    string[] bottom;
    string[] left;
    string[] right;
    uint256 widthInner;
    uint256 heightInner;
    string[] body;
}
- borders(BorderOpts memory opts)

all the borders are so badass, SMILE, the christmas one, tripppy ones
bear with board omg

.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:.
_."._."._."._."._."._."._."._."._."._."._."._."._."._."._."._
=^..^=   =^..^=   =^..^=    =^..^=    =^..^=    =^..^=    =^..^=
_,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,_
_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_
.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.

   \  :  /       \  :  /       \  :  /       \  :  /       \  :  /
`. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .'
_ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _
   /_   _\       /_   _\       /_   _\       /_   _\       /_   _\
 .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.
   /  |  \       /  :  \       /  :  \       /  :  \       /  |  \hjw
   ______________________________
 / \                             \.
|   |                            |.
 \_ |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |                            |.
    |   _________________________|___
    |  /                            /.
    \_/dc__________________________/.



/^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\

Art by Krogg
 .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.
=`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'=
   "      "      "      "      "      "      "      "      "
Art by Krogg
      ....           ....           ....           ....
     ||             ||             ||             ||
 /"""l|\        /"""l|\        /"""l|\        /"""l|\
/_______\      /_______\      /_______\      /_______\
|  .-.  |------|  .-.  |------|  .-.  |------|  .-.  |------
 __|L|__| .--. |__|L|__| .--. |__|L|__| .--. |__|L|__| .--.
_\  \\p__`o-o'__\  \\p__`o-o'__\  \\p__`o-o'__\  \\p__`o-o'_
------------------------------------------------------------

               _._
           __.{,_.).__
        .-"           "-.
      .'  __.........__  '.
     /.-'`___.......___`'-.\
    /_.-'` /   \ /   \ `'-._\
    |     |   '/ \'   |     |
    |      '-'     '-'      |
    ;                       ;
    _\         ___         /_
   /  '.'-.__  ___  __.-'.'  \
 _/_    `'-..._____...-'`    _\_
/   \           .           /   \
\____)         .           (____/
    \___________.___________/
      \___________________/
jgs  (_____________________)

 */

library SolPretty {
    using SoladyStrings for string;

    // ************************************************************************
    // LibFormatDec
    // ************************************************************************

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
        bool isNegative; //                default false
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
            decimalDelimter: ".", // "." in U.S. and "," in Europe
            isNegative: false
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
            decimalDelimter: "",
            isNegative: false
        });
    }

    // FORMAT core function variants*******************************************

    function format(int256 value, Config memory opts) internal pure returns (string memory) {
        uint256 uintValue;
        if (value >= 0) {
            uintValue = uint256(value);
        } else if (value == type(int256).min) {
            uintValue = 0x800000000000000000000000000000000000000000000000000000000000000;
        } else {
            uintValue = uint256(-1 * value);
        }

        if (value < 0) {
            opts.isNegative = true;
        } else {
            opts.isNegative = false;
        }

        return _formatDecimal(uintValue, opts);
    }

    function format(bool value) internal pure returns (string memory) {
        if (value) {
            return "true";
        } else {
            return "false";
        }
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

            // add one for negative sign
            if (opts.isNegative) {
                length += 1;
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
                    if (opts.isNegative) {
                        assembly {
                            mstore8(ptr, byte(0, "-"))
                            counter := add(counter, 1)
                        }
                        continue;
                    }
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

    // ************************************************************************
    // LibFormat Strings
    // ************************************************************************

    /// @dev returns the string with a space appended
    function space(string memory text) internal pure returns (string memory) {
        return text.concat(" ");
    }

    /// @dev returns a string of spaces
    function spaces(uint256 n) internal pure returns (string memory result) {
        return fill(" ", n);
    }

    /// @dev returns a given string with spaces appended
    function addSpaces(string memory text, uint256 n) internal pure returns (string memory result) {
        return fill(text, " ", n);
    }

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

    function shorten(string memory str, uint256 newLength) internal pure returns (string memory) {
        uint256 currentLength = bytes(str).length;
        require(newLength <= currentLength, "SolPretty.shorten: new length too long");
        // assembly {
        //     mstore(str, newLength) // overwrite the length, shortenining it
        // }
        // return str;
        return str.slice(0, newLength);
    }

    function fill(string memory symbol, uint256 width) internal pure returns (string memory filled) {
        return fill("", symbol, width);
    }

    /// @dev fills based on width -- so if symbol is "/\" (length of 2) and width provided is 5, it will return "/\/\/"
    /// this means that if the width is not divisible by the symbol length then the last symbol will be partial.
    //  If you want a function that just repeats a symbol n times, use repeat()
    function fill(string memory prepend, string memory symbol, uint256 width)
        internal
        pure
        returns (string memory filled)
    {
        if (width == 0) return "";
        uint256 symbolLength = SoladyStrings.runeCount(symbol);
        uint256 full = width / symbolLength;
        filled = SoladyStrings.repeat(symbol, full);
        uint256 part = width % symbolLength;
        if (part > 0) {
            filled = filled.concat(shorten(symbol, part));
        }
        return prepend.concat(filled);
    }

    // ************************************************************************
    // LibLog
    // ************************************************************************

    function logger(string memory message) internal pure returns (string memory) {
        console2.log(message);
        return message;
    }

    /// @dev returns self for composability
    function log(string memory message) internal pure returns (string memory) {
        return logger(message);
    }

    /// @dev by default adds a space between message and append
    function log(string memory message, string memory append) internal pure returns (string memory) {
        log(message, append, true);
        return message;
    }

    /// @dev optional addSpace bool for adding/ommitting space between message and append
    function log(string memory message, string memory append, bool addSpace) internal pure returns (string memory) {
        return logger(addSpaces(message, addSpace ? 1 : 0).concat(append));
    }

    /// @dev log an array of strings
    function log(string[] memory messages) internal pure returns (string[] memory) {
        for (uint256 i = 0; i < messages.length; i++) {
            log(messages[i]);
        }
        return messages;
    }
}

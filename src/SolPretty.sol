// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {Unicode} from "./LibUnicode.sol";

/**
 * Do hex numbers
 * deal with unicode - runecount?
 * Do addresses like short hex
 *
 *
 * need to have the following functions, everything else is built on top:
 *
 * struct Border {
 *     string[] top;
 *     string[] bottom;
 *     string[] left;
 *     string[] right;
 *     uint256 widthInner;
 *     uint256 heightInner;
 *     string[] body;
 * }
 * - borders(BorderOpts memory opts)
 *
 * all the borders are so badass, SMILE, the christmas one, tripppy ones
 * bear with board omg
 *
 * .:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:.
 * _."._."._."._."._."._."._."._."._."._."._."._."._."._."._."._
 * =^..^=   =^..^=   =^..^=    =^..^=    =^..^=    =^..^=    =^..^=
 * _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,_
 * _/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_
 * .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.
 *
 *    \  :  /       \  :  /       \  :  /       \  :  /       \  :  /
 * `. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .'
 * _ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _
 *    /_   _\       /_   _\       /_   _\       /_   _\       /_   _\
 *  .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.
 *    /  |  \       /  :  \       /  :  \       /  :  \       /  |  \hjw
 *    ______________________________
 *  / \                             \.
 * |   |                            |.
 *  \_ |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |                            |.
 *     |   _________________________|___
 *     |  /                            /.
 *     \_/dc__________________________/.
 *
 *
 *
 * /^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\ /^(o.o)^\
 *
 * Art by Krogg
 *  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.  .-.-.
 * =`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'==`. .'=
 *    "      "      "      "      "      "      "      "      "
 * Art by Krogg
 *       ....           ....           ....           ....
 *      ||             ||             ||             ||
 *  /"""l|\        /"""l|\        /"""l|\        /"""l|\
 * /_______\      /_______\      /_______\      /_______\
 * |  .-.  |------|  .-.  |------|  .-.  |------|  .-.  |------
 *  __|L|__| .--. |__|L|__| .--. |__|L|__| .--. |__|L|__| .--.
 * _\  \\p__`o-o'__\  \\p__`o-o'__\  \\p__`o-o'__\  \\p__`o-o'_
 * ------------------------------------------------------------
 *
 *                _._
 *            __.{,_.).__
 *         .-"           "-.
 *       .'  __.........__  '.
 *      /.-'`___.......___`'-.\
 *     /_.-'` /   \ /   \ `'-._\
 *     |     |   '/ \'   |     |
 *     |      '-'     '-'      |
 *     ;                       ;
 *     _\         ___         /_
 *    /  '.'-.__  ___  __.-'.'  \
 *  _/_    `'-..._____...-'`    _\_
 * /   \           .           /   \
 * \____)         .           (____/
 *     \___________.___________/
 *       \___________________/
 * jgs  (_____________________)
 */
library SolPretty {
    using SoladyStrings for string;
    using Unicode for string;

    // ************************************************************************
    // LibFormatDec
    // ************************************************************************

    bytes16 constant SYMBOLS = "0123456789abcdef";

    enum VerticalAlignment {
        Bottom,
        Center,
        Top
    }

    struct Config {
        uint256 labelWidth; //             default 0 (automatic)
        uint256 fixedDecimals; //          default 0
        uint256 displayDecimals; //        default type(uint256).max
        bytes1 fractionalDelimiter; //     default " "
        uint256 fractionalGroupingSize; // default 0
        bytes1 integerDelimiter; //        default ","
        uint256 integerGroupingSize; //    default 3
        uint256 fixedWidth; //             default 0 (automatic)
        bytes1 decimalDelimiter; //         default "." // ex. "." in U.S. and "," in Europe
        bool isNegative; //                default false
    }

    function toMemory(Config storage config) internal view returns (Config memory) {
        return Config({
                labelWidth: config.labelWidth,
                fixedDecimals: config.fixedDecimals,
                displayDecimals: config.displayDecimals,
                fractionalDelimiter: config.fractionalDelimiter,
                fractionalGroupingSize: config.fractionalGroupingSize,
                integerDelimiter: config.integerDelimiter,
                integerGroupingSize: config.integerGroupingSize,
                fixedWidth: config.fixedWidth,
                decimalDelimiter: config.decimalDelimiter,
                isNegative: config.isNegative
            });
    }

    struct Box {
        uint256 width;
        uint256 height;
        string[] rows;
    }

    function createBox(string[] memory rows) internal pure returns (Box memory result) {
        uint256 width = 0;
        for (uint256 i = 0; i < rows.length; i++) {
            if (bytes(rows[i]).length > width) {
                width = bytes(rows[i]).length;
            }
        }
        result = Box({width: width, height: rows.length, rows: rows});
    }

    // pads all rows with spaces on both sides
    function hpadRows(string[] memory rows, uint256 padding) internal pure returns (string[] memory newRows) {
        newRows = new string[](rows.length);
        for (uint256 i = 0; i < rows.length; i++) {
            newRows[i] = spaces(padding).concat(rows[i]).concat(spaces(padding));
        }
    }

    struct BorderBox {
        BorderTiles tile;
        uint256 topHeight;
        uint256 bottomHeight;
        uint256 leftWidth;
        uint256 rightWidth;
        Box data;
    }

    struct BorderTiles {
        Box topLeft;
        Box topCenter;
        Box topRight;
        Box middleLeft;
        Box bottomLeft;
        Box bottomCenter;
        Box bottomRight;
        Box middleRight;
    }


    // TODO: Seems like these convenience variants should go in Tools, maybe?
    function createBorderBox(Box memory data, string memory symbol) internal pure returns (BorderBox memory result) {
        return createBorderBox(data, symbol, 1, 1, 1, 1);
    }

    function createBorderBox(Box memory data, Box memory tile ) internal pure returns (BorderBox memory ) {
        string[] memory renderedRows = rendered(tile);
        uint height = renderedRows.length;
        uint width = bytes(renderedRows[0]).length;
        BorderTiles memory tiles = BorderTiles({
            topLeft: tile,
            topCenter: tile,
            topRight: tile,
            middleLeft: tile,
            bottomLeft: tile,
            bottomCenter: tile,
            bottomRight: tile,
            middleRight: tile
        });
        return createBorderBox(data, tiles, height, height, width, width);
    }

    function createBorderBox(
        Box memory data,
        Box memory tile,
        uint256 topHeight,
        uint256 bottomHeight,
        uint256 leftWidth,
        uint256 rightWidth
    ) internal pure returns (BorderBox memory result) {
        BorderTiles memory tiles = createBorderTiles(tile);

        return createBorderBox(data, tiles, topHeight, bottomHeight, leftWidth, rightWidth);
    }

    function createBorderBox(
        Box memory data,
        Box memory tile,
        uint256 horizontalBorderHeight, // top and bottom
        uint256 verticalBorderWidth //     left and right
    ) internal pure returns (BorderBox memory result) {
        BorderTiles memory tiles = createBorderTiles(tile);

        return createBorderBox(data, tiles, horizontalBorderHeight, horizontalBorderHeight, verticalBorderWidth, verticalBorderWidth);
    }

    function createBorderBox(
        Box memory data,
        string memory symbol,
        uint256 topHeight,
        uint256 bottomHeight,
        uint256 leftWidth,
        uint256 rightWidth
    ) internal pure returns (BorderBox memory result) {
        string[] memory rows = new string[](1);
        rows[0] = symbol;
        Box memory tile = Box({width: 1, height: 1, rows: rows});

        BorderTiles memory tiles = createBorderTiles(tile);

        return createBorderBox(data, tiles, topHeight, bottomHeight, leftWidth, rightWidth);
    }

    function createBorderBox(
        Box memory data,
        BorderTiles memory tiles,
        uint256 topHeight,
        uint256 bottomHeight,
        uint256 leftWidth,
        uint256 rightWidth
    ) internal pure returns (BorderBox memory result) {
        result = BorderBox({
            tile: tiles,
            topHeight: topHeight,
            bottomHeight: bottomHeight,
            leftWidth: leftWidth,
            rightWidth: rightWidth,
            data: data
        });
    }

    function createBorderTiles(Box memory tile) internal pure returns (BorderTiles memory result) {
        result = BorderTiles({
            topLeft: tile,
            topCenter: tile,
            topRight: tile,
            middleLeft: tile,
            bottomLeft: tile,
            bottomCenter: tile,
            bottomRight: tile,
            middleRight: tile
        });
    }

    function rendered(BorderBox memory borderBox) internal pure returns (string[] memory fixedRows) {
        return rendered(borderBox, VerticalAlignment.Center);
    }

    function rendered(BorderBox memory borderBox, VerticalAlignment verticalAlignment)
        internal
        pure
        returns (string[] memory fixedRows)
    {
        Box memory top = Box({
            width: borderBox.leftWidth + borderBox.data.width + borderBox.rightWidth,
            height: borderBox.topHeight,
            rows: concatBoxesToRows(
                fill(borderBox.tile.topLeft, borderBox.leftWidth, borderBox.topHeight),
                fill(borderBox.tile.topCenter, borderBox.data.width, borderBox.topHeight),
                fill(borderBox.tile.topRight, borderBox.rightWidth, borderBox.topHeight),
                borderBox.topHeight,
                verticalAlignment
                )
        });
        Box memory middle = Box({
            width: borderBox.leftWidth + borderBox.data.width + borderBox.rightWidth,
            height: borderBox.data.height,
            rows: concatBoxesToRows(
                fill(borderBox.tile.middleLeft, borderBox.leftWidth, borderBox.data.height),
                borderBox.data,
                fill(borderBox.tile.middleRight, borderBox.rightWidth, borderBox.data.height),
                borderBox.data.height,
                verticalAlignment
                )
        });
        Box memory bottom = Box({
            width: borderBox.leftWidth + borderBox.data.width + borderBox.rightWidth,
            height: borderBox.bottomHeight,
            rows: concatBoxesToRows(
                fill(borderBox.tile.bottomLeft, borderBox.leftWidth, borderBox.bottomHeight),
                fill(borderBox.tile.bottomCenter, borderBox.data.width, borderBox.bottomHeight),
                fill(borderBox.tile.bottomRight, borderBox.rightWidth, borderBox.bottomHeight),
                borderBox.bottomHeight,
                verticalAlignment
                )
        });

        fixedRows = new string[](top.height + middle.height + bottom.height);
        for (uint256 i = 0; i < top.height; i++) {
            fixedRows[i] = top.rows[i];
        }
        for (uint256 i = 0; i < middle.height; i++) {
            fixedRows[i + top.height] = middle.rows[i];
        }
        for (uint256 i = 0; i < bottom.height; i++) {
            fixedRows[i + top.height + middle.height] = bottom.rows[i];
        }
    }

    function stackBoxes(Box memory a, Box memory b) internal pure returns (Box memory result) {
        result = Box({
            width: a.width > b.width ? a.width : b.width,
            height: a.height + b.height,
            rows: concatBoxesToRows(a, b, a.height + b.height, VerticalAlignment.Center)
        });
    }

    // @param verticalAlignment 0 = bottom, 1 = center, 2 = top
    function rendered(Box memory box) internal pure returns (string[] memory fixedRows) {
        return rendered(box, VerticalAlignment.Center);
    }

    // @param verticalAlignment 0 = bottom, 1 = center, 2 = top
    function rendered(Box memory box, VerticalAlignment verticalAlignment)
        internal
        pure
        returns (string[] memory fixedRows)
    {
        // require(index <= box.height, "SolPretty.getBoxRow: index out of bounds");
        fixedRows = new string[](box.height);

        uint256 dataRowsHeight = box.height > box.rows.length ? box.rows.length : box.height;

        uint256 topPaddedRows;
        uint256 bottomPaddedRows;

        uint256 heightDelta = box.height > dataRowsHeight ? box.height - dataRowsHeight : 0;
        if (heightDelta > 0) {
            if (verticalAlignment == VerticalAlignment.Bottom) {
                topPaddedRows = heightDelta;
            } else if (verticalAlignment == VerticalAlignment.Center) {
                topPaddedRows = (box.height - dataRowsHeight) / 2;
                bottomPaddedRows = box.height - dataRowsHeight - topPaddedRows;
            } else {
                bottomPaddedRows = box.height - dataRowsHeight;
            }
        }

        if (topPaddedRows > 0) {
            for (uint256 i = 0; i < topPaddedRows; i++) {
                fixedRows[i] = spaces(box.width);
            }
        }

        for (uint256 i = topPaddedRows; i < topPaddedRows + dataRowsHeight; i++) {
            fixedRows[i] = fixLength(box.rows[i - topPaddedRows], box.width);
        }

        if (bottomPaddedRows > 0) {
            for (uint256 i = topPaddedRows + dataRowsHeight; i < box.height; i++) {
                fixedRows[i] = spaces(box.width);
            }
        }
    }

    function concat(Box memory a, Box memory b) internal pure returns (Box memory result) {
        return concat(a, b, VerticalAlignment.Center, 0);
    }

    function concatWithSpace(Box memory a, Box memory b, uint8 buffer) internal pure returns (Box memory result) {
        return concat(a, b, VerticalAlignment.Center, buffer);
    }

    function concat(Box memory a, Box memory b, VerticalAlignment verticalAlignment)
        internal
        pure
        returns (Box memory result)
    {
        return concat(a, b, verticalAlignment, 0);
    }

    function emptyBox(uint256 width, uint256 height) internal pure returns (Box memory result) {
        string[] memory emptyRows = new string[](height);
        for (uint256 i = 0; i < height; i++) {
            emptyRows[i] = spaces(width);
        }
        result = Box({width: width, height: height, rows: emptyRows});
    }

    function concat(Box memory a, Box memory b, VerticalAlignment verticalAlignment, uint256 buffer)
        internal
        pure
        returns (Box memory result)
    {
        if (buffer > 0) {
            a = concat(a, emptyBox(buffer, a.height));
        }

        uint256 height = a.height > b.height ? a.height : b.height;

        result =
            Box({width: a.width + b.width, height: height, rows: concatBoxesToRows(a, b, height, verticalAlignment)});
    }

    function concatBoxesToRows(
        Box memory a,
        Box memory b,
        Box memory c,
        uint256 height,
        VerticalAlignment verticalAlignment
    ) internal pure returns (string[] memory rows) {
        Box memory ab = concat(a, b, verticalAlignment);
        return concatBoxesToRows(ab, c, height, verticalAlignment);
    }

    function concatBoxesToRows(Box memory a, Box memory b, uint256 height, VerticalAlignment verticalAlignment)
        internal
        pure
        returns (string[] memory rows)
    {
        string[] memory renderedA = rendered(Box({width: a.width, height: height, rows: a.rows}), verticalAlignment);

        string[] memory renderedB = rendered(Box({width: b.width, height: height, rows: b.rows}), verticalAlignment);

        rows = new string[](height);

        for (uint256 i = 0; i < height; i++) {
            rows[i] = renderedA[i].concat(renderedB[i]);
        }
    }

    // DEFAULT Config ********************************************************

    function getDefaultConfig() internal pure returns (Config memory config) {
        config = Config({
            labelWidth: 25,
            fixedDecimals: 18, // defaults to zero decimal places
            displayDecimals: 2, // if this is less than fixedDecimals, value will be truncated
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0, // fractional (right side of decimal) grouping disabled by default
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 25,
            decimalDelimiter: ".", // "." in U.S. and "," in Europe
            isNegative: false
        });
    }

    function getEmptyConfig() internal pure returns (Config memory config) {
        config = Config({
            labelWidth: 0,
            fixedDecimals: 0,
            displayDecimals: type(uint256).max,
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: "",
            integerGroupingSize: 0,
            fixedWidth: 0,
            decimalDelimiter: "",
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
            if (adjustedDecimals > 0 && !isEmpty(opts.decimalDelimiter)) {
                length += 1;
                decimalDelimiter = opts.decimalDelimiter;
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
                    if (!isEmpty(opts.decimalDelimiter)) {
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

    /// @dev returns a given box with a colulmn of spaces appended
    function addSpaces(Box memory box, uint256 n) internal pure returns (Box memory) {
        string[] memory renderedOldRows = rendered(box);

        string[] memory newRows = new string[](box.height);
        for (uint256 i = 0; i < box.height; i++) {
            newRows[i] = renderedOldRows[i].concat(spaces(n));
        }
        return Box({width: box.width + n, height: box.height, rows: newRows});
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

    function unicodeSlice(string memory str, uint256 start, uint256 end) internal pure returns (string memory result) {
        uint256 charCursor = 0;
        uint256 byteCursor = 0;
        uint256 length = str.runeCount();
        require(start < length, "SolPretty.unicodeSlice: start out of bounds");
        end = end > length ? length : end;
        string memory char;
        result = "";
        while (charCursor < end) {
            (char, byteCursor) = str.decodeChar(byteCursor);
            if (charCursor >= start) {
                result = result.concat(char);
                charCursor++;
            }
        }
    }

    function fixLength(string memory str, uint256 length) internal pure returns (string memory) {
        return fixLength(str, length, 0);
    }


    // alignment 0 = left, 1 = center, 2 = right
    function fixLength(string memory str, uint256 length, uint alignment) internal pure returns (string memory) {
        uint256 currentLength = bytes(str).length;
        if (currentLength == length) {
            return str;
        }
        if (currentLength > length) {
            return shorten(str, length);
        }

        if (alignment == 0) {
            return pad(str, length);
        } else if (alignment == 1) {
            uint256 padding = (length - currentLength) / 2;
            return pad(spaces(padding).concat(str), length);
        } else if (alignment == 2) {
            uint256 padding = (length - currentLength);
            return spaces(padding).concat(str);
        } else {
            revert("SolPretty.fixLength: invalid alignment");
        }

    }

    function shorten(string memory str, uint256 newLength) internal pure returns (string memory) {
        uint256 currentLength = bytes(str).length;
        require(newLength <= currentLength, "SolPretty.shorten: new length too long");

        if (str.isASCII()) {
            return str.slice(0, newLength);
        } else {
            return unicodeSlice(str, 0, newLength);
        }
    }

    function pad(Box memory box, uint256 horizontalPadding, uint256 verticalPadding) internal pure returns (Box memory result) {
        uint unpaddedHeight = box.height;
        box = Box({
            width: box.width + 2 * horizontalPadding,
            height: box.height + 2 * verticalPadding,
            rows: rendered(box)
        });
        string[] memory newRows = new string[](box.height);
        for (uint256 i = 0; i < verticalPadding; i++) {
            newRows[i] = spaces(box.width);
        }
        for (uint256 i = verticalPadding; i < unpaddedHeight + verticalPadding; i++) {
            newRows[i] = spaces(horizontalPadding).concat(box.rows[i - verticalPadding]).concat(spaces(horizontalPadding));
        }
        for (uint256 i = unpaddedHeight + verticalPadding; i < box.height; i++) {
            newRows[i] = spaces(box.width);
        }
        result = Box({
            width: box.width,
            height: box.height,
            rows: newRows
        });
    }

    function pad(string memory str, uint256 width) internal pure returns (string memory) {
        uint256 currentLength = bytes(str).length;
        if (currentLength >= width) {
            return str;
        }
        return str.concat(spaces(width - currentLength));
    }

    function fill(Box memory box, uint256 width, uint256 height) internal pure returns (Box memory result) {
        string[] memory rows = rendered(box);

        uint256 cappedHeight = height > box.height ? box.height : height;

        string[] memory filledRows = new string[](height);
        for (uint256 i = 0; i < cappedHeight; i++) {
            filledRows[i] = fill(rows[i], width);
        }

        if (cappedHeight < height) {
            for (uint256 i = cappedHeight; i < height; i++) {
                filledRows[i] = fill(rows[i % cappedHeight], width);
            }
        }

        result = Box({width: width, height: height, rows: filledRows});
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
}

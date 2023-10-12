// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SolPretty} from "./SolPretty.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

import {console2 as console} from "forge-std/Test.sol";
/// @notice A library for graphics, borders, and other ascii art.
/// @dev The functions in this returns an array of strings called "lines",
/// where each element in the array is a line.

library SolKawai { // SOLかわいい
    using SolPretty for *;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         GRAPHICS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    /** dividers / section breaks / lines

        --------------------------------------------------------------------------------


        _,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.


        _/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\


        .:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._


        ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ

    */

    string constant singleLinePattern_00 = "_,.-'~'-.,_";
    string constant singleLinePattern_01 = "_/~\\";
    string constant singleLinePattern_02 = ".:*~*:._";

    string constant multiLinePattern_00_1of2 = "     .-.";
    string constant multiLinePattern_00_2of2 = "`._.'   ";

    string constant solady_divider = unicode"•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•";

    function singleLineDivider(string memory symbol, uint256 width) internal pure returns (string[] memory result) {
        return singleLineDivider(symbol, width, 1, 1, false);
    }

    // function singleLineDividerUnicode(string memory symbol, uint256 width)
    //     internal
    //     pure
    //     returns (string[] memory result)
    // {
    //     return singleLineDivider(symbol, width, 1, 1, true);
    // }

    function singleLineDivider(string memory symbol, uint256 width, uint256 spaceAbove, uint256 spaceBelow, bool hasUnicode)
        internal
        pure
        returns (string[] memory result)
    {
        result = new string[](spaceAbove + spaceBelow + 1);
        uint256 counter;
        uint256 index;
        for (index = 0; index < spaceAbove; index++) {
            result[index] = "";
            counter++;
        }
        result[counter] = symbol.fill(width);
        for (index = 0; index < spaceBelow; index++) {
            result[index] = "";
            counter++;
        }
    }

    function multiLineDivider(string[] memory symbols, uint256 width) internal pure returns (string[] memory result) {
        return multiLineDivider(symbols, width, 1, 1);
    }

    // function multiLineDividerUnicode(string[] memory symbols, uint256 width) internal pure returns (string[] memory result) {
    //     return multiLineDivider(symbols, width, 1, 1, true);
    // }

    /// @dev once we figure out unicode we may not need separate functions. its really about the fill. can there be one fill that handles both?
    function multiLineDivider(string[] memory symbols, uint256 width, uint256 spaceAbove, uint256 spaceBelow)
        internal
        pure
        returns (string[] memory result)
    {
        // TODO: implement unicode
        result = new string[](spaceAbove + spaceBelow + 2);
        uint256 counter;
        uint256 index;
        for (index = 0; index < spaceAbove; index++) {
            result[index] = "";
            counter++;
        }
        for (index = 0; index < symbols.length; index++) {
            result[counter] = symbols[index].fill(width);
            counter++;
        }

        for (index = 0; index < spaceBelow; index++) {
            result[counter] = "";
            counter++;
        }

    }



    // borders
    /**
        *********************************
        *                               *
        *       Alice's balances        *
        *                               *
        *            1.87 USDT          *
        *            0.08 WETH          *
        *      122,828.75 DAI           *
        *                               *
        *********************************
    */

    struct BorderParams {
        string title; // "" to ommit
        string symbol;
        uint256 totalWidth;
        uint256 borderWidth;
        uint256 borderHeight;
    }

    function centered(string memory text, uint256 width) internal pure returns (string memory result) {
        uint256 textLength = bytes(text).length;
        require(textLength <= width, "SolKawai: text is too long");
        uint256 leftPadding = Math.max(0, (width - textLength) / 2);
        uint256 rightPadding = Math.max(0, width - textLength - leftPadding);
        result = " ".fill(leftPadding).concat(text).concat(" ".fill(rightPadding));
    }

    function withBorder(string[] memory body, string memory symbol, uint256 totalWidth, string memory title)
        internal
        pure
        returns (string[] memory result)
    {
        BorderParams memory borderParams = BorderParams(title, symbol, totalWidth, 1, 1);
        return withBorder(body, borderParams);
    }


    function withBorder(string[] memory body, BorderParams memory params)
        internal
        pure
        returns (string[] memory result)
    {
        uint256 totalHeight = 2 * params.borderHeight + body.length + 2 + (bytes(params.title).length > 0 ? 2 : 0); // +2 for 1 line white space above and below;
        result = new string[](totalHeight);
        uint256 currentIndex = 0;

        // extend or shorten symbol for side border
        string memory sideBorder;
        if (params.borderWidth >= bytes(params.symbol).length) {
            sideBorder = params.symbol.fill(params.borderWidth);
        } else {
            sideBorder = SolPretty.shorten(params.symbol, params.borderWidth);
        }

        // add top border
        {
            for (uint256 i; i < params.borderHeight;) {
                result[currentIndex] = params.symbol.fill(params.totalWidth);
                currentIndex++;
                i++;
            }
        }

        // add blank line (with side borders)
        result[currentIndex] = (
            sideBorder.addSpaces(params.totalWidth - 2 * params.borderWidth)
        ).concat(sideBorder);
        currentIndex++;


        // add title
        {
            if (bytes(params.title).length > 0) {
                uint256 maxBodyWidth = params.totalWidth - (2 * params.borderWidth);
                require(bytes(params.title).length <= maxBodyWidth, "SolKawai: title is too long");
                result[currentIndex] = sideBorder.concat(centered(params.title, maxBodyWidth)).concat(sideBorder);
                currentIndex++;

                // add blank line
                result[currentIndex] = (
                    sideBorder.addSpaces(params.totalWidth - 2 * params.borderWidth)
                ).concat(sideBorder);
                currentIndex++;
            }
        }

        // add body
        {
            uint256 maxBodyWidth = params.totalWidth - (2 * params.borderWidth + 1);
            for (uint256 i; i < body.length; i++) {
                require(bytes(body[i]).length <= maxBodyWidth, "SolKawai: body line is too long");
                result[currentIndex] = sideBorder.space().concat(
                    body[i].addSpaces(maxBodyWidth - bytes(body[i]).length)
                ).concat(sideBorder);
                currentIndex++;
            }
        }

        // add blank line
        result[currentIndex] = (
            sideBorder.addSpaces(params.totalWidth - 2 * params.borderWidth)
        ).concat(sideBorder);
        currentIndex++;

        // add bottom border
        {
            for (uint256 i = 0; i < params.borderHeight; i++) {
                result[currentIndex] = params.symbol.fill(params.totalWidth);
                currentIndex++;
            }
        }
    }
}

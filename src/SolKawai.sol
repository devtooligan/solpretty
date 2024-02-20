// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SolPretty} from "./SolPretty.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

/// @notice A library for graphics, borders, and other ascii art.
/// @dev The functions in this returns an array of strings called "lines",
/// where each element in the array is a line.

library SolKawai { // SOLかわいい
    using SolPretty for *;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         GRAPHICS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


   function star() internal pure returns (SolPretty.Box memory tile) {
        string[] memory tileRows = new string[](6);
        tileRows[0] = "   \\  :  /";
        tileRows[1] = "`. __/ \\__ .'";
        tileRows[2] = "_ _\\     /_ _";
        tileRows[3] = "   /_   _\\";
        tileRows[4] = " .'  \\ /  `.";
        tileRows[5] = "   /  |  \\";
        tile = SolPretty.Box({width: 14, height: 6, rows: tileRows});
    }

    function cartman() internal pure returns (SolPretty.Box memory tile) {
        string[] memory tileRows = new string[](17);
        tileRows[0] = "                _._";
        tileRows[1] = "            __.{,_.).__";
        tileRows[2] = '         .-"           "-.';
        tileRows[3] = "       .'  __.........__  '.";
        tileRows[4] = "      /.-'`___.......___`'-.\\";
        tileRows[5] = "     /_.-'` /   \\ /   \\ `'-._\\";
        tileRows[6] = "     |     |   '/ \\'   |     |";
        tileRows[7] = "     |      '-'     '-'      |";
        tileRows[8] = "     ;                       ;";
        tileRows[9] = "     _\\         ___         /_";
        tileRows[10] = "    /  '.'-.__  ___  __.-'.'  \\";
        tileRows[11] = "  _/_    `'-..._____...-'`    _\\_";
        tileRows[12] = " /   \\           .           /   \\";
        tileRows[13] = " \\____)         .           (____/";
        tileRows[14] = "     \\___________.___________/";
        tileRows[15] = "       \\___________________/";
        tileRows[16] = "      (_____________________)";
        tile = SolPretty.Box({width: 34, height: 17, rows: tileRows});
    }
    string constant singleLinePattern_00 = "_,.-'~'-.,_";
    string constant singleLinePattern_01 = "_/~\\";
    string constant singleLinePattern_02 = ".:*~*:._";

    string constant multiLinePattern_00_1of2 = "     .-.";
    string constant multiLinePattern_00_2of2 = "`._.'   ";

    string constant solady_divider = unicode"´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:";

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
}

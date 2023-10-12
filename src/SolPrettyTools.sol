// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SolPretty.sol";
import {SolKawai} from "./SolKawai.sol";
import {LibFunctionCast} from "./LibFunctionCast.sol";

/// @dev Convenience functions to be used with SolPretty
contract SolPrettyTools {
    using SolPretty for *;
    using SolKawai for *;
    using LibFunctionCast for *;

    struct SolPrettyToolsConfig {
        uint256 width;
        string[] singleDividerSymbols;
        string[][] multiDividerSymbols;
    }

    SolPrettyToolsConfig public toolsConfig; // configuration of this SolPrettyTools contract

    SolPretty.Config public decConfig; // default configuration to use with decimal numbers

    constructor() {
        decConfig = SolPretty.getDefaultConfig();

        string[] memory singleDividerSymbols = new string[](4);
        singleDividerSymbols[0] = "*";
        singleDividerSymbols[1] = SolKawai.singleLinePattern_00; // "_,.-'~'-.,_"
        singleDividerSymbols[2] = SolKawai.singleLinePattern_01; // "_/~\\"
        singleDividerSymbols[3] = SolKawai.singleLinePattern_02; // ".:*~*:._"

        string[][] memory multiDividerSymbols = new string[][](1);
        multiDividerSymbols[0] = new string[](2);
        multiDividerSymbols[0][0] = SolKawai.multiLinePattern_00_1of2; // "     .-."
        multiDividerSymbols[0][1] = SolKawai.multiLinePattern_00_2of2; // "`._.'   "

        toolsConfig = SolPrettyToolsConfig({
            width: 80,
            singleDividerSymbols: singleDividerSymbols,
            multiDividerSymbols: multiDividerSymbols
        });
    }

    function setWidth(uint256 width_) public {
        toolsConfig.width = width_;
    }

    function setToolsConfig(SolPrettyToolsConfig memory toolsConfig_) public {
        toolsConfig = toolsConfig_;
    }

    function setFormatDecConfig(SolPretty.Config memory decConfig_) public {
        decConfig = decConfig_;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         GRAPHICS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**            dividers / section breaks / lines */


    /// @dev logs a divider line
    function divider() internal view returns (string[] memory) {
        return divider("-");
    }

    function divider(uint256 symbolIndex) internal view returns (string[] memory) {
        return divider(toolsConfig.singleDividerSymbols[symbolIndex]);
    }

    function divider(string memory symbol) internal view returns (string[] memory) {
        return symbol.singleLineDivider(toolsConfig.width).log();
    }

    function dividerMulti() internal view returns (string[] memory) {
        string[] memory symbols = new string[](2);
        symbols[0] = toolsConfig.multiDividerSymbols[0][0];
        symbols[1] = toolsConfig.multiDividerSymbols[0][1];
        return symbols.multiLineDivider(toolsConfig.width);
    }
    function dividerMulti(string[] memory symbols) internal view returns (string[] memory) {
        return symbols.multiLineDivider(toolsConfig.width);
    }

    struct BorderParams {
        string title; // "" to ommit
        string symbol;
        uint256 totalWidth;
        uint256 borderWidth;
        uint256 borderHeight;
    }

    /**            borders / boxes */

    function addBorder(string[] memory body) internal view returns (string[] memory result) {
        return addBorder(body, "");
    }

    function addBorder(string[] memory body, string memory title) internal view returns (string[] memory result) {
        SolKawai.BorderParams memory params = SolKawai.BorderParams({
            title: title,
            symbol: toolsConfig.singleDividerSymbols[0],
            totalWidth: toolsConfig.width,
            borderWidth: 1,
            borderHeight: 1
        });
        return body.withBorder(params);
    }

    function addBorder(string[] memory body, SolKawai.BorderParams memory params)
        internal
        pure
        returns (string[] memory result)
    {
        return body.withBorder(params);
    }

    /**
     *
     *
     *                 ,ggggggggggg,   ,ggggggggggg,
     *                 dP"""88""""""Y8,dP"""88""""""Y8,
     *                 Yb,  88      `8bYb,  88      `8b
     *                 `"  88      ,8P `"  88      ,8P
     *                     88aaaad8P"      88aaaad8P"
     *                     88"""""         88"""""
     *                     88              88
     *                     88              88
     *                     88              88
     *                     88              88
     *
     * pp (short for "pretty print") is the central feature of this toolset which
     * combines formatting and logging into a single function call.
     *
     * Note: The 'pp' function is extensively overloaded to accommodate a diverse
     * range of use-cases and input types.
     *
     * Note: Functions cast from "view" to "pure" for use in pure contexts.
     *
     *
     */

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         STRING                              */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // so you don't have to type console.log
    function pp() internal pure returns (string memory) {
        return "".log();
    }

    function pp(string memory label) internal pure returns (string memory) {
        return label.log();
    }

    function pp(string memory label1, string memory label2) internal pure returns (string memory) {
        return label1.space().concat(label2).log();
    }

    function pp(string[] memory labels) internal pure returns (string[] memory) {
        return SolPretty.log(labels);
    }

    function pp(bool isTrue, string memory label) internal pure returns (string memory) {
        return isTrue.format().log(label);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         UINT                                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // value, config, label
    function pp(uint256 value, SolPretty.Config memory config, string memory label) internal pure returns (string memory) {
        return value.format(config).log(label);
    }

    // value, config
    function pp(uint256 value, SolPretty.Config memory config) internal pure returns (string memory) {
        return pp(value, config, "");
    }


    // value, label
    function pp(uint256 value, string memory label) internal pure returns (string memory) {
        return _pp0.castToPure()(value, label);
    }
    //value
    function pp(uint256 value) internal pure returns (string memory) {
        return _pp0.castToPure()(value, "");
    }
    function _pp0(uint256 value, string memory label) internal view returns (string memory) {
        return pp(value, decConfig, label);
    }


    // value, fixedDecimals, label
    function pp(uint256 value, uint256 fixedDecimals, string memory label) internal pure returns (string memory) {
        return _pp1.castToPure()(value, fixedDecimals, label);
    }
    // value, fixedDecimals
    function pp(uint256 value, uint256 fixedDecimals) internal pure returns (string memory) {
        return _pp1.castToPure()(value, fixedDecimals, "");
    }
    function _pp1(uint256 value, uint256 fixedDecimals, string memory label) internal view returns (string memory) {
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = fixedDecimals;
        return pp(value, config, label);
    }


    // value, fixedDecimals, displayDecimals, label
    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory label)
        internal
        pure
        returns (string memory)
    {
        return _pp2.castToPure()(value, fixedDecimals, displayDecimals, label);
    }
    // value, fixedDecimals, displayDecimals,
    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals) internal pure returns (string memory) {
        return _pp2.castToPure()(value, fixedDecimals, displayDecimals, "");
    }
    function _pp2(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory label)
        internal
        view
        returns (string memory)
    {
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = fixedDecimals;
        config.displayDecimals = displayDecimals;
        return pp(value, config, label);
    }


    // value, fixedDecimals, displayDecimals, fixedWidth, label
    function pp(
        uint256 value,
        uint256 fixedDecimals,
        uint256 displayDecimals,
        uint256 fixedWidth,
        string memory label
    ) internal pure returns (string memory) {
        return _pp3.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, label);
    }
    // value, fixedDecimals, displayDecimals, fixedWidth
    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        internal
        pure
        returns (string memory)
    {
        return _pp3.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, "");
    }
    function _pp3(
        uint256 value,
        uint256 fixedDecimals,
        uint256 displayDecimals,
        uint256 fixedWidth,
        string memory label
    ) internal view returns (string memory) {
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = fixedDecimals;
        config.displayDecimals = displayDecimals;
        config.fixedWidth = fixedWidth;
        return pp(value, config, label);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         INT                                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // value, config, label
    function pp(int256 value, SolPretty.Config memory config, string memory label) internal pure returns (string memory) {
        return value.format(config).log(label, false);
    }
    // value, config, label
    function pp(int256 value, SolPretty.Config memory config) internal pure returns (string memory) {
        return pp(value, config, "");
    }


    // value, label
    function pp(int256 value, string memory label) internal pure returns (string memory) {
        return _ppi0.castToPure()(value, label);
    }
    // value
    function pp(int256 value) internal pure returns (string memory) {
        return _ppi0.castToPure()(value, "");
    }
    function _ppi0(int256 value, string memory label) internal view returns (string memory) {
        SolPretty.Config memory config = decConfig;
        return pp(value, config, label);
    }


    // value, fixedDecimals, label
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory label) internal pure returns (string memory) {
        return _pp2i.castToPure()(value, fixedDecimals, displayDecimals, label);
    }
    // value, fixedDecimals
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals) internal pure returns (string memory) {
        return _pp2i.castToPure()(value, fixedDecimals, displayDecimals, "");
    }
    function _pp2i(int256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory label)
        internal
        view
        returns (string memory)
    {
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = fixedDecimals;
        config.displayDecimals = displayDecimals;
        return pp(value, config, label);
    }

    // value, fixedDecimals, displayDecimals, fixedWidth, label
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory label) internal pure returns (string memory) {
        return _pp3i.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, label);
    }
    // value, fixedDecimals, displayDecimals, fixedWidth
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth) internal pure returns (string memory) {
        return _pp3i.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, "");
    }
    function _pp3i(int256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory label)
        internal
        view
        returns (string memory)
    {
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = fixedDecimals;
        config.displayDecimals = displayDecimals;
        config.fixedWidth = fixedWidth;
        return pp(value, config, label);
    }

    // log with NO FORMATTING at all

    // value, useFormatting, label
    function pp(uint256 value, bool useFormatting, string memory label) internal pure returns (string memory) {
        return _pp4.castToPure()(value, useFormatting, label);
    }
    // value, useFormatting
    function pp(uint256 value, bool useFormatting) internal pure returns (string memory) {
        return _pp4.castToPure()(value, useFormatting, "");
    }
    function _pp4(uint256 value, bool useFormatting, string memory label) internal view returns (string memory) {
        SolPretty.Config memory config;
        if (useFormatting) {
            config = decConfig;
        } else {
            config = SolPretty.getEmptyConfig();
            config.integerDelimiter = "";
            config.integerGroupingSize = 0;
        }
        return pp(value, config, label);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         BYTES32                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function pp(bytes32 value) internal pure returns (string memory) {
        return SoladyStrings.toHexString(uint(value)).log();
    }
}

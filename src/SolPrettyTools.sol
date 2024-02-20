// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SolPretty.sol";
import {SolKawai} from "./SolKawai.sol";
import {LibFunctionCast} from "./LibFunctionCast.sol";
import {console, console2} from "forge-std/Test.sol";

/// @dev Convenience functions to be used with SolPretty
contract SolPrettyTools {
    using SolPretty for *;
    using SolKawai for *;
    using LibFunctionCast for *;

    struct SolPrettyToolsConfig {
        uint256 width;
        string[] singleDividerSymbols;
        string[][] multiDividerSymbols;
        SolPretty.VerticalAlignment boxVerticalAlignment;
    }

    bool tableLoggingEnabled = false;
    bool consoleLoggingEnabled = true;
    bool console2LoggingEnabled = false;

    SolPrettyToolsConfig public toolsConfig; // configuration of this SolPrettyTools contract

    SolPretty.Config public decimalsFormat; // default configuration to use with decimal numbers

    string public currentTable;
    mapping(string => string[]) public tables;


    constructor() {

        // load default dividers
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
            multiDividerSymbols: multiDividerSymbols,
            boxVerticalAlignment: SolPretty.VerticalAlignment.Center
        });

        decimalsFormat = SolPretty.getDefaultConfig();

        currentTable = "default";
    }

    function setBoxVerticalAlignment(uint boxVerticalAlignment) public {
        toolsConfig.boxVerticalAlignment = SolPretty.VerticalAlignment(boxVerticalAlignment);
    }

    function setWidth(uint256 width_) public {
        toolsConfig.width = width_;
    }

    function setToolsConfig(SolPrettyToolsConfig memory toolsConfig_) public {
        toolsConfig = toolsConfig_;
    }

    function setFormatdecimalsFormat(SolPretty.Config memory decimalsFormat_) public {
        decimalsFormat = decimalsFormat_;
    }

    function enableLogConsole() public {
        consoleLoggingEnabled = true;
    }
    function enableLogConsole(bool enabled) public {
        consoleLoggingEnabled = enabled;
    }

    function enableLogConsole2() public {
        console2LoggingEnabled = true;
    }
    function enableLogConsole2(bool enabled) public {
        console2LoggingEnabled = enabled;
    }

    function enableLogTable() public {
        tableLoggingEnabled = true;
    }
    function enableLogTable(bool enabled) public {
        tableLoggingEnabled = enabled;
    }
    function setTable(string memory name) public {
        currentTable = name;

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
        return loggit(symbol.singleLineDivider(toolsConfig.width));
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

    function dividerSolady() internal view returns (string[] memory) {
        string memory div =  SolKawai.solady_divider;
        return divider(div);
    }

    // deprecated
    // function addBorder(string[] memory body) internal view returns (string[] memory result) {
    //     return addBorder(body, "");
    // }

    // function addBorderSolady(string[] memory body) internal view returns (string[] memory result) {
    //     return addBorderSolady(body, "");
    // }

    // function addBorderSolady(string[] memory body, string memory title) internal view returns (string[] memory result) {
    //     SolKawai.Box memory params = SolKawai.Box({
    //         title: title,
    //         symbol: SolKawai.solady_divider,
    //         totalWidth: toolsConfig.width,
    //         borderWidth: 7,
    //         borderHeight: 3
    //     });
    //     return body.withBorder(params);
    // }

    // function addBorder(string[] memory body, string memory title) internal view returns (string[] memory result) {
    //     SolKawai.Box memory params = SolKawai.Box({
    //         title: title,
    //         symbol: toolsConfig.singleDividerSymbols[0],
    //         totalWidth: toolsConfig.width,
    //         borderWidth: 1,
    //         borderHeight: 1
    //     });
    //     return body.withBorder(params);
    // }

    // function addBorder(string[] memory body, SolKawai.Box memory params)
    //     internal
    //     pure
    //     returns (string[] memory result)
    // {
    //     return body.withBorder(params);
    // }


    // ************************************************************************
    // LibLog
    // ************************************************************************

    function logger(string memory message) internal pure returns (string memory) {
        console2.log(message);
        return message;
    }

    /// @dev returns self for composability
    function loggit(string memory message) internal pure returns (string memory) {
        return logger(message);
    }

    /// @dev by default adds a space between message and append
    function loggit(string memory message, string memory append) internal pure returns (string memory) {
        if (bytes(append).length > 0) {
            return loggit(message, append, true);
        }
        return loggit(message);

    }

    /// @dev optional addSpace bool for adding/ommitting space between message and append
    function loggit(string memory message, string memory append, bool addSpace) internal pure returns (string memory) {
        return logger(message.addSpaces(addSpace ? 1 : 0).concat(append));
    }

    /// @dev log an array of strings
    function loggit(string[] memory messages) internal pure returns (string[] memory) {
        for (uint256 i = 0; i < messages.length; i++) {
            loggit(messages[i]);
        }
        return messages;
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
        return loggit("");
    }

    function pp(string memory label) internal pure returns (string memory) {
        return loggit(label);
    }

    function pp(string memory label1, string memory label2) internal pure returns (string memory) {
        return loggit(label1.space().concat(label2));
    }

    function pp(string[] memory labels) internal pure returns (string[] memory) {
        return loggit(labels);
    }

    function pp(bool isTrue, string memory label) internal pure returns (string memory) {
        return loggit(label, isTrue.format());
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         UINT                                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // value, config, label
    function pp(uint256 value, SolPretty.Config memory config, string memory label) internal pure returns (string memory) {
        return loggit(value.format(config), label);
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
        return pp(value, decimalsFormat, label);
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
        SolPretty.Config memory config = decimalsFormat;
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
        SolPretty.Config memory config = decimalsFormat;
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
        SolPretty.Config memory config = decimalsFormat;
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
        return loggit(value.format(config), label);
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
        SolPretty.Config memory config = decimalsFormat;
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
        SolPretty.Config memory config = decimalsFormat;
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
        SolPretty.Config memory config = decimalsFormat;
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
            config = decimalsFormat;
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
        return loggit(SoladyStrings.toHexString(uint(value)));
    }


    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      SolPretty.Box                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    // use boxVerticalAlignment from toolsConfig
    function pp(SolPretty.Box memory box) internal pure returns (string[] memory) {
        return _pp5.castToPure()(box);
    }

    // manually select boxVerticalAlignment
    function pp(SolPretty.Box memory box, uint boxVerticalAlignment) internal pure returns (string[] memory) {
        return _pp6.castToPure()(box, boxVerticalAlignment);
    }

    function _pp5(SolPretty.Box memory box) internal view returns (string[] memory) {
        return loggit(box.rendered(toolsConfig.boxVerticalAlignment));
    }

    function _pp6(SolPretty.Box memory box, uint boxVerticalAlignment) internal view returns (string[] memory) {
        SolPretty.VerticalAlignment verticalAlignment = SolPretty.VerticalAlignment(boxVerticalAlignment);
        return loggit(box.rendered(verticalAlignment));
    }


}

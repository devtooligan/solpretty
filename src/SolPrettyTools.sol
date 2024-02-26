// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./SolPretty.sol";
import {SolKawai} from "./SolKawai.sol";
import {LibFunctionCast} from "./LibFunctionCast.sol";
import {console2} from "forge-std/Test.sol";
import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";

interface IERC20 {
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

library SolPrettyReporter {
    using SolPretty for *;

    struct ReportSection {
        uint256 sectionIndex;
        string title;
        string[] data;
        Checkpoint checkpoint;
    }

    struct Padding {
        uint256 top;
        uint256 right;
        uint256 bottom;
        uint256 left;
    }

    struct Checkpoint {
        uint256 sectionIndex;
        string title;
        uint256[] ethBalances; // key is user address
        uint256[] totalSupply; // same order as tokens
        uint256[][] userBalances; // outer order is user order, inner is token order
    }

    struct Tracking {
        TokenTracking[] tokens;
        UserTracking[] users;
    }

    struct TokenTracking {
        // TODO: Rename to TokenTracking
        address token;
        string name;
    }

    struct UserTracking {
        address user;
        string name;
    }

    function renderCheckpointsGrid(
        ReportSection[] storage sections,
        Tracking storage tracking,
        SolPretty.Config memory config
    ) internal view returns (string[] memory) {
        uint256 height = 3 + (tracking.users.length * (tracking.tokens.length + 1)) + tracking.tokens.length + 1
            + tracking.users.length + 1;
        // console2.log("height", height);
        // height = 30;
        uint256 currentRow = 0;
        string[] memory result = new string[](height);
        result[currentRow++] = SolPretty.spaces(config.labelWidth + 1);
        result[currentRow] = SolPretty.spaces(config.labelWidth + 1);
        {
            string memory title;
            for (uint256 sectionIndex; sectionIndex < sections.length; sectionIndex++) {
                ReportSection storage section = sections[sectionIndex];

                if (bytes(section.title).length > 0) {
                    title = " ".concat(section.title).fixLength(config.fixedWidth, 2);
                } else {
                    title = SolPretty.spaces(config.fixedWidth + 1);
                }

                result[currentRow] = result[currentRow].concat(title);
            }
            currentRow++;
            result[currentRow++] = SolPretty.spaces(config.labelWidth + 1);
        }

        UserTracking storage user;
        string memory userTokenCheckpoint;
        uint256 balance;
        for (uint256 userIndex; userIndex < tracking.users.length; userIndex++) {
            user = tracking.users[userIndex];
            for (uint256 tokenIndex; tokenIndex < tracking.tokens.length; tokenIndex++) {
                TokenTracking storage token = tracking.tokens[tokenIndex];
                result[currentRow] =
                    (token.name.concat(".balanceOf(").concat(user.name).concat(")")).fixLength(config.labelWidth);
                for (uint256 sectionIndex; sectionIndex < sections.length - 1; sectionIndex++) {
                    ReportSection storage section = sections[sectionIndex];
                    uint256[] storage balances = section.checkpoint.userBalances[tokenIndex];

                    balance = section.checkpoint.userBalances[tokenIndex][userIndex];
                    result[currentRow] = result[currentRow].concat(balance.format(config));
                }
                currentRow++;
            }
            result[currentRow++] = SolPretty.spaces(config.labelWidth + 1);
        }

        result[currentRow++] = SolPretty.spaces(config.labelWidth + 1);

        for (uint256 userIndex; userIndex < tracking.users.length; userIndex++) {
            user = tracking.users[userIndex];
            userTokenCheckpoint = ("ETH balance (").concat(user.name.concat(") ")).fixLength(config.labelWidth);
            for (uint256 sectionIndex; sectionIndex < sections.length - 1; sectionIndex++) {
                ReportSection storage section = sections[sectionIndex];
                userTokenCheckpoint =
                    userTokenCheckpoint.concat(section.checkpoint.ethBalances[userIndex].format(config));
            }
            result[currentRow++] = userTokenCheckpoint;
        }

        result[currentRow++] = SolPretty.spaces(config.labelWidth + 1);

        for (uint256 tokenIndex; tokenIndex < tracking.tokens.length; tokenIndex++) {
            TokenTracking storage token = tracking.tokens[tokenIndex];
            result[currentRow] = token.name.concat(".totalSupply()").fixLength(config.labelWidth);
            for (uint256 sectionIndex; sectionIndex < sections.length - 1; sectionIndex++) {
                ReportSection storage section = sections[sectionIndex];
                result[currentRow] =
                    result[currentRow].concat(section.checkpoint.totalSupply[tokenIndex].format(config));
            }
            currentRow++;
        }

        return result;
    }

    function emptyCheckpoint() internal pure returns (Checkpoint memory) {
        return Checkpoint({
            sectionIndex: 0,
            title: "",
            ethBalances: new uint256[](0),
            userBalances: new uint256[][](0),
            totalSupply: new uint256[](0)
        });
    }

    function newReportSection(ReportSection[] storage reportSections, string memory title) internal {
        reportSections.push(
            SolPrettyReporter.ReportSection({
                title: title,
                data: new string[](0),
                sectionIndex: reportSections.length,
                checkpoint: emptyCheckpoint()
            })
        );
    }

    function log(ReportSection[] storage reportSections, string memory message) internal {
        reportSections[reportSections.length - 1].data.push(message);
    }

    function setSectionTitle(ReportSection[] storage reportSections, string memory title) internal {
        reportSections[reportSections.length - 1].title = title;
    }

    function checkpoint(ReportSection[] storage reportSections, Tracking storage tracking) internal {
        checkpoint(reportSections[reportSections.length - 1], tracking);
    }

    function checkpoint(ReportSection storage section, Tracking storage tracking) internal {
        delete section.checkpoint;
        section.checkpoint.sectionIndex = section.sectionIndex;
        section.checkpoint.title = section.title;
        for (uint256 i = 0; i < tracking.users.length; i++) {
            section.checkpoint.ethBalances.push(tracking.users[i].user.balance);
        }
        for (uint256 i = 0; i < tracking.tokens.length; i++) {
            section.checkpoint.totalSupply.push(IERC20(tracking.tokens[i].token).totalSupply());
            uint256[] memory balances = new uint256[](tracking.users.length);
            for (uint256 j = 0; j < tracking.users.length; j++) {
                balances[j] = IERC20(tracking.tokens[i].token).balanceOf(tracking.users[j].user);
            }
            section.checkpoint.userBalances.push(balances);
        }
    }
}

contract SolPrettyTools {
    using SolPretty for *;
    using SolKawai for *;
    using LibFunctionCast for *;
    using SolPrettyReporter for *;

    struct SolPrettyToolsConfig {
        uint256 width;
        string[] singleDividerSymbols;
        string[][] multiDividerSymbols;
        SolPretty.VerticalAlignment boxVerticalAlignment;
    }

    SolPrettyToolsConfig public toolsConfig; // configuration of this SolPrettyTools contract
    SolPretty.Config public decimalsFormat; // default configuration to use with decimal numbers

    SolPrettyReporter.ReportSection[] _report;
    SolPrettyReporter.Padding _reportPadding;

    constructor() {
        // load default dividers // TODO: Move to a separate function
        // TODO: These should be tile boxes?
        string[] memory singleDividerSymbols = new string[](4);
        singleDividerSymbols[0] = "*";
        singleDividerSymbols[1] = SolKawai.singleLinePattern_00; // "_,.-'~'-.,_"
        singleDividerSymbols[2] = SolKawai.singleLinePattern_01; // "_/~\\"
        singleDividerSymbols[3] = SolKawai.singleLinePattern_02; // ".:*~*:._"

        string[][] memory multiDividerSymbols = new string[][](1);
        multiDividerSymbols[0] = new string[](2);
        multiDividerSymbols[0][0] = SolKawai.multiLinePattern_00_1of2; // "     .-."
        multiDividerSymbols[0][1] = SolKawai.multiLinePattern_00_2of2; // "`._.'   "

        // TODO: Move to a separate function
        // set configuration
        toolsConfig = SolPrettyToolsConfig({
            width: 80,
            singleDividerSymbols: singleDividerSymbols,
            multiDividerSymbols: multiDividerSymbols,
            boxVerticalAlignment: SolPretty.VerticalAlignment.Center
        });
        decimalsFormat = SolPretty.getDefaultConfig();

        _reportPadding = SolPrettyReporter.Padding({top: 2, right: 2, bottom: 2, left: 2});

        newReportSection(); // create default section (section 0)
    }

    SolPrettyReporter.Tracking tracking;

    function trackTokens(address[] memory tokens) public {
        for (uint256 i = 0; i < tokens.length; i++) {
            trackToken(tokens[i]);
        }
    }

    function trackTokens(address token0, address token1) public {
        trackToken(token0);
        trackToken(token1);
    }

    function trackTokens(address token0, address token1, address token2) public {
        trackToken(token0);
        trackToken(token1);
        trackToken(token2);
    }

    function trackTokens(SolPrettyReporter.TokenTracking[] memory tokens) public {
        for (uint256 i = 0; i < tokens.length; i++) {
            trackToken(tokens[i]);
        }
    }

    function trackToken(address token) public {
        trackToken(SolPrettyReporter.TokenTracking(token, IERC20(token).symbol()));
    }

    function trackToken(SolPrettyReporter.TokenTracking memory token) public {
        tracking.tokens.push(token);
    }

    function trackUser(SolPrettyReporter.UserTracking memory user) public {
        tracking.users.push(SolPrettyReporter.UserTracking({user: user.user, name: user.name}));
    }

    function trackUser(address user) public {
        uint256 count = tracking.users.length + 1;
        string memory name = "User".concat(SoladyStrings.toString(count));
        trackUser(SolPrettyReporter.UserTracking(user, name));
    }

    function trackUser(address user, string memory name) public {
        trackUser(SolPrettyReporter.UserTracking(user, name));
    }

    function checkpoint(string memory title) public {
        setSectionTitle(title);
        checkpoint();
    }

    // automatically advances to new section
    // uses storage as scratch space for dynamic array features
    function checkpoint() public {
        _report.checkpoint(tracking);
        newReportSection();
    }

    function setSectionTitle(string memory title) public {
        _report.setSectionTitle(title);
    }

    function newReportSection() public {
        newReportSection("");
    }

    function newReportSection(string memory title) public {
        _report.newReportSection(title);
    }

    function reporter(string memory message) internal returns (string memory) {
        _report.log(message);
        return message;
    }

    /// @dev returns self for composability
    function report(string memory message) internal returns (string memory) {
        return reporter(message);
    }

    /// @dev by default adds a space between message and append
    function report(string memory message, string memory append) internal returns (string memory) {
        if (bytes(append).length > 0) {
            return report(message, append, true);
        }
        return report(message);
    }

    /// @dev optional addSpace bool for adding/ommitting space between message and append
    function report(string memory message, string memory append, bool addSpace) internal returns (string memory) {
        return reporter(message.addSpaces(addSpace ? 1 : 0).concat(append));
    }

    /// @dev log an array of strings
    function report(string[] memory messages) internal returns (string[] memory) {
        for (uint256 i = 0; i < messages.length; i++) {
            report(messages[i]);
        }
        return messages;
    }

    function renderCheckpointsGrid() public view returns (string[] memory) {
        return _report.renderCheckpointsGrid(tracking, decimalsFormat.toMemory());
    }

    function setBoxVerticalAlignment(uint256 boxVerticalAlignment) public {
        toolsConfig.boxVerticalAlignment = SolPretty.VerticalAlignment(boxVerticalAlignment);
    }

    function setWidth(uint256 width_) public {
        toolsConfig.width = width_;
    }

    function setDecimalsFormatFixedWidth(uint256 width_) public {
        decimalsFormat.fixedWidth = width_;
    }

    // TODO: Need to incorporate this in all pp commands
    function setDecimalsFormatLabelWidth(uint256 width_) public {
        decimalsFormat.labelWidth = width_;
    }

    function setToolsConfig(SolPrettyToolsConfig memory toolsConfig_) public {
        toolsConfig = toolsConfig_;
    }

    function setDecimalsFormat(SolPretty.Config memory decimalsFormat_) public {
        decimalsFormat = decimalsFormat_;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         GRAPHICS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * dividers / section breaks / lines
     */

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
        string memory div = SolKawai.solady_divider;
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
    // Logging
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
    function pp(uint256 value, SolPretty.Config memory config, string memory label)
        internal
        pure
        returns (string memory)
    {
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
    function pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory label)
        internal
        pure
        returns (string memory)
    {
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
    function pp(int256 value, SolPretty.Config memory config, string memory label)
        internal
        pure
        returns (string memory)
    {
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
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, string memory label)
        internal
        pure
        returns (string memory)
    {
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
    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth, string memory label)
        internal
        pure
        returns (string memory)
    {
        return _pp3i.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, label);
    }
    // value, fixedDecimals, displayDecimals, fixedWidth

    function pp(int256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
        internal
        pure
        returns (string memory)
    {
        return _pp3i.castToPure()(value, fixedDecimals, displayDecimals, fixedWidth, "");
    }

    function _pp3i(
        int256 value,
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
        return loggit(SoladyStrings.toHexString(uint256(value)));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      SolPretty.Box                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // use boxVerticalAlignment from toolsConfig
    function pp(SolPretty.Box memory box) internal pure returns (string[] memory) {
        return _pp5.castToPure()(box);
    }

    // manually select boxVerticalAlignment
    function pp(SolPretty.Box memory box, uint256 boxVerticalAlignment) internal pure returns (string[] memory) {
        return _pp6.castToPure()(box, boxVerticalAlignment);
    }

    function _pp5(SolPretty.Box memory box) internal view returns (string[] memory) {
        return loggit(box.rendered(toolsConfig.boxVerticalAlignment));
    }

    function _pp6(SolPretty.Box memory box, uint256 boxVerticalAlignment) internal view returns (string[] memory) {
        SolPretty.VerticalAlignment verticalAlignment = SolPretty.VerticalAlignment(boxVerticalAlignment);
        return loggit(box.rendered(verticalAlignment));
    }
}

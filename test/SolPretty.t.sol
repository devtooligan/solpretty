// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Unicode} from "../src/LibUnicode.sol";
import "../src/SolPretty.sol";
import "../src/SolPrettyTools.sol";

contract SolPrettyTest is Test, SolPrettyTools {
    using SolPretty for *;
    using SolKawai for *;
    using Unicode for *;

    function setUp() public {}

    function test_fractional1() public {
        uint256 target = 0.95e18;
        string memory expected = "0.9500";
        assertTrue(pp(target, 18, 4).eq(expected));
    }
    function test_fractional1INT() public {
        int256 target = -0.95e18;
        string memory expected = "-0.9500";
        assertTrue(pp(target, 18, 4).eq(expected));
    }

    function test_fractional2() public {
        uint256 target = 0.0000095e18;
        string memory expected = "0.0000";
        assertTrue(pp(target, 18, 4).eq(expected));
    }

    function test_fractional3() public {
        uint256 target = 9.5e18;
        string memory expected = "9.5000";
        assertTrue(pp(target, 18, 4).eq(expected));
    }

    function test_fractional4() public {
        uint256 target = 0.0095e18;
        string memory expected = "0.009";
        assertTrue(pp(target, 18, 3).eq(expected));
    }

    function test_geeb() public {
        uint256 target = 1000.5e18;
        string memory expected = "1,000.50";
        assertTrue(pp(target, 18, 2).eq(expected));
    }

    function test_benaadams() public {
        uint256 target = 0;
        string memory expected = "0.00";
        pp(expected.concat("XXXexpected"));
        string memory result = pp(target, 18, 2);
        pp(result.concat("XXXresult"));
        require(result.eq(expected));
        divider();
        SolPretty.Config memory config = SolPretty.Config({
            fixedDecimals: 18,
            displayDecimals: 5, // if this is less than fixedDecimals, value will be truncated
            decimalDelimiter: ".",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 3,
            integerDelimiter: ",",
            integerGroupingSize: 1,
            fixedWidth: 0,
            isNegative: false
        });
        target = uint256(0.000001 ether);
        expected = "0.000 00";
        result = pp(target, config);
        require(result.eq(expected));
    }

    function test_pp_default() public {
        string memory expected = "123,456,789";
        uint256 target = 123456789;
        assertTrue(pp(target).eq(expected));
    }

    function test_pp_fp() public {
        string memory expected = "123,456,789.987654321987654321";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18).eq(expected));
    }

    function test_pp_displaydecimals() public {
        string memory expected = "123,456,789.9876";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 4).eq(expected));
    }

    function test_pp_displaydecimals2() public {
        string memory expected = "123,456,789";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 0).eq(expected));
    }

    function test_pp_fixedwidth() public {
        string memory expected = "    123,456,789.9876";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 4, 20).eq(expected));
    }

    function test_pp_config1() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1|2|3|4|5|6|7|8|9X9876 5432 19";
        SolPretty.Config memory config = SolPretty.Config({
            fixedDecimals: 18,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimiter: "X",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 4,
            integerDelimiter: "|",
            integerGroupingSize: 1,
            fixedWidth: 0,
            isNegative: false
        });
        assertTrue(pp(target, config).eq(expected));
    }

    function test_pp_config2() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1,234,567,899,876,543,219,876,543-21";
        SolPretty.Config memory config = SolPretty.Config({
            fixedDecimals: 2,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimiter: "-",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 0,
            isNegative: false
        });
        assertTrue(pp(target, config).eq(expected));
    }

    function test_pp_config3() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "123456789987654321O987X654X321";
        SolPretty.Config memory config = SolPretty.Config({
            fixedDecimals: 9,
            displayDecimals: 10,
            decimalDelimiter: "O",
            fractionalDelimiter: "X",
            fractionalGroupingSize: 3,
            integerDelimiter: "",
            integerGroupingSize: 3,
            fixedWidth: 0,
            isNegative: false
        });
        assertTrue(pp(target, config).eq(expected));
    }

    function testWithoutSolPretty() public pure {
        console2.log(uint256(12300000000000000000));
        console2.log("from pool:");
        console2.log(uint256(127000000000000000000));
        console2.log(uint256(128000000000000000000));
        console2.log(uint256(7000000000000000000));
        console2.log("here");
        console2.logBytes(abi.encode(1));
        console2.log(uint256(7332330000000000000));
        console2.log(uint256(25650003));
        console2.log(uint256(25750004));
        console2.log(uint256(25750005));
        revert("sucker");
    }

    function testFixedWidth() public {
        SolPretty.Config memory configWETH = SolPretty.Config({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimiter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20,
            isNegative: false
        });
        string memory expected = "              1.5000 result";
        string memory result = pp(uint(1500000000000000000), configWETH, "result");
        // pp(expected, "expected");
        // pp(result.eq(expected), "equal?");
        // assertTrue((result).eq(expected));
    }

    function testSolPrettytestWithoutSolPretty() public pure {
        SolPretty.Config memory configWETH = SolPretty.Config({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimiter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20,
            isNegative: false
        });

        SolPretty.Config memory configUSDC = SolPretty.Config({
            fixedDecimals: 6,
            displayDecimals: 4,
            decimalDelimiter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20,
            isNegative: false
        });

        pp(uint256(12300000000000000000).format(configWETH).concat(" Alice's WETH balance before"));
        pp(uint256(127000000000000000000).format(configWETH).concat(" Alice's WETH balance during"));
        pp(uint256(128000000000000000000).format(configWETH).concat(" Alice's WETH balance after"));
        pp(uint256(7000000000000000000).format(configWETH).concat(" Bob's WETH balance before"));
        pp(uint256(7332330000000000000).format(configWETH).concat(" Bob's WETH balance after"));
        pp(uint256(25650003).format(configUSDC).concat(" Alice USDC final balance"));
        pp(uint256(25750004).format(configUSDC).concat(" Alice USDC final balance"));
        pp(uint256(25750005).format(configUSDC).concat(" Alice USDC final balance"));
    }

    function testConcatList() public {
        string[] memory list = new string[](3);
        list[0] = "a";
        list[1] = "b";
        list[2] = "c";
        string memory expected = "abc";
        assertTrue(pp(list.concat()).eq(expected));
    }

    function testLogList() public pure {
        string[] memory list = new string[](3);
        list[0] = "a";
        list[1] = "b";
        list[2] = "c";
        list.log();
    }

    function test_echo() public {
        string memory hi = "hi";
        assertTrue(hi.echo().eq("hi"));
    }

    function testdivider() public {
        setWidth(80);
        string[] memory result = new string[](3);
        result = divider();

        string memory expected = "-".fill(80);
        require(result[1].eq(expected));

        divider(0);
        divider(1);
        divider(2);
        divider("Z");
        divider("1234567");
    }

    function testMultiDivider() public {
        string[] memory symbols = new string[](2);
        symbols[0] = SolKawai.multiLinePattern_00_1of2;
        symbols[1] = SolKawai.multiLinePattern_00_2of2;

        dividerMulti(symbols);

        string[] memory result = dividerMulti();
        string memory empty = "";
        string memory expected1 = "     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.";
        string memory expected2 = "`._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   ";
        require(result[0].eq(empty));
        require(result[1].eq(expected1));
        require(result[2].eq(expected2));
        require(result[3].eq(empty));

    }

    function testBorder() public {
        string[] memory body = new string[](3);
        SolPretty.Config memory config = decConfig;
        config.fixedDecimals = 18;
        config.displayDecimals = 2;
        config.fixedWidth = 15;
        body[0] = SolPretty.format(uint(1.875 ether), config).space().concat("USDT balance");
        body[1] = SolPretty.format(uint(0.0875 ether), config).space().concat("WETH balance");
        body[2] = SolPretty.format(uint(122828.75 ether), config).space().concat("DAI balance");
        pp(addBorder(body));

        string[] memory result = new string[](9);
        result = pp(addBorder(body, "Alice's balances"));
        require(result[0].eq("*".fill(80)));
        string memory empty = "*                                                                              *";
        require(result[1].eq(empty));
        string memory title = "*                               Alice's balances                               *";
        require(result[2].eq(title));
        require(result[3].eq(empty));
        string memory currentBody = "*            1.87 USDT balance                                                 *";
        require(result[4].eq(currentBody));
        currentBody = "*            0.08 WETH balance                                                 *";
        require(result[5].eq(currentBody));
        currentBody = "*      122,828.75 DAI balance                                                  *";
        require(result[6].eq(currentBody));
        require(result[7].eq(empty));
        require(result[8].eq("*".fill(80)));
        /**
            struct Box {
                string title; // "" to ommit
                string symbol;
                uint256 totalWidth;
                uint256 borderWidth;
                uint256 borderHeight;
            }
        */
        SolKawai.Box memory box = SolKawai.Box("Alice's balances", SolKawai.solady_divider, 80, 10, 5);
        pp(addBorder(body, box));
        box = SolKawai.Box("Alice's balances", "X", 80, 10, 5);
        pp(addBorder(body, box));

        pp();
        pp();
        pp();
        pp();
        pp();
        pp();
        pp(body);
        pp();
        console.log("dividerSolady():");
        dividerSolady();
        console.log("addBorderSolady():");
        pp();
        pp(addBorderSolady(body));

    }

    function testRuneCount() public {
        string memory text = unicode".•°:°.´+˚.";
        uint256 expected = 10;
        uint256 result = SoladyStrings.runeCount(text);
        pp(text);
        pp(result, "result1");
        text = SoladyStrings.slice(text, 0, 5);
        result = SoladyStrings.runeCount(text);
        pp(text);
        pp(result, "result2");

    }

    // function decodeChar(string calldata text, uint256 cursor) public pure returns (string memory char, uint256 nextCursor) {
    //     return Unicode.decodeChar(text, cursor);
    // }

    function testSlice() public {
        string memory text = unicode".•°:°.´+˚.";
        uint length = SoladyStrings.runeCount(text);
        pp(length, "length");
        uint cursor = 0;
        string memory char;
        (char, cursor) = Unicode.decodeChar(text, cursor);
        pp(char, "char1");
        pp(cursor, "cursor1");
        (char, cursor) = Unicode.decodeChar(text, cursor);
        pp(char, "char2");
        pp(cursor, "cursor2");

        pp(text.unicodeSlice(0, 2), "slice1");
    }


}

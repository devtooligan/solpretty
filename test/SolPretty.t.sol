// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2 as console} from "forge-std/Test.sol";
import {LibString as Solady} from "solady/src/utils/LibString.sol";
import "../src/SolPretty.sol";

using SolPretty for uint256;
using SolPretty for string;

contract SolPrettyTest is Test {
    function setUp() public {}

    function test_fractional1() public {
        uint256 target = 0.95e18;
        string memory expected = "0.9500";
        string memory result = pp(target, 18, 4);
        assertTrue(result.log().eq(expected));
    }

    function test_fractional2() public {
        uint256 target = 0.0000095e18;
        string memory expected = "0.0000";
        string memory result = pp(target, 18, 4);
        assertTrue(result.log().eq(expected));
    }

    function test_fractional3() public {
        uint256 target = 9.5e18;
        string memory expected = "9.5000";
        string memory result = pp(target, 18, 4);
        assertTrue(result.log().eq(expected));
    }

    function test_fractional4() public {
        uint256 target = 0.0095e18;
        string memory expected = "0.009";
        string memory result = pp(target, 18, 3);
        assertTrue(result.log().eq(expected));
    }

    function test_geeb() public {
        uint256 target = 1000.5e18;
        string memory expected = "1,000.50";
        string memory result = pp(target, 18, 2);
        assertTrue(result.log().eq(expected));
    }

    function test_benaadams() public {
        uint256 target = 0;
        string memory expected = "0.00";
        string memory result = pp(target, 18, 2);
        require(result.log().eq(expected));
        // assertTrue(result.log().eq(expected));

        SolPretty.SolPrettyOptions memory opts = SolPretty.SolPrettyOptions({
            fixedDecimals: 18,
            displayDecimals: 5, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: ".",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 3,
            integerDelimiter: ",",
            integerGroupingSize: 1,
            fixedWidth: 0
        });
        target = uint256(0.000001 ether);
        result = pp(target, opts);
        expected = "0.000 00";
        assertTrue(result.log().eq(expected));
    }

    function test_pp_default() public {
        string memory expected = "123,456,789";
        uint256 target = 123456789;
        assertTrue(pp(target).log().eq(expected));
    }

    function test_pp_fp() public {
        string memory expected = "123,456,789.987654321987654321";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18).log().eq(expected));
    }

    function test_pp_displaydecimals() public {
        string memory expected = "123,456,789.9876";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 4).log().eq(expected));
    }

    function test_pp_displaydecimals2() public {
        string memory expected = "123,456,789";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 0).log().eq(expected));
    }

    function test_pp_fixedwidth() public {
        string memory expected = "    123,456,789.9876";
        uint256 target = 123456789987654321987654321;
        assertTrue(pp(target, 18, 4, 20).log().eq(expected));
    }

    function test_pp_opts1() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1|2|3|4|5|6|7|8|9X9876 5432 19";
        SolPretty.SolPrettyOptions memory opts = SolPretty.SolPrettyOptions({
            fixedDecimals: 18,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: "X",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 4,
            integerDelimiter: "|",
            integerGroupingSize: 1,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).log().eq(expected));
    }

    function test_pp_opts2() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1,234,567,899,876,543,219,876,543-21";
        SolPretty.SolPrettyOptions memory opts = SolPretty.SolPrettyOptions({
            fixedDecimals: 2,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: "-",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).log().eq(expected));
    }

    function test_pp_opts3() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "123456789987654321O987X654X321";
        SolPretty.SolPrettyOptions memory opts = SolPretty.SolPrettyOptions({
            fixedDecimals: 9,
            displayDecimals: 10,
            decimalDelimter: "O",
            fractionalDelimiter: "X",
            fractionalGroupingSize: 3,
            integerDelimiter: "",
            integerGroupingSize: 3,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).log().eq(expected));
    }

    function testWithoutSolPretty() public {
        console.log(uint256(12300000000000000000));
        console.log("from pool:");
        console.log(uint256(127000000000000000000));
        console.log(uint256(128000000000000000000));
        console.log(uint256(7000000000000000000));
        console.log("here");
        console.logBytes(abi.encode(1));
        console.log(uint256(7332330000000000000));
        console.log(uint256(25650003));
        console.log(uint256(25750004));
        console.log(uint256(25750005));
        revert("sucker");
    }

    function testFixedWidth() public {
        SolPretty.SolPrettyOptions memory optsWETH = SolPretty.SolPrettyOptions({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });
        string memory result = pp(1500000000000000000, optsWETH).log();
        assertTrue(result.eq("              1.5000"));
    }

    function testSolPrettytestWithoutSolPretty() public {
        SolPretty.SolPrettyOptions memory optsWETH = SolPretty.SolPrettyOptions({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });

        SolPretty.SolPrettyOptions memory optsUSDC = SolPretty.SolPrettyOptions({
            fixedDecimals: 6,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });

        pp(uint256(12300000000000000000), optsWETH).concat(" Alice's WETH balance before").log();
        pp(uint256(127000000000000000000), optsWETH).concat(" Alice's WETH balance during").log();
        pp(uint256(128000000000000000000), optsWETH).concat(" Alice's WETH balance after").log();
        pp(uint256(7000000000000000000), optsWETH).concat(" Bob's WETH balance before").log();
        pp(uint256(7332330000000000000), optsWETH).concat(" Bob's WETH balance after").log();
        pp(uint256(25650003), optsUSDC).concat(" Alice USDC final balance").log();
        pp(uint256(25750004), optsUSDC).concat(" Alice USDC final balance").log();
        pp(uint256(25750005), optsUSDC).concat(" Alice USDC final balance").log();
    }

    function testConcatList() public {
        string[] memory list = new string[](3);
        list[0] = "a";
        list[1] = "b";
        list[2] = "c";
        string memory expected = "abc";
        string memory result = SolPretty.concat(list);
        assertTrue(result.eq(expected));
    }

    function testLogList() public {
        string[] memory list = new string[](3);
        list[0] = "a";
        list[1] = "b";
        list[2] = "c";
        SolPretty.log(list);
    }

    function test_prettyPrint() public {
        string memory hi = "hi";
        assertTrue(hi.echo().eq("hi"));
    }
}

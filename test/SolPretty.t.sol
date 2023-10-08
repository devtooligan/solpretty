// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2 as console} from "forge-std/Test.sol";
import "../src/SolPretty.sol";

contract SolPrettyTest is Test, SolPretty {
    using LibFormatString for *;
    using LibFormatDec for *;
    using LibLog for *;

    function setUp() public {}

    function test_fractional1() public {
        uint256 target = 0.95e18;
        string memory expected = "0.9500";
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
        require(pp(target, 18, 2).eq(expected));
        // assertTrue(result.log().eq(expected));

        LibFormatDec.Config memory config = LibFormatDec.Config({
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
        expected = "0.000 00";
        assertTrue(pp(target, config).eq(expected));
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

    function test_pp_opts1() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1|2|3|4|5|6|7|8|9X9876 5432 19";
        LibFormatDec.Config memory opts = LibFormatDec.Config({
            fixedDecimals: 18,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: "X",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 4,
            integerDelimiter: "|",
            integerGroupingSize: 1,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).eq(expected));
    }

    function test_pp_opts2() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "1,234,567,899,876,543,219,876,543-21";
        LibFormatDec.Config memory opts = LibFormatDec.Config({
            fixedDecimals: 2,
            displayDecimals: 10, // if this is less than fixedDecimals, value will be truncated
            decimalDelimter: "-",
            fractionalDelimiter: " ",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).eq(expected));
    }

    function test_pp_opts3() public {
        uint256 target = 123456789987654321987654321;
        string memory expected = "123456789987654321O987X654X321";
        LibFormatDec.Config memory opts = LibFormatDec.Config({
            fixedDecimals: 9,
            displayDecimals: 10,
            decimalDelimter: "O",
            fractionalDelimiter: "X",
            fractionalGroupingSize: 3,
            integerDelimiter: "",
            integerGroupingSize: 3,
            fixedWidth: 0
        });
        assertTrue(pp(target, opts).eq(expected));
    }

    function testWithoutSolPretty() public pure {
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
        LibFormatDec.Config memory optsWETH = LibFormatDec.Config({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });
        assertTrue(pp(1500000000000000000, optsWETH).eq("              1.5000"));
    }

    function testSolPrettytestWithoutSolPretty() public pure {
        LibFormatDec.Config memory optsWETH = LibFormatDec.Config({
            fixedDecimals: 18,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });

        LibFormatDec.Config memory optsUSDC = LibFormatDec.Config({
            fixedDecimals: 6,
            displayDecimals: 4,
            decimalDelimter: ".",
            fractionalDelimiter: "",
            fractionalGroupingSize: 0,
            integerDelimiter: ",",
            integerGroupingSize: 3,
            fixedWidth: 20
        });

        pp(uint256(12300000000000000000).format(optsWETH).concat(" Alice's WETH balance before"));
        pp(uint256(127000000000000000000).format(optsWETH).concat(" Alice's WETH balance during"));
        pp(uint256(128000000000000000000).format(optsWETH).concat(" Alice's WETH balance after"));
        pp(uint256(7000000000000000000).format(optsWETH).concat(" Bob's WETH balance before"));
        pp(uint256(7332330000000000000).format(optsWETH).concat(" Bob's WETH balance after"));
        pp(uint256(25650003).format(optsUSDC).concat(" Alice USDC final balance"));
        pp(uint256(25750004).format(optsUSDC).concat(" Alice USDC final balance"));
        pp(uint256(25750005).format(optsUSDC).concat(" Alice USDC final balance"));
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

    function test_prettyPrint() public {
        string memory hi = "hi";
        assertTrue(hi.echo().eq("hi"));
    }
}

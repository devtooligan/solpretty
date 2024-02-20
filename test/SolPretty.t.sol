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

    // TODO:

    //  - Do some tests for Box of different sizes and alignments along with concat
    //  - borderBox is 6 boxes. There are 4 corners plus top, bottom, left and right
    //  - borderBox can be used to create a border around a box
    //  - Should Box be a custom type?

    function testFixLength() public {
        console.log(SolPretty.fill("X", 80));
        string memory x = "a";
        string memory y = "bbbbbbbbbbb";
        assertTrue(SolPretty.fixLength(x, 80).eq(x.concat(SolPretty.spaces(79))));
        assertTrue(SolPretty.fixLength(y, 2).eq("bb"));
    }

    function testFillBox() public {
        string[] memory rows = new string[](2);
        rows[0] = "12";
        rows[1] = "34";
        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 2, rows: rows});
        SolPretty.Box memory result = box1.fill(21, 3);
        assertTrue(result.width == 21);
        assertTrue(result.height == 3);
        assertTrue(result.rows.length == 3);
        assertTrue(result.rows[0].eq("121212121212121212121"));
        assertTrue(result.rows[1].eq("343434343434343434343"));
        assertTrue(result.rows[2].eq("121212121212121212121"));

        string[] memory expected = new string[](3);
        expected[0] = "121212121212121212121";
        expected[1] = "343434343434343434343";
        expected[2] = "121212121212121212121";

        for (uint256 i = 0; i < result.rows.length; i++) {
            assertTrue(result.rows[i].eq(expected[i]));
        }
        pp(result.rendered());
    }

    function testBorderBox() public {
        string[] memory dataRows = new string[](3);
        dataRows[0] = "Beginning Balance - DAI: 1,239.00";
        dataRows[1] = "some stuff......";
        dataRows[2] = "Ending Balance -    DAI: 1,240.00";
        SolPretty.Box memory data = SolPretty.Box({width: 33, height: 3, rows: dataRows});
        string memory symbol = "**";
        SolPretty.BorderBox memory bbox = data.createBorderBox(symbol, 2, 2, 2, 2);
        assertTrue(bbox.data.height == 3);
        assertTrue(bbox.data.width == 33);
        assertTrue(bbox.data.rows.length == 3);
        assertTrue(bbox.tile.topLeft.rows[0].eq(symbol));
        assertTrue(bbox.tile.topRight.rows[0].eq(symbol));
        assertTrue(bbox.tile.middleLeft.rows[0].eq(symbol));
        assertTrue(bbox.tile.middleRight.rows[0].eq(symbol));
        assertTrue(bbox.tile.bottomLeft.rows[0].eq(symbol));
        assertTrue(bbox.tile.bottomRight.rows[0].eq(symbol));

        data = data.pad(3, 1);
        string[] memory bboxRenderedRows = pp(data.createBorderBox("**", 2, 2, 2, 2).rendered());
        assertEq("*******************************************", bboxRenderedRows[0]);
        assertEq("*******************************************", bboxRenderedRows[1]);
        assertEq("**                                       **", bboxRenderedRows[2]);
        assertEq("**   Beginning Balance - DAI: 1,239.00   **", bboxRenderedRows[3]);
        assertEq("**   some stuff......                    **", bboxRenderedRows[4]);
        assertEq("**   Ending Balance -    DAI: 1,240.00   **", bboxRenderedRows[5]);
        assertEq("**                                       **", bboxRenderedRows[6]);
        assertEq("*******************************************", bboxRenderedRows[7]);
        assertEq("*******************************************", bboxRenderedRows[8]);
    }

    function testBorderBox2() public {
        string[] memory dataRows = new string[](3);
        dataRows[0] = "Beginning Balance - DAI: 1,239.00";
        dataRows[1] = "some stuff......";
        dataRows[2] = "Ending Balance -    DAI: 1,240.00";
        SolPretty.Box memory data = SolPretty.Box({width: 33, height: 3, rows: dataRows});
        data = data.pad(3, 1);


        SolPretty.BorderBox memory bbox = data.createBorderBox(SolKawai.star(), 6, 6, 14, 14);

        string[] memory bboxRenderedRows = pp(bbox.rendered());
        assertTrue("`. __/ \\__ .'    Beginning Balance - DAI: 1,239.00   `. __/ \\__ .' ".eq(bboxRenderedRows[7]));
    }

    function testBorderBox3() public {
        string[] memory dataRows = new string[](3);
        dataRows[0] = "Beginning Balance - DAI: 1,239.00";
        dataRows[1] = "some stuff......";
        dataRows[2] = "Ending Balance -    DAI: 1,240.00";
        SolPretty.Box memory data = SolPretty.Box({width: 33, height: 3, rows: dataRows});
        data = data.pad(3, 1);


        SolPretty.BorderBox memory bbox = data.createBorderBox(SolKawai.cartman(), 17, 17, 34, 34);

        string[] memory bboxRenderedRows = pp(bbox.rendered());
        // assertTrue("`. __/ \\__ .'    Beginning Balance - DAI: 1,239.00   `. __/ \\__ .' ".eq(bboxRenderedRows[7]));
    }

    function testBoxGeneralDefault() public {
        string[] memory expected1 = new string[](2);
        expected1[0] = "12";
        expected1[1] = "34";
        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 2, rows: expected1});
        string[] memory expected2 = new string[](2);
        expected2[0] = "56";
        expected2[1] = "78";
        SolPretty.Box memory box2 = SolPretty.Box({width: 2, height: 2, rows: expected2});

        string[] memory result1 = pp(box1);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory result2 = pp(box2);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2));
        string[] memory expected3 = new string[](2);
        expected3[0] = "12 56";
        expected3[1] = "34 78";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

    function testBoxGeneralCenterAligned() public {
        string[] memory expected1 = new string[](2);
        expected1[0] = "12";
        expected1[1] = "34";
        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 2, rows: expected1});
        string[] memory expected2 = new string[](2);
        expected2[0] = "56";
        expected2[1] = "78";
        SolPretty.Box memory box2 = SolPretty.Box({width: 2, height: 2, rows: expected2});

        string[] memory result1 = pp(box1, 1);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory result2 = pp(box2, 1);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2), 1);
        string[] memory expected3 = new string[](2);
        expected3[0] = "12 56";
        expected3[1] = "34 78";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

    function testBoxBigCenterAligned() public {
        string[] memory rows1 = new string[](2);
        rows1[0] = "12";
        rows1[1] = "34";

        string[] memory expected1 = new string[](5);
        expected1[0] = SolPretty.spaces(2);
        expected1[1] = rows1[0];
        expected1[2] = rows1[1];
        expected1[3] = SolPretty.spaces(2);
        expected1[4] = SolPretty.spaces(2);

        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 5, rows: rows1});
        string[] memory result1 = pp(box1, 1);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory rows2 = new string[](5);
        rows2[0] = SolPretty.fill("*", 10);
        rows2[1] = SolPretty.fill("*", 10);
        rows2[2] = SolPretty.fill("*", 10);
        rows2[3] = SolPretty.fill("*", 10);
        rows2[4] = SolPretty.fill("*", 10);

        string[] memory expected2 = new string[](5);
        expected2[0] = SolPretty.shorten(rows2[0], 3);
        expected2[1] = SolPretty.shorten(rows2[0], 3);
        expected2[2] = SolPretty.shorten(rows2[0], 3);
        expected2[3] = SolPretty.shorten(rows2[0], 3);
        expected2[4] = SolPretty.shorten(rows2[0], 3);
        SolPretty.Box memory box2 = SolPretty.Box({width: 3, height: 5, rows: rows2});

        string[] memory result2 = pp(box2, 1);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2));
        string[] memory expected3 = new string[](5);
        expected3[0] = "   ***";
        expected3[1] = "12 ***";
        expected3[2] = "34 ***";
        expected3[3] = "   ***";
        expected3[4] = "   ***";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

    function testBoxBigTopAligned() public {
        string[] memory rows1 = new string[](2);
        rows1[0] = "12";
        rows1[1] = "34";

        string[] memory expected1 = new string[](5);
        expected1[0] = rows1[0];
        expected1[1] = rows1[1];
        expected1[2] = SolPretty.spaces(2);
        expected1[3] = SolPretty.spaces(2);
        expected1[4] = SolPretty.spaces(2);

        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 5, rows: rows1});
        string[] memory result1 = pp(box1, 2);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory rows2 = new string[](5);
        rows2[0] = SolPretty.fill("*", 10);
        rows2[1] = SolPretty.fill("*", 10);
        rows2[2] = SolPretty.fill("*", 10);
        rows2[3] = SolPretty.fill("*", 10);
        rows2[4] = SolPretty.fill("*", 10);

        string[] memory expected2 = new string[](5);
        expected2[0] = SolPretty.shorten(rows2[0], 3);
        expected2[1] = SolPretty.shorten(rows2[0], 3);
        expected2[2] = SolPretty.shorten(rows2[0], 3);
        expected2[3] = SolPretty.shorten(rows2[0], 3);
        expected2[4] = SolPretty.shorten(rows2[0], 3);
        SolPretty.Box memory box2 = SolPretty.Box({width: 3, height: 5, rows: rows2});

        string[] memory result2 = pp(box2, 2);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2));
        string[] memory expected3 = new string[](5);
        expected3[0] = "   ***";
        expected3[1] = "12 ***";
        expected3[2] = "34 ***";
        expected3[3] = "   ***";
        expected3[4] = "   ***";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

    function testBoxBigBottomAligned() public {
        string[] memory rows1 = new string[](2);
        rows1[0] = "12";
        rows1[1] = "34";

        string[] memory expected1 = new string[](5);
        expected1[0] = SolPretty.spaces(2);
        expected1[1] = SolPretty.spaces(2);
        expected1[2] = SolPretty.spaces(2);
        expected1[3] = rows1[0];
        expected1[4] = rows1[1];

        SolPretty.Box memory box1 = SolPretty.Box({width: 2, height: 5, rows: rows1});
        string[] memory result1 = pp(box1, 0);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory rows2 = new string[](5);
        rows2[0] = SolPretty.fill("*", 10);
        rows2[1] = SolPretty.fill("*", 10);
        rows2[2] = SolPretty.fill("*", 10);
        rows2[3] = SolPretty.fill("*", 10);
        rows2[4] = SolPretty.fill("*", 10);

        string[] memory expected2 = new string[](5);
        expected2[0] = SolPretty.shorten(rows2[0], 3);
        expected2[1] = SolPretty.shorten(rows2[0], 3);
        expected2[2] = SolPretty.shorten(rows2[0], 3);
        expected2[3] = SolPretty.shorten(rows2[0], 3);
        expected2[4] = SolPretty.shorten(rows2[0], 3);
        SolPretty.Box memory box2 = SolPretty.Box({width: 3, height: 5, rows: rows2});

        string[] memory result2 = pp(box2, 0);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2));
        string[] memory expected3 = new string[](5);
        expected3[0] = "   ***";
        expected3[1] = "12 ***";
        expected3[2] = "34 ***";
        expected3[3] = "   ***";
        expected3[4] = "   ***";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

    function testBoxSmallAllAlignments() public {
        string[] memory rows1 = new string[](5);
        rows1[0] = "12345xxxxxxxxxxx";
        rows1[1] = "67890xxxxxxxx";
        rows1[2] = "xxxxxxx";
        rows1[3] = "ala;dflkad;kadf;lkad";
        rows1[4] = "345678910";

        string[] memory expected1 = new string[](2);
        expected1[0] = rows1[0].shorten(5);
        expected1[1] = rows1[1].shorten(5);

        SolPretty.Box memory box1 = SolPretty.Box({width: 5, height: 2, rows: rows1});

        string[] memory result1 = pp(box1, 1);
        assertTrue(result1.length == expected1.length);
        for (uint256 i = 0; i < result1.length; i++) {
            assertTrue(result1[i].eq(expected1[i]));
        }

        string[] memory rows2 = new string[](5);
        rows2[0] = "*";
        rows2[1] = "*";
        rows2[2] = "*";
        rows2[3] = "*";
        rows2[4] = "*";

        string[] memory expected2 = new string[](3);
        expected2[0] = SolPretty.fixLength(rows2[0], 3);
        expected2[1] = SolPretty.fixLength(rows2[0], 3);
        expected2[2] = SolPretty.fixLength(rows2[0], 3);
        SolPretty.Box memory box2 = SolPretty.Box({width: 3, height: 3, rows: rows2});

        string[] memory result2 = pp(box2, 1);
        assertTrue(result2.length == expected2.length);
        for (uint256 i = 0; i < result2.length; i++) {
            assertTrue(result2[i].eq(expected2[i]));
        }

        string[] memory result3 = pp(box1.addSpaces(1).concat(box2));
        string[] memory expected3 = new string[](3);
        expected3[0] = "12345 *  ";
        expected3[1] = "67890 *  ";
        expected3[2] = "      *  ";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }

        result3 = pp(box1.addSpaces(1).concat(box2, SolPretty.VerticalAlignment.Bottom));
        expected3 = new string[](3);
        expected3[0] = "      *  ";
        expected3[1] = "12345 *  ";
        expected3[2] = "67890 *  ";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }

        result3 = pp(box1.addSpaces(1).concat(box2), 2);
        expected3 = new string[](3);
        expected3[0] = "12345 *  ";
        expected3[1] = "67890 *  ";
        expected3[2] = "      *  ";
        assertTrue(result3.length == expected3.length);
        for (uint256 i = 0; i < result3.length; i++) {
            assertTrue(result3[i].eq(expected3[i]));
        }
    }

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
        string memory result = pp(uint256(1500000000000000000), configWETH, "result");
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
        loggit(list);
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

    // deprecated
    // function testBorder() public {
    //     string[] memory body = new string[](3);
    //     SolPretty.Config memory config = decimalsFormat;
    //     config.fixedDecimals = 18;
    //     config.displayDecimals = 2;
    //     config.fixedWidth = 15;
    //     body[0] = SolPretty.format(uint256(1.875 ether), config).space().concat("USDT balance");
    //     body[1] = SolPretty.format(uint256(0.0875 ether), config).space().concat("WETH balance");
    //     body[2] = SolPretty.format(uint256(122828.75 ether), config).space().concat("DAI balance");
    //     pp(addBorder(body));

    //     string[] memory result = new string[](9);
    //     result = pp(addBorder(body, "Alice's balances"));
    //     require(result[0].eq("*".fill(80)));
    //     string memory empty = "*                                                                              *";
    //     require(result[1].eq(empty));
    //     string memory title = "*                               Alice's balances                               *";
    //     require(result[2].eq(title));
    //     require(result[3].eq(empty));
    //     string memory currentBody = "*            1.87 USDT balance                                                 *";
    //     require(result[4].eq(currentBody));
    //     currentBody = "*            0.08 WETH balance                                                 *";
    //     require(result[5].eq(currentBody));
    //     currentBody = "*      122,828.75 DAI balance                                                  *";
    //     require(result[6].eq(currentBody));
    //     require(result[7].eq(empty));
    //     require(result[8].eq("*".fill(80)));
    //     /**
    //      * struct Box {
    //      *             string title; // "" to ommit
    //      *             string symbol;
    //      *             uint256 totalWidth;
    //      *             uint256 borderWidth;
    //      *             uint256 borderHeight;
    //      *         }
    //      */
    //     SolKawai.Box memory box = SolKawai.Box("Alice's balances", SolKawai.solady_divider, 80, 10, 5);
    //     pp(addBorder(body, box));
    //     box = SolKawai.Box("Alice's balances", "X", 80, 10, 5);
    //     pp(addBorder(body, box));

    //     pp();
    //     pp();
    //     pp();
    //     pp();
    //     pp();
    //     pp();
    //     pp(body);
    //     pp();
    //     console.log("dividerSolady():");
    //     dividerSolady();
    //     console.log("addBorderSolady():");
    //     pp();
    //     pp(addBorderSolady(body));
    // }

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
        uint256 length = SoladyStrings.runeCount(text);
        pp(length, "length");
        uint256 cursor = 0;
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

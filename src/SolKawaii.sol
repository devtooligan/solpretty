// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;


// import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
// import {LibString as SoladyStrings} from "solady/src/utils/LibString.sol";
// import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

// /// @notice A library for graphics, borders, and other ascii art
// /// かわいい!
// contract SolKawai {

//     // GRAPHICS ********************************************************************

//     function border() pure internal {
//         pp();
//         fill("-").log();
//         pp();
//     }

//     function border(string memory symbol) pure internal {
//         pp();
//         fill(symbol).log();
//         pp();
//     }

//     function border(string memory symbol, uint length) pure internal {
//         pp();
//         fill(symbol, length).log();
//         pp();
//     }

//     function fill(string memory symbol, uint length) pure internal returns (string memory filled) {
//         if (length == 0) return "";
//         filled = new string(length);
//         for (uint i = 0; i < length; i++) {
//             filled = filled.concat(symbol);
//         }
//     }

//     function fill(string memory symbol) pure internal returns (string memory filled) {
//         return fill(symbol, 80);
//     }

// }
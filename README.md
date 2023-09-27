## solpretty
![Solidity][solidity-shield]

A library for pretty printing numbers in Solidity

built on [Solady](https://github.com/Vectorized/solady)

## Installation
To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install devtooligan/solpretty
```

## Usage

### pp
 - pp(uint256 value)
 - pp(uint256 value, uint256 fixedDecimals)
 - pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals)
 - pp(uint256 value, uint256 fixedDecimals, uint256 displayDecimals, uint256 fixedWidth)
 - pp(uint256 value, memory SolPrettyOptions)

```solidity
import {pp} from "solpretty/solpretty.sol";

pp(123123123123) //            -> "123,123,123,123" //  default
pp(123123123123, 6) //         -> "123,123.123123" //   fixedDecimals = 6
pp(123123123123, 6, 2) //      -> "123,123.12" //       displayDecimals = 2
pp(123123123123, 6, 0, 15) //  -> "         123,123" // fixedWidth = 15
```

Customizeable options:

```solidity

SolPrettyOptions memory solPrettyOptions = getDefaultOptions();

SolPrettyOptions.fixedDecimals = 6;
SolPrettyOptions.fixedWidth = 20;
SolPrettyOptions.decimalDelimeter = bytes1("*");
SolPrettyOptions.integerDelimeter = bytes1(" ");

pp(123123123123, solPrettyOptions); // -> "      123 123*123123"

struct SolPrettyOptions {
    uint256 fixedDecimals; //          default 0
    uint256 displayDecimals; //        default type(uint256).max
    bytes1 decimalDelimter; //         default "."
    bytes1 fractionalDelimiter; //     default " "
    uint256 fractionalGroupingSize; // default 0
    bytes1 integerDelimiter; //        default ","
    uint256 integerGroupingSize; //    default 3
    uint256 fixedWidth; //             default 0 (automatic)
}

```

### concat
 - concat(string memory left, string memory right)
 - concat(string[] memory parts)

```solidity
pp(1234).concat(" Alice's balance"); // -> "1,234 Alice's Balance";

string[] memory strings = new string[](3);
strings[0] = "a";
strings[1] = "b";
strings[2] = "c";
concat(strings); // -> "abc"

```

### log
 - log(string memory message)
 - log(string[] memory messages)

```solidity
using SolPretty for string;

log("hoagies"); // console2.log("hoagies");
pp(1234).log(); // console2.log("1,234")
pp(1234).concat(" Alice's balance").log(); // console2.log("1,234 Alice's balance")

```

[solidity-shield]: https://img.shields.io/badge/solidity-%3E=0.8.4%20%3C=0.8.19-aa6746

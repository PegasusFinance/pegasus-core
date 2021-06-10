pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "../interfaces/IUniswapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../mocks/MintableERC20.sol";
import "hardhat/console.sol";

contract IUniswapV2RouterMock is IUniswapV2Router01{

    MintableERC20 pair;

    address weth;
    address wbnb;
    address peg;

    constructor(address _pair, address _weth, address _wbnb, address _peg){
        pair = MintableERC20(_pair);
        weth = _weth;
        wbnb = _wbnb;
        peg = _peg;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity) {

        if(tokenA == wbnb && tokenB == peg){
            console.log("%s -> %s = %s", amountADesired, amountBDesired, amountADesired * 100);
            require(amountBDesired >= amountADesired * 4, "Peg too less");
            IERC20(wbnb).transferFrom(msg.sender, address(this), amountADesired);
            IERC20(peg).transferFrom(msg.sender, address(this), amountBDesired);
            pair.mint(msg.sender, amountADesired * 100);
            return (amountADesired, amountBDesired, amountADesired * 100);
        }
        require(false, "Not supported pair2");
        return (0, 0, 0);

    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB){

        return (0, 0);

    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override returns (uint256[] memory amounts){

        uint256[] memory arr = new uint256[](2);
        arr[0] = amountIn;
        if(path[0] == weth && path[1] == wbnb){
            arr[1] = amountIn * 2;
            IERC20(weth).transferFrom(msg.sender, address(this), amountIn);
            MintableERC20(wbnb).mint(msg.sender, amountIn * 2);
        }else if(path[0] == wbnb && path[1] == peg){
            IERC20(wbnb).transferFrom(msg.sender, address(this), amountIn);
            IERC20(peg).transfer(msg.sender, amountIn * 5);
            arr[1] = amountIn * 5;
        }else{
            require(false, toAsciiString(path[1]));
        }
        return arr;

    }

    function toAsciiString(address x) internal view returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal view returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    // function toString(address account) public pure returns(string memory) {
    //     return toString(abi.encodePacked(account));
    // }

    // function toString(bytes memory data) public pure returns(string memory) {
    //     bytes memory alphabet = "0123456789abcdef";

    //     bytes memory str = new bytes(2 + data.length * 2);
    //     str[0] = "0";
    //     str[1] = "x";
    //     for (uint i = 0; i < data.length; i++) {
    //         str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
    //         str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
    //     }
    //     return string(str);
    // }

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        override
        returns (uint256[] memory amounts){
            require(false, "getAmountsOut!!!");
            uint256[] memory arr = new uint256[](2);
            return arr;
        }

}
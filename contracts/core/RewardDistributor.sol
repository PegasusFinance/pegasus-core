pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IFeePayable.sol";

contract RewardDistributor is Ownable, IFeePayable{

    using SafeMath for uint;
 
    address dev;
    mapping(address => address) directs;

    uint directFee = 50;

    constructor (address _dev) {
        dev = _dev;
    }

    function setDirect(address direct) public {
        directs[msg.sender] = direct;
    }

    function feePaid(address tokenAdr, uint amount) override public { //TODO onlyRewardSplitter

        address direct = directs[msg.sender];
        IERC20 token = IERC20(tokenAdr);

        require(amount > 0);
        require(token.balanceOf(address(this)) >= amount);

        if(direct != address(0)){

            token.transfer(direct, amount.mul(directFee).div(100));

        }
    }

    function withdrawDev(address[] calldata tokens) public {
        require(msg.sender == dev || msg.sender == owner(), "Sender not allowed");

        for(uint8 i = 0 ; i < tokens.length ; i++){
            IERC20 token = IERC20(tokens[i]);
            token.transfer(dev, token.balanceOf(address(this)));
        }

    }

    //* Owner Function */
    function setDev(address _dev) external onlyOwner {
        require(_dev != address(0));
        dev = _dev;
    }

    function setDirectfee(uint fee) external onlyOwner {
        directFee = fee;
    }

    function setDirectOwner(address from, address direct) external onlyOwner {
        directs[from] = direct;
    }

}
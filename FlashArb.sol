// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashArb is FlashLoanSimpleReceiverBase, Ownable {
    
    constructor(address _addressProvider) 
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) 
        Ownable(msg.sender) 
    {}

    /**
     * @dev Execution logic triggered by Aave after receiving loan.
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // ARBITRAGE LOGIC GOES HERE
        // 1. Swap 'asset' on DEX A
        // 2. Swap back to 'asset' on DEX B
        
        uint256 amountToReturn = amount + premium;
        require(IERC20(asset).balanceOf(address(this)) >= amountToReturn, "Insufficient funds to repay loan");
        
        IERC20(asset).approve(address(POOL), amountToReturn);
        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public onlyOwner {
        POOL.flashLoanSimple(address(this), _token, _amount, "", 0);
    }

    function withdraw(address _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}

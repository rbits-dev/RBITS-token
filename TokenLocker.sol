/*
                                                                   
Simple Hard Locker

Lock Tokens in the contract

*/

pragma solidity ^0.8.18;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenLocker is Context, Ownable {
    
    IERC20 public tokenAddress;

    event Unlock(uint256 amount);
    event PartialUnlock(uint256 amount);
    event Lock(uint256 amount);
    event RescueETH(uint256 amount, address beneficiary);
   
    uint64 public releaseTime = 0;
    
    function setTokenAddress(address tokenContractAddr) external onlyOwner() {
        require( tokenContractAddr != address(0));
        tokenAddress = IERC20(tokenContractAddr);
    }

    /**
     * Set the unlock time
     */
    function lock( uint64 _releaseTime) external onlyOwner() {
        require( _releaseTime > block.timestamp , "Must be in the future");
        require( _releaseTime < ( block.timestamp + ( 6 * 30 days)), "Too far in the future" );

        releaseTime = _releaseTime;
        
        uint256 balance = tokenAddress.balanceOf( address(this) );
        require( balance > 0, "No tokens to lock");
        emit Lock(balance);
    }
    
    /**
     * if time lock has expired, transfer the balance of the smart contract 
     */
    function unlock() external onlyOwner {
        require(block.timestamp >= releaseTime, "Time lock is still active");
        
        uint256 balance = tokenAddress.balanceOf( address(this) );
        require( balance > 0, "No tokens to unlock");

        tokenAddress.transfer( msg.sender , balance );
             
        emit Unlock(balance);
    }
  
    /**
     * if time lock has expired, transfer given amount of the smart contract 
     */
    function partialUnlock(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(block.timestamp >= releaseTime, "Time lock is still active");
        
        uint256 balance = tokenAddress.balanceOf(address(this));
        require(amount <= balance, "Insufficient balance");

        tokenAddress.transfer(msg.sender, amount);
             
        emit PartialUnlock(amount);
    }

    // rescue ETH accidently sent to contract address
    function rescueETH(uint256 amount, address beneficiary) external onlyOwner {
        payable( beneficiary ).transfer(amount);

        emit RescueETH(amount, beneficiary );
    }

}
/*
                                   
RBITS: A frictionless yield NFT/gaming token

TG: https://t.me/rbitsportal

X: https://twitter.com/RBitsOfficial

Web: https://rbits.xyz

dev notes:
- High Tax on launch (25%)
- After setFees is called to set the new tax rate, it can never be set higher than 5%
- No limits

*/


pragma solidity ^0.8.18;
// SPDX-License-Identifier: Unlicensed
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

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
        require(_owner == _msgSender(), "Not owner");
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
        require(newOwner != address(0), "Renounced");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Rabbits is Context, IERC20, Ownable {
  
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _specialFees; // fee amount for special addresses
    mapping( address => bool) private _hasSpecialFee; // addresses eligible for special fees
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromReward;  // addresses excluded from reflection rewards
    
    address[] private _excludedFromReward; // addresses not eligible for reflection rewards

    address payable public _platformFundAddress = payable(0xDbB3582AF53846d5C1E6E1d049FBe4F890Ca857A);
   
    uint256 public numTokensToSell = 500000 * 10**6 * 10**9; // 500 billion
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _TTOTAL = 1000000000 * 10**6 * 10**9;  // 1 quadrillion
    uint256 private constant WHALETHRESHOLD = 5000000 * 10**6 * 10**9; // 0.5 trillion
    uint256 private constant MAXLIQUIFYAMOUNT = 10000000 * 10**6 * 10**9; // 1 trillion

    uint256 private _rTotal = (MAX - (MAX % _TTOTAL));

    string private constant NAME = "Rabbits";
    string private constant SYMBOL = "RBITS";
    uint8 private constant DECIMALS = 9;
    
    // initially, high taxes to seed project funds
    uint256 public _taxFee = 0;                    // percentage that is distributed to all holders
    uint256 private _prevTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 0;              // percentage that is added to LP
    uint256 private _prevLiquidityFee = _liquidityFee;

    uint256 public _projectFee = 2500;             // percentage that is added to project fund
    uint256 private _prevProjectFee = _projectFee;

    uint256 public _totalLiqFee = 0;               // total fee to be liquified 
    uint256 private _prevTotalLiqFee = _totalLiqFee;

    // target tax rate (5%)
    // tax can be modified but new taxrate must be equal to or less than 5%
    uint256 private constant TARGETFEE = 500;
    bool private _transferTaxEnabled = false;
    uint256 public _totalFee = 0;
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool private inSwapAndLiquify;
    
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyMaxAmountEnabled = true;

    uint256 private _timeLock = 0;

    event SetFee(address account, uint256 newFee, bool enabled);
    event SetFees(uint256 newRewardFee, uint256 newLiquidityFee, uint256 newProjectFee, bool transferTax);
    event SetPlatformFundAddress(address newAddress);
    event ExcludeFromReward(address addr);
    event IncludeInReward(address addr);
    event SetSwapAndLiquifyMaxAmount(uint256 amount);
    event SetSwapAndLiquifyEnabled(bool swapEnabled, bool maxAmountEnabled);
    event RescueETH(uint256 amount, address addr);
    event RescueERC20(uint256 amount, address addr);
    event RemoveLiquidity(uint256 percentage);
    event AddInitialLiquidity();
    event OpenTrading();

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        // BSC Testnet

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
       
        //exclude owner, fund address and this contract from fee
        _hasSpecialFee[ owner() ] = true;
        _hasSpecialFee[ address(this) ] = true;
        _hasSpecialFee[ _platformFundAddress ] = true;

        //exclude pair from receiving reflection rewards
        _isExcludedFromReward[ uniswapV2Pair ] = true;
        
        _totalLiqFee = _liquidityFee + _projectFee;
        _prevTotalLiqFee = _totalLiqFee;

        _timeLock = block.timestamp;

        emit Transfer(address(0), _msgSender(), _TTOTAL);
    }

    function name() external pure returns (string memory) {
        return NAME;
    }

    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() external pure override returns (uint256) {
        return _TTOTAL;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= _TTOTAL);
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal);
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function isFeeForAddressEnabled(address account) external view returns (bool) {
        return _hasSpecialFee[ account ];
    }

    function getFeeForAddress(address account) external view returns (uint256) {
        return  _specialFees[ account ];
    }

    function setPlatformFundAddress(address newAddress) external onlyOwner() {
        require( newAddress != address(0) );
        _platformFundAddress = payable(newAddress);

        emit SetPlatformFundAddress(newAddress);
    }

   function setFees(uint256 newRewardFee, uint256 newLiquidityFee, uint256 newProjectFee, bool transferTax) 
     external onlyOwner() {
        require( (newRewardFee + newLiquidityFee + newProjectFee) <= TARGETFEE); // cannot be more than 5%
        
        _taxFee = newRewardFee;
        _liquidityFee = newLiquidityFee;
        _projectFee = newProjectFee;
        _transferTaxEnabled = transferTax; // if enabled, tax transfers between wallets

        _totalLiqFee = _liquidityFee + _projectFee;

        emit SetFees(newRewardFee, newLiquidityFee, newProjectFee, transferTax);
    }

    function openTrading() external onlyOwner() {
        swapAndLiquifyEnabled = true;

        emit OpenTrading();
    }

    function setFee(address account, uint256 newFee, bool enabled) external onlyOwner {
        require( newFee <= TARGETFEE ); // cannot be more than 5%

        _specialFees[ account ] = newFee;
        _hasSpecialFee[ account ] = enabled;

        emit SetFee(account, newFee, enabled);
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromReward[account]);
        require(_excludedFromReward.length < 100);
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);

        emit ExcludeFromReward(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account]);
        require(_excludedFromReward.length < 100);
        uint len = _excludedFromReward.length;
        for (uint256 i = 0; i < len; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[len - 1];
                uint256 currentRate = _getRate();
                _rOwned[account] = _tOwned[account] * currentRate;
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();

                emit IncludeInReward(account);
                break;
            }
        }
    }

    function setSwapAndLiquifyEnabled(bool swapEnabled, bool maxAmountEnabled) external onlyOwner {
        swapAndLiquifyEnabled = swapEnabled;
        swapAndLiquifyMaxAmountEnabled = maxAmountEnabled;

        emit SetSwapAndLiquifyEnabled(swapAndLiquifyEnabled, swapAndLiquifyMaxAmountEnabled);
    }

    function setSwapAndLiquifyMaxAmount(uint256 amount) external onlyOwner {
        require( amount > 0 );
        require( amount <= MAXLIQUIFYAMOUNT);
        numTokensToSell = amount;

        emit SetSwapAndLiquifyMaxAmount(numTokensToSell);
    }

    // contract gains ETH over time
    function rescueETH(uint256 amount) external onlyOwner {
        payable( msg.sender ).transfer(amount);

        emit RescueETH(amount, msg.sender );
    }

    // rescue tokens accidently sent to contract address
    function rescueERC20(address tokenAddress) external onlyOwner() {
        require(tokenAddress != address(this));
        require(tokenAddress != address(uniswapV2Pair));

        IERC20 token = IERC20(tokenAddress);
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0);

        bool success = token.transfer(_msgSender(), amount);
        require(success);

        emit RescueERC20( amount, tokenAddress );
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _totalFee = _totalFee + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount * _taxFee / (10**4);
        uint256 tLiquidity = tAmount * _totalLiqFee / (10**4);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) 
        private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _TTOTAL;
        uint len = _excludedFromReward.length;
        for (uint256 i = 0; i < len; i++) {
            if (_rOwned[_excludedFromReward[i]] > rSupply || 
                _tOwned[_excludedFromReward[i]] > tSupply) 
                    return (_rTotal, _TTOTAL);
            rSupply = rSupply - _rOwned[_excludedFromReward[i]];
            tSupply = tSupply - _tOwned[_excludedFromReward[i]];
        }
        if (rSupply < (_rTotal / _TTOTAL)) return (_rTotal, _TTOTAL);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }
    
    function saveAllFees() private {
        _prevTaxFee = _taxFee;
        _prevTotalLiqFee = _totalLiqFee;
        _prevProjectFee = _projectFee;
        _prevLiquidityFee = _liquidityFee;
    }
  
    function setTaxes(address from, address to) private returns (bool) {
        
        uint256 totalFee = _taxFee + _liquidityFee + _projectFee;
        if( totalFee == 0 ) {
            return false;
        }

        // don't tax normal transfers between wallets if transferTax is disabled
        bool isSimpleTransfer = (from != uniswapV2Pair && to != uniswapV2Pair && !_transferTaxEnabled);
        if (isSimpleTransfer && !_hasSpecialFee[from]) {
            _taxFee = 0;
            _liquidityFee = 0;
            _projectFee = 0;
            _totalLiqFee = 0;
            return false;
        }

        // if the tax rate is not yet the target tax rate, lock the tax rate on buy
        // this provides a dynamic taxrate to cushion the impact when sniper whales exit
        if( totalFee > TARGETFEE && from == uniswapV2Pair && !_hasSpecialFee[to] ) {
            if( balanceOf(to) >= WHALETHRESHOLD ) {
                _hasSpecialFee[to] = true;
                _specialFees[to]   = totalFee;
            }
        }

        if( !_hasSpecialFee[from] && !_hasSpecialFee[to]) {
            // dont change tax fee
            return false;
        }

        // either one or both of the addresses have a special fee, take the lowest
        address lowestFeeAccount = from;
        if( _hasSpecialFee[from] && _hasSpecialFee[to]) {
            lowestFeeAccount = ( _specialFees[from] > _specialFees[to] ? to : from );
        } else if ( _hasSpecialFee[to] ) {
            lowestFeeAccount = to;
        }

        // get the fee (which can be zero)
        uint256 fee = _specialFees[ lowestFeeAccount ];
        
        // set fees
        _taxFee = fee * _taxFee / totalFee;
        _liquidityFee = fee * _liquidityFee / totalFee;
        _projectFee = fee * _projectFee / totalFee;
        _totalLiqFee = _liquidityFee + _projectFee;

        return true;
    }

    function restoreAllFees(address from, address to) private {
        _taxFee = _prevTaxFee;
        _totalLiqFee = _prevTotalLiqFee;
        _projectFee = _prevProjectFee;
        _liquidityFee = _prevLiquidityFee;

        // remove special fee if new balance is near zero
        if( _hasSpecialFee[to] && balanceOf(to) < (1 * 10**9) ) {
            _specialFees[to] = 0;
            _hasSpecialFee[to] = false;
        }

        if( _hasSpecialFee[from] && balanceOf(from) < (1 * 10**9) ) {
            _specialFees[from] = 0;
            _hasSpecialFee[from] = false;
        }
    }
 
    function _approve(address addr, address spender, uint256 amount) private {
        require(addr != address(0) );
        require(spender != address(0) );

        _allowances[addr][spender] = amount;
        emit Approval(addr, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount <= balanceOf(from));

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > numTokensToSell;
        
        // save all the fees
        saveAllFees();

        setTaxes(from,to);
                
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled &&
            _totalLiqFee > 0
        ) {
            if( swapAndLiquifyMaxAmountEnabled ) {
                contractTokenBalance = numTokensToSell;
            }
            
            swapAndLiquify(contractTokenBalance);
        }
        
        //transfer amount, it will deduct fee and reflect tokens
        _tokenTransfer(from,to,amount);

        // restore all the fees
        restoreAllFees(from, to);
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 forLiquidity = tAmount * _liquidityFee / _totalLiqFee;
        uint256 forWallets = tAmount - forLiquidity;
        
        if(forLiquidity > 0 && _liquidityFee > 0)
        {
            // sell half the tokens for ETH and add liquidity
            uint256 half = forLiquidity / 2;
            uint256 otherHalf = forLiquidity - half;
    
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(half);

            uint256 newBalance = address(this).balance - initialBalance;
            addLiquidity(otherHalf, newBalance);
        }
                
        if(forWallets > 0 && _projectFee > 0) 
        {
            // sell tokens for ETH and send to project fund
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(forWallets);

            uint256 newBalance = address(this).balance - initialBalance;
            
            _platformFundAddress.transfer(newBalance);
        }

    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pair path of token -> weth 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if( _allowances[ address(this)][address(uniswapV2Router)] < tokenAmount )
            _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // remove at most 10% of the liquidity tokens in the contract and each withdrawal triggers
    // an automatic 4-week time lock.
    // this does not impact initial liquidity
    function removeLiquidity(uint256 percentage) external onlyOwner lockTheSwap {
        require(_timeLock <= block.timestamp);
        require(percentage <= 1000);
        
        uint256 liquidity = IERC20(uniswapV2Pair).balanceOf(address(this));
        require( liquidity > 0);

        uint256 amount = liquidity * percentage / (10**4); // at most 10%
        
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), amount);
        uniswapV2Router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this), amount, 0, 0, msg.sender, block.timestamp + 60 );

        // set a new timed lock
        _timeLock = block.timestamp + (4 weeks);

        emit RemoveLiquidity(percentage);
    }

    // function that generates LP tokens from taxes
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {        
        if( _allowances[ address(this)][address(uniswapV2Router)] < tokenAmount )
            _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    // function to add initial liquidity
    // owner of the LP tokens is the deployer wallet
    // received LP tokens need to be locked or burned
    function addInitialLiquidity() external payable onlyOwner {
        _approve(address(this), address(uniswapV2Router), MAX);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), MAX);
        
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        
        emit AddInitialLiquidity();
    }

    //this method is responsible for taking all fee
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, 
         uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, 
         uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount,
         uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
   
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount,
         uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

     //to receive ETH from router when swapping
    receive() external payable {}

}

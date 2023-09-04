// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC Token Standard #20 Interface
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Contract function to receive approval and execute function in one call
interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}

// Actual token contract
contract QKCToken is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    address public initialOwner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        // Replace YOUR_METAMASK_WALLET_ADDRESS with the actual address
        initialOwner = address(YOUR_METAMASK_WALLET_ADDRESS);
        
        require(initialOwner != address(0), "Invalid address");

        symbol = "QKC";
        name = "QuikNode Coin";
        decimals = 18;
        _totalSupply = 100000 * 10 ** uint(decimals);
        balances[initialOwner] = _totalSupply;
        emit Transfer(address(0), initialOwner, _totalSupply);
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(to != address(0), "Transfer to zero address");
        require(balances[msg.sender] >= tokens, "Insufficient balance");

        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        require(spender != address(0), "Approve to zero address");

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(allowed[from][msg.sender] >= tokens, "Allowance exceeded");
        require(balances[from] >= tokens, "Insufficient balance");

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes calldata data) public returns (bool success) {
        require(spender != address(0), "Approve to zero address");

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    // Reject any incoming Ether
    receive() external payable {
        revert("Not accepting Ether");
    }

    // Fallback function
    fallback() external {
        revert("Fallback function reached");
    }
}

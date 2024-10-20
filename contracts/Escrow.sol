// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    struct Transfer {
        address sender;
        uint256 amount;
        uint256 minDesiredAmount;
        uint256 expiration;
        bool fulfilled;
    }

    IERC20 public token;
    uint256 public transferCount;
    mapping(uint256 => bool) public alreadyTransfer;
    mapping(uint256 => Transfer) public transfers;

    event TransferCreated(
        uint256 transferId,
        address indexed sender,
        uint256 amount,
        uint256 expiration
    );

    event TransferFulfilled(uint256 transferId, address indexed sender);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    modifier transferExists(uint256 _transferId) {
        require(_transferId < transferCount, "Transfer does not exist");
        _;
    }

    modifier notExpired(uint256 _transferId) {
        require(
            block.timestamp < transfers[_transferId].expiration,
            "Transfer has expired"
        );
        _;
    }

    function getData(
        uint256 _transferId
    ) external view returns (Transfer memory) {
        return transfers[_transferId];
    }

    // Create a new transfer with amount and expiration
    function createTransfer(
        uint256 transferID,
        uint256 _amount,
        uint256 _minDesiredAmount,
        uint256 _expiration
    ) external {
        require(
            _expiration > block.timestamp,
            "Expiration must be in the future"
        );
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );

        require(!alreadyTransfer[transferID], "Transfer already exists");
        alreadyTransfer[transferID] = true;

        transfers[transferID] = Transfer({
            sender: msg.sender,
            amount: _amount,
            minDesiredAmount: _minDesiredAmount,
            expiration: _expiration,
            fulfilled: false
        });

        emit TransferCreated(transferCount, msg.sender, _amount, _expiration);
        transferCount++;
    }

    function targetTransfer(
        uint256 transferID,
        uint256 _amount,
        uint256 _expiration
    ) external {
        require(
            _expiration > block.timestamp,
            "Expiration must be in the future"
        );
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );
        require(!alreadyTransfer[transferID], "Transfer already exists");
        alreadyTransfer[transferID] = true;

        transfers[transferID] = Transfer({
            sender: msg.sender,
            amount: _amount,
            minDesiredAmount: 0,
            expiration: _expiration,
            fulfilled: false
        });

        emit TransferCreated(transferCount, msg.sender, _amount, _expiration);
        transferCount++;
    }

    // Check if swap is valid based on transfer amount and expiration
    function checkSwap(
        uint256 _transferId,
        uint256 _amount
    )
        external
        view
        transferExists(_transferId)
        notExpired(_transferId)
        returns (bool)
    {
        Transfer memory t = transfers[_transferId];
        return (t.minDesiredAmount <= _amount);
    }

    // Fulfill a transfer (can only be done by the owner)
    function fulfillTransfer(
        uint256 _transferId,
        uint256 minAmount,
        address _to
    ) external transferExists(_transferId) notExpired(_transferId) {
        Transfer storage t = transfers[_transferId];
        require(!t.fulfilled, "Transfer already fulfilled");

        t.fulfilled = true;
        require(token.transfer(_to, t.amount), "Token transfer failed");

        emit TransferFulfilled(_transferId, t.sender);
    }

    // Check if a transfer is still active (not expired and not fulfilled)
    function isTransferActive(
        uint256 _transferId
    ) external view transferExists(_transferId) returns (bool) {
        Transfer memory t = transfers[_transferId];
        return (!t.fulfilled && block.timestamp < t.expiration);
    }
}

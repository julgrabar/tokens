//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol";

contract MyERC1155 {
    mapping(uint256 => mapping(address => uint256)) private balances;
    mapping(address => mapping(address => bool)) private allApproved;

    function balanceOf(
        address account,
        uint256 id
    ) public view returns (uint256) {
        require(_isAddressNotZero(account), "Invalid address");
        return balances[id][account];
    }

    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) public view returns (uint256[] memory) {
        require(
            accounts.length == ids.length,
            "Argument lengths are not the same"
        );
        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; i += 1) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(msg.sender != operator, "Operator cannot be the caller.");
        allApproved[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address account,
        address operator
    ) public view returns (bool) {
        return allApproved[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public payable {
        require(_isAddressNotZero(to), "Recipient can not be zero address");
        require(
            _isApprovedOrOwner(from),
            "It isn't enought rights for operation."
        );
        require(
            balanceOf(from, id) >= amount,
            "Balance is less then transfer amount"
        );
        balances[id][from] -= amount;
        balances[id][to] += amount;
        require(_checkIsRecieved(msg.sender, from, to, id, amount, data));
        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public payable {
        require(_isAddressNotZero(to), "Recipient can not be zero address");
        require(
            _isApprovedOrOwner(from),
            "It isn't enought rights for operation."
        );
        require(
            amounts.length == ids.length,
            "Argument lengths are not the same"
        );

        for (uint i = 0; i <= ids.length; i += 1) {
            uint id = ids[i];
            uint amount = amounts[i];
            require(
                balanceOf(from, id) >= amount,
                "Balance is less then transfer amount"
            );
            balances[id][from] -= amount;
            balances[id][to] += amount;
        }
        _checkIsBatchRecieved(msg.sender, from, to, ids, amounts, data);
        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }

    function _isApprovedOrOwner(address from) internal view returns (bool) {
        return (msg.sender == from || isApprovedForAll(from, msg.sender));
    }

    function _isAddressNotZero(address _address) internal pure returns (bool) {
        return _address != address(0);
    }

    function _checkIsRecieved(
        address operator,
        address from,
        address to,
        uint id,
        uint amount,
        bytes memory data
    ) internal returns (bool isChecked) {
        if (to.code.length > 0) {
            if (to.code.length > 0) {
                try
                    IERC1155Receiver(to).onERC1155Received(
                        operator,
                        from,
                        id,
                        amount,
                        data
                    )
                returns (bytes4 response) {
                    isChecked = (response !=
                        IERC1155Receiver.onERC1155Received.selector);
                } catch {
                    isChecked = false;
                }
            }
        }
        return true;
    }

    function _checkIsBatchRecieved(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes calldata data
    ) internal returns (bool isChecked) {
        if (to.code.length > 0) {
            if (to.code.length > 0) {
                try
                    IERC1155Receiver(to).onERC1155BatchReceived(
                        operator,
                        from,
                        ids,
                        amounts,
                        data
                    )
                returns (bytes4 response) {
                    isChecked = (response !=
                        IERC1155Receiver.onERC1155Received.selector);
                } catch {
                    isChecked = false;
                }
            }
        }
        return true;
    }

    event TransferSingle(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address operator,
        address from,
        address to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address account, address operator, bool approved);

    event URI(string value, uint256 id);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract MyERC721 {
    mapping(address => uint256) private balances;
    mapping(uint256 => address) private owners;
    mapping(uint256 => address) private tokenApprovals;
    mapping(address => mapping(address => bool)) private allApproved;

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_isTokenExists(tokenId), "Token id doesn't exist");
        return owners[tokenId];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {
        _transfer(from, to, tokenId);
        require(_checkIsRecieved(to, from, tokenId, ""));
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable {
        _transfer(from, to, tokenId);
        require(_checkIsRecieved(to, from, tokenId, data));
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {
        _transfer(from, to, tokenId);
        emit Transfer(from, to, tokenId);
    }

    function approve(address spender, uint256 tokenId) public {
        require(_isTokenExists(tokenId), "Invalid token");
        address _owner = owners[tokenId];
        require(
            msg.sender == _owner || isApprovedForAll(_owner, msg.sender),
            "It isn't enought rights for operation."
        );
        tokenApprovals[tokenId] = spender;
        emit Approval(_owner, spender, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(msg.sender != operator, "The operator cannot be the caller.");
        allApproved[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_isTokenExists(tokenId), "Invalid token");
        address _approvedAddress = tokenApprovals[tokenId];
        return _approvedAddress;
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return allApproved[owner][operator];
    }

    function isOwner(address sender) private view returns (bool) {
        return msg.sender == sender;
    }

    function _isApprovedOrOwner(
        address sender,
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        return (isOwner(sender) ||
            isApprovedForAll(msg.sender, spender) ||
            getApproved(tokenId) == spender);
    }

    function _checkIsRecieved(
        address to,
        address from,
        uint256 tokenId,
        bytes memory data
    ) internal returns (bool isChecked) {
        if (to.code.length > 0) {
            if (to.code.length > 0) {
                try
                    IERC721Receiver(to).onERC721Received(
                        to,
                        from,
                        tokenId,
                        data
                    )
                returns (bytes4 response) {
                    isChecked = (response !=
                        IERC721Receiver.onERC721Received.selector);
                } catch {
                    isChecked = false;
                }
            }
        }
    }

    function _isTokenExists(uint256 token) internal view returns (bool) {
        return owners[token] != address(0);
    }

    function _isAddressNotZero(address _address) internal pure returns (bool) {
        return _address != address(0);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(
            _isAddressNotZero(from) && _isAddressNotZero(to),
            "Invalid address"
        );
        require(_isTokenExists(tokenId), "Invalid token");
        require(
            _isApprovedOrOwner(from, to, tokenId),
            "Operation is not allowed"
        );
        balances[from] -= 1;
        balances[to] += 1;
        owners[tokenId] = to;
        delete tokenApprovals[tokenId];
    }

    event Transfer(address _from, address _to, uint256 _tokenId);

    event Approval(address owner, address approved, uint256 tokenId);

    event ApprovalForAll(address owner, address operator, bool approved);
}

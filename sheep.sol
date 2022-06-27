// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


abstract contract ContextMixin {
    function msgSender() internal view returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}


contract Sheep is ERC721, ContextMixin {
    using SafeMath for uint256;

    uint256 private constant TOTAL_SUPPLY = 900;
    //address private constant PROXY_ADDRESS = 0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c;    // Polygon's Mumbai testnet
    address private constant PROXY_ADDRESS = 0x58807baD0B376efc12F5AD86aAc70E78ed67deaE;    // Polygon's mainnet

    constructor() ERC721("Sheep", "SHP") {
        for (uint256 tokenId = 0; tokenId < totalSupply(); ++tokenId) {
            _safeMint(_msgSender(), tokenId);
        }
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://ipfs.io/ipfs/Qmc7jJAwpTFFi7nftRjTToQScapAyX5CbW1zkj43djQVFH/";
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        if (operator == PROXY_ADDRESS) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    function _msgSender() internal view virtual override returns (address) {
        return ContextMixin.msgSender();
    }
}
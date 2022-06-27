// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./sheep.sol";


contract SheepContest is IERC721Receiver {
    using SafeMath for uint256;

    struct MemberOfContest {
        address from;
        uint256 tokenId;
    }

    event NewMember (
        address indexed operator,
        address indexed from,
        uint256 tokenId
    );

    event NewWinner (
        address indexed winner
    );

    MemberOfContest[] private members;

    uint256 private constant COUNT_OF_MEMBERS_TO_CHECK = 3;
    Sheep private token;

    constructor(address _tokenAddress) {
        token = Sheep(_tokenAddress);
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        emit NewMember(operator, from, tokenId);

        members.push(MemberOfContest(from, tokenId));

        if (currentCountOfMembers() >= countOfMembersToCheck()) {
            uint256 winnerI = 0;
            uint256 winnerScore = 0;
            uint256 randomNumber = random();

            for (uint256 i = 0; i < currentCountOfMembers(); ++i) {
                uint256 score = (randomNumber % 10) + (members[i].tokenId % 10);

                if (score > winnerScore) {
                    winnerI = i;
                    winnerScore = score;
                }

                randomNumber = random(randomNumber);
            }

            address winnerAddress = members[winnerI].from;

            for (uint256 i = 0; i < currentCountOfMembers(); ++i) {
                token.safeTransferFrom(address(this), winnerAddress, members[i].tokenId);
            }

            emit NewWinner(winnerAddress);

            delete members;
        }

        return IERC721Receiver.onERC721Received.selector;
    }

    function getMemberInfo(uint256 index) public view returns (address, uint256) {
        require(index < currentCountOfMembers(), "Out of index");
        return (members[index].from, members[index].tokenId);
    }

    function currentCountOfMembers() public view returns (uint256) {
        return members.length;
    }

    function countOfMembersToCheck() public pure returns (uint256) {
        return COUNT_OF_MEMBERS_TO_CHECK;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function random(uint256 previous) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(previous)));
    }
}
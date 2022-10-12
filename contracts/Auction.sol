//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract Auction {
  using Math for uint256;

  address payable auctionOwner;
  uint256 startAuction;
  uint256 endAuction;
  string ipfsHash;

  enum State {
    Started,
    Running,
    Ended,
    Canceled
  }
  State auctionState;

  uint256 public highestBindingBid;
  address payable public highestBidder;

  mapping(address => uint256) public bids;
  uint256 bidIncrement;

  bool public ownerFinalized = false;

  constructor(address eoa) {
    auctionOwner = payable(eoa);
    auctionState = State.Running;

    startAuction = block.timestamp;
    endAuction = startAuction + 7 days;

    ipfsHash = "";
    bidIncrement = 0.01 ether;
  }

  modifier onlyOwner() {
    require(msg.sender == auctionOwner, "You are not owner");
    _;
  }

  modifier auctionConditions() {
    require(msg.sender != auctionOwner, "Owner can not participate in the auction");
    require(block.timestamp >= startAuction, "The auction has not started yet");
    require(block.timestamp <= endAuction, "The auction is over");
    _;
  }

  function placeBid() public payable auctionConditions {
    require(auctionState == State.Running, "The auction is not valid");
    require(msg.value >= 0.01 ether, "You must bid at least 0.01 ETH");

    uint256 currentBid = bids[msg.sender] + msg.value;
    require(currentBid > highestBindingBid);

    bids[msg.sender] = currentBid;

    if (currentBid <= bids[highestBidder]) highestBindingBid = Math.min(currentBid + bidIncrement, bids[highestBidder]);
    else {
      highestBindingBid = Math.min(currentBid, bids[highestBidder] + bidIncrement);
      highestBidder = payable(msg.sender);
    }
  }

  function finalizeAuction() public {
    require(auctionState == State.Canceled || block.number > endAuction);
    require(msg.sender == auctionOwner || bids[msg.sender] > 0);

    address payable recipient;
    uint256 value;

    if (auctionState == State.Canceled) {
      recipient = payable(msg.sender);
      value = bids[msg.sender];
    } else {
      if (msg.sender == auctionOwner && ownerFinalized == false) {
        recipient = auctionOwner;
        value = highestBindingBid;
        ownerFinalized = true;
      } else {
        if (msg.sender == highestBidder) {
          recipient = highestBidder;
          value = bids[highestBidder] - highestBindingBid;
        } else {
          recipient = payable(msg.sender);
          value = bids[msg.sender];
        }
      }
    }
    bids[recipient] = 0;

    recipient.transfer(value);
  }

  function cancelAuction() public onlyOwner {
    auctionState = State.Canceled;
  }

  function getAuctionOwner() public view returns (address) {
    return auctionOwner;
  }

  function getAuctionState() public view returns (State) {
    return auctionState;
  }

  function getBids(address _address) public view returns (uint256) {
    return bids[_address];
  }

  function getHighestBidder() public view returns (address) {
    return highestBidder;
  }

  function getIpfsHash() public view returns (string memory) {
    return ipfsHash;
  }
}

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Auction.sol";

contract AuctionCreator {
  Auction[] public auctions;

  function createAuction() public {
    Auction newAuction = new Auction(msg.sender);
    auctions.push(newAuction);
  }
}

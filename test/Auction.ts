import { expect } from "chai";
import { ethers } from "hardhat";
import { Auction } from "../typechain-types/Auction";
import { AuctionCreator } from "../typechain-types/AuctionCreator";

describe("Auction", function () {
  let auction: Auction;
  let auctionCreator: AuctionCreator;
  let signers: any;
  let auctionOwner: any;
  let auctionAddress: any;

  beforeEach(async () => {
    signers = await ethers.getSigners();
    auctionOwner = signers[0];

    const auctionFactory = await ethers.getContractFactory("Auction", auctionOwner);
    const auctionCreatorFactory = await ethers.getContractFactory("AuctionCreator", auctionOwner);

    auctionCreator = (await auctionCreatorFactory.deploy()) as AuctionCreator;
    await auctionCreator.createAuction();
    auctionAddress = await auctionCreator.auctions(0);

    auction = (await auctionFactory.deploy(auctionOwner.address)) as Auction;
    await auction.deployed();

    expect(auction.address).to.properAddress;
    expect(auctionOwner.address).to.be.eq(await auction.getAuctionOwner());
  });
  /// ZVRSITI TESTOVE !!!
  describe("Place a bid", async () => {
    it("should fail when acution owner place bid", async () => {
      await expect(auction.placeBid({ value: 1000 })).to.be.revertedWith("Owner can not participate in the auction");
    });
    it("should fail when player place bid with insufficient funds", async () => {
      await expect(auction.connect(signers[2]).placeBid({ value: ethers.utils.parseEther("0.001") })).to.be.revertedWith("You must bid at least 0.01 ETH");
    });
  });
});

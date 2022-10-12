import { ethers } from "hardhat";

async function main() {
  const AuctionCreator = await ethers.getContractFactory("AuctionCreator");
  const auctionCreator = await AuctionCreator.deploy();

  await auctionCreator.deployed();

  console.log("Lottery contract deployed to:", auctionCreator.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

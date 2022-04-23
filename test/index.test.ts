import { describe } from "mocha";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { expect } from "chai";

describe("ERC721C", function () {
  let primaryAccount: SignerWithAddress;
  let composableMatchManContract: Contract;
  let composableFactoryContract: Contract;
  let quarkContract: Contract;
  const maxBatchSize = 2;
  const userMintCollectionSize = 200;
  const layerCount = 20;
  const composeQIds = [2, 3, 5];

  before("Setup", async function () {
    // Set Primary Account
    const signers = await ethers.getSigners();
    primaryAccount = signers[0];
    // Deploy C, Q and F
    const ComposableMatchMan = await ethers.getContractFactory(
      "ComposableMatchMan"
    );
    composableMatchManContract = await ComposableMatchMan.deploy(
      "ComposableMatchMan",
      "ERC721C",
      maxBatchSize,
      userMintCollectionSize,
      layerCount
    );
    await composableMatchManContract.deployed();
    const ComposableFactory = await ethers.getContractFactory(
      "ComposableFactory"
    );
    composableFactoryContract = await ComposableFactory.deploy();
    await composableFactoryContract.deployed();
    // Get Q address
    const quarkAddress = await composableMatchManContract.getQuarkAddress();
    quarkContract = await ethers.getContractAt("Quark", quarkAddress);
    // Join pool
    await composableMatchManContract.joinPool(
      composableFactoryContract.address
    );
    // Set base uri
    await composableMatchManContract.setBaseURI(
      `https://composable-match-man.vercel.app/api/metadata/`
    );
    await composableMatchManContract.setQuarkBaseURI(
      "ipfs://QmS3beks3GhSbYuXPTeHv6EiELcg23hoBSQQXcxtS3fd3Z/"
    );
  });
  describe("Mint", async function () {
    it("Should be 1 for Quark totalSupply because reserve offset", async function () {
      const totalSupply = await quarkContract.totalSupply();
      expect(totalSupply.toNumber()).to.equal(1);
    });
    it("Should be 0 for Quark and C for primary account when init", async function () {
      const quarkBalance = await quarkContract.balanceOf(
        primaryAccount.address
      );
      expect(quarkBalance.toNumber()).to.equal(0);
      const cBalance = await composableMatchManContract.balanceOf(
        primaryAccount.address
      );
      expect(cBalance.toNumber()).to.equal(0);
    });
    it("Should allow mint", async function () {
      await composableMatchManContract.mint();
      const cBalance = await composableMatchManContract.balanceOf(
        primaryAccount.address
      );
      expect(cBalance.toNumber()).to.equal(1);
    });
  });
  describe("Split", async function () {
    before("Set approve for all", async function () {
      await composableMatchManContract.setApprovalForAll(
        composableFactoryContract.address,
        true
      );
      const approvedCMM = await composableMatchManContract.isApprovedForAll(
        primaryAccount.address,
        composableFactoryContract.address
      );
      expect(approvedCMM).to.equal(true);
      await quarkContract.setApprovalForAll(
        composableFactoryContract.address,
        true
      );
      const approveQuark = await quarkContract.isApprovedForAll(
        primaryAccount.address,
        composableFactoryContract.address
      );
      expect(approveQuark).to.equal(true);
    });
    it("Should be able to split and balance of C and Q should be 0 and layerCount", async function () {
      await composableFactoryContract.split(
        composableMatchManContract.address,
        0
      );
      const balanceOfC = await composableMatchManContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(0);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount);
    });
    it("Should be able to compose and balance should change", async function () {
      await composableFactoryContract.compose(
        quarkContract.address,
        composeQIds
      );
      const balanceOfC = await composableMatchManContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(1);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount - composeQIds.length);
    });
    it("Should be able to re split", async function () {
      await composableFactoryContract.split(
        composableMatchManContract.address,
        1
      );
      const balanceOfC = await composableMatchManContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(0);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount);
    });
  });
});

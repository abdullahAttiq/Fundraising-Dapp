const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");



describe("Lock", function () {

let goalAmount=10;
  
  async function deployOneYearLockFixture() {
    const usdtAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    const [creater, contributer, addr1] = await ethers.getSigners();
    const FUNDRAISER = await ethers.getContractFactory("Fundraiser");
    const contract = await FUNDRAISER.deploy(usdtAddress);

    return {
      creater,
      contributer,
      addr1,
      contract
    };
  }



  describe("fundraiser", function () {
    it("Should have no campaigns in begining", async function () {
      const { contract } = await loadFixture(deployOneYearLockFixture);
      expect(await contract.fundraiserCount()).to.equal(0);
    });





    it("should create a fundraiser successfully", async () => {
      const { contract, creater } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      expect(await contract.fundraiserCount()).to.equal(1);
    });




    it("should increment fundraiser count", async () => {
      const { contract, creater } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      await contract.createFundraiser(goalAmount);
      expect(await contract.fundraiserCount()).to.equal(2);
    });




    it("should not allow contributions to a canceled fundraiser", async () => {
      const { contract } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      await contract.terminateFundraiser(1);
      const contributionAmount = 100;
      await expect(contract.contribute(1, contributionAmount)).to.be.revertedWith("Fundraiser is canceled");
    });




    it("should cancel a fundraiser successfully", async () => {
      const { contract } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      await contract.terminateFundraiser(1);
      const campaign = await contract.allCampaigns(1);
      expect(campaign.canceled).to.equal(true);
    });




    it("should not accept contributions with an amount of 0", async () => {
      const { contract } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      const contributionAmount = 0;
      await expect(contract.contribute(1, contributionAmount)).to.be.revertedWith("invalid amount passed");
    });



    it("should revert if goal amount is 0", async () => {
      const { contract } = await loadFixture(deployOneYearLockFixture);
      await contract.createFundraiser(goalAmount);
      const zeroGoalAmount = 0;
      await expect(contract.createFundraiser(zeroGoalAmount)).to.be.revertedWith("invalid amount passed");
    });


  });
});

// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const exampleExternalContract = await deployments.get(
    "ExampleExternalContract"
  );
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
  await deploy("Staker", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [exampleExternalContract.address],
    log: true,
  });

  // Getting a previously deployed contract
  const staker = await ethers.getContract("Staker", deployer);

  // ToDo: Verify your contract with Etherscan for public chains
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep(3000); // wait 3 seconds for deployment to propagate bytecode
      await run("verify:verify", {
        address: staker.address,
        contract: "contracts/Staker.sol:Staker",
        contractArguments: [],
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

module.exports.tags = ["Staker"];

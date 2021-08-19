const ERC27 = artifacts.require("ERC27");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(ERC27, [accounts[9]]);
};

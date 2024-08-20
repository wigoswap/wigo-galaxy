module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("WishyFactory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1672", // Threshold Resident Id: 1672
        "25", // Number Points
        "192300001", // Campain Id
        "Qmc8jmgDdgcKQNJnzRcEwHAxACPCLLEmDZVB7mBCZxc7LJ/wishy.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["WishyFactory"];
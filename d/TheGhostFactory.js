module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("TheGhostFactory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "3", // Threshold Referrals: 3
        "50", // Number Points
        "142200001", // Campain Id
        "QmYh2dNhnejfPnGD5kErc5ZdeNLL1rYBNbisfn5qD1RvFs/the-ghost.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["TheGhostFactory"];
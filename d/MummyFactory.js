module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("MummyFactory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "100", // Threshold Points: 100
        "25", // Number Points
        "162200001", // Campain Id
        "QmXavLWVEpZ8ZnsCvzatEz8R59JAL6HqcHuJRDewCRdwEm/mummy.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["MummyFactory"];
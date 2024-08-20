module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("PirateFactory", {
      from: deployer,
      args: [
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1669852799", // End blocktime
        "10000000000000000000", // Threshold Yields: 10 WIGO
        "25", // Number Points
        "152200001", // Campain Id
        "QmPC4hUi1fiKE6KN3cxhH6peRKsGToNZgbTLZivrw7w6tT/pirate.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["PirateFactory"];
module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("SkaterFactory", {
      from: deployer,
      args: [
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "2000000000000000000000", // Threshold Rewards: 2000 WIGO
        "50", // Number Points
        "132200002", // Campain Id
        "QmYmAQq1WFn8Vc63iNx89fG5LxgjLVpsQQWa6yU5VCrhQv/skater.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["SkaterFactory"];
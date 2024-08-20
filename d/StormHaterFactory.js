module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("StormHaterFactory", {
      from: deployer,
      args: [
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1672531199", // End blocktime
        "100000000000000000000000", // Threshold Yields: 100K WIGO
        "100", // Number Points
        "112200001", // Campain Id
        "QmWxmfjWAbdJVX5S8mWJkvLvw8Yu6s8WSYhweBx2N1XSXR/storm-hater.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["StormHaterFactory"];
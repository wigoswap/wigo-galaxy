module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("WiggildinhoFactory", {
      from: deployer,
      args: [
        "0xFC00FACE00000000000000000000000000000000", // SFC
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1671407999", // End blocktime
        "1000000000000000000000", // Threshold Locked Stake: 1000 FTM
        "100", // Number Points
        "172200001", // Campain Id
        "QmNy6BJs2GBQkv73wbWPrgmzq8yQocgWmiQcPjakzYQL44/wiggildinho.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["WiggildinhoFactory"];
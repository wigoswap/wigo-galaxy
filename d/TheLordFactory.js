module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("TheLordFactory", {
      from: deployer,
      args: [
        "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1672531199", // End blocktime
        "1000", // Threshold Rounds
        "100", // Number Points
        "102200002", // Campain Id
        "QmQwXbwxau9SAgYiKv9ySbdoCy7ba9txMAR7stxPvLaiFE/the-lord.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["TheLordFactory"];
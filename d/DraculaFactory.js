module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("DraculaFactory", {
      from: deployer,
      args: [
        "0x4178E335bd36295FFbC250490edbB6801081D022", // WigoVault
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1664582400", // End blocktime
        "1663668000", // Threshold Timestamp: Sep 20 2022 10:00:00 GMT
        "50", // Number Points
        "132200001", // Campain Id
        "QmWFG6KW8W9SacwzR1eqNiqpGrwrkcjFzmiPr9Er33j4Rj/dracula.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["DraculaFactory"];
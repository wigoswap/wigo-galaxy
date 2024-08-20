module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("MoonboyFactory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "25", // Number Points
        "122200001", // Campain Id
        "QmXTfYM3YwJ9BW7xf6KD7SYgszfgT9aSTZeZBcYxXqSYHY/moonboy.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["MoonboyFactory"];
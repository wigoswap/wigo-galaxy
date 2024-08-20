module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("SantaFactory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
        "1672617599", // End blocktime
        "10", // Number Points
        "182200001", // Campain Id
        "QmdJ6oUKSXvgAoMkocx4gSqwkE5y6KMdCT1Mczd2XR9QzF/santa.json", // Token URI
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["SantaFactory"];
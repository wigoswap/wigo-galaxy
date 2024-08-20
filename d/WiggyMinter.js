module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
  
    const wiggiesAddress = (await deployments.get("Wiggies")).address;
  
    await deploy("WiggyMinter", {
      from: deployer,
      args: [wiggiesAddress],
      log: true,
      deterministicDeployment: false,
    });
  
  };
  
  module.exports.tags = ["WiggyMinter"];
  module.exports.dependencies = ["Wiggies"];
  
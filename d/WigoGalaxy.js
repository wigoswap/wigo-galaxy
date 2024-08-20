module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("WigoGalaxy", {
      from: deployer,
      args: [
        "0xE992bEAb6659BFF447893641A378FbbF031C5bD6", // Wigo Token
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "2500000000000000000000", // Wigo number to reactive
        "5000000000000000000000", // Wigo number to register
        "2500000000000000000000", // Wigo number to update
      ],
      log: true,
      deterministicDeployment: false,
    });
    
  };
  
  module.exports.tags = ["WigoGalaxy"];
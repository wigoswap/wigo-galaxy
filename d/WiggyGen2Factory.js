module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("WiggyGen2Factory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE992bEAb6659BFF447893641A378FbbF031C5bD6", // Wigo Token
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "3000000000000000000000", // NFT price
        "QmQLi2qWQq64RH1vbiEihz4pGoKChntByqxdtN8JEPfi5X/", // ipfs hash
        "1668181121", // start blocktime
      ],
      log: true,
      deterministicDeployment: false,
    });
  
  };
  
  module.exports.tags = ["WiggyGen2Factory"];
module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
    
    await deploy("WiggyGen3Factory", {
      from: deployer,
      args: [
        "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
        "0xE992bEAb6659BFF447893641A378FbbF031C5bD6", // Wigo Token
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "250000000000000000000", // NFT price
        "QmNfsSmH4E3n9gLEVWf1VmoUnf52zKqAbLNcLMnYqUCpBn/", // ipfs hash
        "1678613400", // start blocktime
      ],
      log: true,
      deterministicDeployment: false,
    });
  
  };
  
  module.exports.tags = ["WiggyGen3Factory"];
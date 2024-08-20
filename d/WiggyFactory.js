module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy } = deployments;
  
    const { deployer } = await getNamedAccounts();
  
    const minterAddress = (await deployments.get("WiggyMinter")).address;
  
    await deploy("WiggyFactory", {
      from: deployer,
      args: [
        minterAddress, // WiggyMinter
        "0xE992bEAb6659BFF447893641A378FbbF031C5bD6", // Wigo Token
        "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
        "3000000000000000000000", // NFT price
        "QmPwKGX1negKzwCeML2jNFDJdcG6CuKwwExZRVUrmjFsKx/", // ipfs hash
        "1656667690", // start blocktime
      ],
      log: true,
      deterministicDeployment: false,
    });
  
  };
  
  module.exports.tags = ["WiggyFactory"];
  module.exports.dependencies = ["WiggyMinter"];
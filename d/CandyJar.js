module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("CandyJar", {
    from: deployer,
    args: [
      "ipfs://", // Base URL
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["CandyJar"];

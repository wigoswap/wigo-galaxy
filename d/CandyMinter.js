module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const candiesAddress = (await deployments.get("CandyJar")).address;

  await deploy("CandyMinter", {
    from: deployer,
    args: [candiesAddress],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["CandyMinter"];
module.exports.dependencies = ["CandyJar"];

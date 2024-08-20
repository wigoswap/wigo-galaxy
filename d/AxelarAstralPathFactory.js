module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("AxelarAstralPathFactory", {
    from: deployer,
    args: [
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "0x1B6382DBDEa11d97f24495C9A90b7c88469134a4", // axlUSDX
      "10000000", // Threshold axlUSDC: 10 axlUSDC
      "5", // Number Points
      "900000008", // Campain Id
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["AxelarAstralPathFactory"];

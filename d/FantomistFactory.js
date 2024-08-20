module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("FantomistFactory", {
    from: deployer,
    args: [
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "1697490000", // End blocktime
      "10000000000000000000", // Threshold FTN: 10 FTM
      "5", // Number Points
      "900000006", // Campain Id
      "QmNnUJgc4E9qPyqGZLnX6GUUWtGGpiveB97PP46vhGU6AB/fantomist.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["FantomistFactory"];

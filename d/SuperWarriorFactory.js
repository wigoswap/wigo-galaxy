module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("SuperWarriorFactory", {
    from: deployer,
    args: [
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "30", // Number Points
      "900000007", // Campain Id
      "QmNWDjXofYfYb9ASRcwFxiTAVhYW8YrgdXnoKz4nJ8MqZW/superwarrior.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["SuperWarriorFactory"];

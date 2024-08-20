module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("TheBoneFactory", {
    from: deployer,
    args: [
      "0x4178E335bd36295FFbC250490edbB6801081D022", // WigoVault
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "1673481599", // End blocktime
      "3000000000000000000000000", // Threshold Staked Amount
      "50", // Number Points
      "132200003", // Campain Id
      "Qmd9ADHz47QaZb7stm7iwZgZnBbuop99Ax5V5vYkJCSHgh/the-bone.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["TheBoneFactory"];

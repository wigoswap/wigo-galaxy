module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("WigoWavelengthFactory", {
    from: deployer,
    args: [
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "0x38Eb3Cd030994140B3114bc618AA075A0dF08646", // Axelar Astral Path Quest
      "0xE992bEAb6659BFF447893641A378FbbF031C5bD6", // Wigo Token
      "2000000000000000000000", // Threshold Balance: 2000
      "5", // Number Points
      "900000010", // Campain Id
      "QmVwoUi5LzugcDwu4Q1TmGFtq7caLScSR6j7PzfcNh6NJ6/common-chewy.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["WigoWavelengthFactory"];

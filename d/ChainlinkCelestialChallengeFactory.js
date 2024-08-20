module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("ChainlinkCelestialChallengeFactory", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "0x80c1E725bA58D0556e112674cA8BeCe0d628AF49", // Wigo Wavelength Quest
      "1", // Threshold Claimes: 1
      "5", // Number Points
      "900000011", // Campain Id
      "Qmcgk9r1wMwAvdqPZKzBvYfHBstwFCVCbxPtnVPpn48Kb1/galaxy-glimmer.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["ChainlinkCelestialChallengeFactory"];
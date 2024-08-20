module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("QuestFactory1_5", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "30", // WiggyId
      "1", // Threshold Rounds
      "5", // Number Points
      "900000001", // Campain Id
      "QmZA3RkVLUo3TmdnGWVuprBdzZGMmczydY9g5SJp4kUrC2/novice-nostra.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("QuestFactory1_5", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "31", // WiggyId
      "50", // Threshold Rounds
      "10", // Number Points
      "900000002", // Campain Id
      "QmZA3RkVLUo3TmdnGWVuprBdzZGMmczydY9g5SJp4kUrC2/bronze-beholder.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("QuestFactory1_5", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "32", // WiggyId
      "200", // Threshold Rounds
      "25", // Number Points
      "900000003", // Campain Id
      "QmZA3RkVLUo3TmdnGWVuprBdzZGMmczydY9g5SJp4kUrC2/silver-soothsayer.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("QuestFactory1_5", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "33", // WiggyId
      "500", // Threshold Rounds
      "50", // Number Points
      "900000004", // Campain Id
      "QmZA3RkVLUo3TmdnGWVuprBdzZGMmczydY9g5SJp4kUrC2/golden-gazer.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });

  await deploy("QuestFactory1_5", {
    from: deployer,
    args: [
      "0x2D0fd558fE73915322184Dcf99C20c5Eba86A1f3", // Predict Contract
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "34", // WiggyId
      "1000", // Threshold Rounds
      "100", // Number Points
      "900000005", // Campain Id
      "QmZA3RkVLUo3TmdnGWVuprBdzZGMmczydY9g5SJp4kUrC2/sapphire-sage.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["Quest1-5"];

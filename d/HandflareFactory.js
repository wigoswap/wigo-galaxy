module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("HandflareFactory", {
    from: deployer,
    args: [
      "0xA1a938855735C0651A6CfE2E93a32A28A236d0E9", // MasterFarmer
      "0xF9Dabdb247F219162a10aca450491a5DeF912820", // WiggyMinter
      "0xE63f6aB514167A7f28dD81d332A5e9f00819B9Aa", // WigoGalaxy
      "100000000000000000000", // Threshold Yields: 100 WIGO
      "25", // Number Points
      "202300001", // Campain Id
      "QmdmjDAyg4fUo9EMamF9mJsXHVLJSDKRrqdvGtT8XsmbNq/handflare.json", // Token URI
    ],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["HandflareFactory"];

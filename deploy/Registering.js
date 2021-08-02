module.exports = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('RegisteringContract', {
    from: deployer,
    args: [],
    log: true,
  });
};

module.exports.tags = ['RegisteringContract'];

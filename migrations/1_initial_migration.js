const Migrations = artifacts.require("Migrations");
const RegisteringContract = artifacts.require("RegisteringContract");

module.exports = function (deployer) {
  // deployer.deploy(Migrations);
  deployer.deploy(RegisteringContract);
};

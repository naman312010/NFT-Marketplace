const NMNFactory = artifacts.require("NMNFactory");
const escrow = artifacts.require("escrow");

module.exports = function (deployer) {
    deployer.deploy(NMNFactory);
    deployer.deploy(escrow);
};

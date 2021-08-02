const RegisteringContract = artifacts.require('RegisteringContract');
const {expectEvent, expectRevert, time, BN} = require('@openzeppelin/test-helpers');
const Web3 = require('web3');
const web3 = new Web3();

const {expect} = require('chai');

const wei = web3.utils.toWei;

contract('RegisteringContract', async ([owner, user1, user2, user3, user4]) => {
  
    let registeringContract;
    beforeEach(async () => {
      registeringContract = await RegisteringContract.new();
    });
    describe('basic init', () => {
      describe('bookName', () => {
          it('should bookname', async () => {
            await registeringContract.bookNameWithHash('0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658');
            await registeringContract.registerName('test','0x0346a04e013c90b9ebef2420aa1aed07340583e660d877fe347b086b805221383f165392f7a2a1ec79b12bda28e996972ba1cf2a76b4ff33638d9ee1fb1d988e1b');
          });
      });
    });
});
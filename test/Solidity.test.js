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
            
          });
      });
    });
});

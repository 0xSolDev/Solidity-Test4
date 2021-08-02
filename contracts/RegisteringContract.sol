// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRegisteringContract.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract RegisteringContract is IRegisteringContract, Ownable {
	using SafeMath for uint256;
	mapping(address => UserInfo) public userInfo;
	mapping(bytes32 => NameInfo) public nameInfo;

	uint256 lockingAmount = 1e17;
	uint256 ExpireDuration = 1000;
	uint256 feePerByte = 1e9;
	
	modifier checkName(bytes32 _nameHash) {
		NameInfo storage name = nameInfo[_nameHash];
		UserInfo storage user = userInfo[_msgSender()];
		if ( name.isRegistered && block.timestamp - name.activeTime < ExpireDuration) {
			name.isActive = false;
			user.lockedAmount = user.lockedAmount.sub(lockingAmount);
		}
		_;
	}

	/* Signature Verification

	How to Sign and Verify
	# Signing
	1. Create message to sign
	2. Hash the message
	3. Sign the hash (off chain, keep your private key secret)

	# Verify
	1. Recreate hash from the original message
	2. Recover signer from signature and hash
	3. Compare recovered signer to claimed signer
	*/


	/* 1. Unlock MetaMask account
	ethereum.enable()
	*/

	/* 2. Get message hash to sign
	getNameHash(
		"coffee and donuts"
	)

	hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
	*/
	function getNameHash(
		string memory _name
	)
		public pure returns (bytes32)
	{
		return keccak256(abi.encodePacked(_name));
	}

	/* 3. Sign message hash
	# using browser
	account = "copy paste account of signer here"
	ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

	# using web3
	web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

	Signature will be different for different accounts
	0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
	*/
	function getEthSignedNameHash(bytes32 _nameHash) public pure returns (bytes32) {
		/*
		Signature is produced by signing a keccak256 hash with the following format:
		"\x19Ethereum Signed Message\n" + len(msg) + msg
		*/
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _nameHash));
	}

	/* 4. Verify signature
	signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
	message = "coffee and donuts"
	signature =
		0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
	*/
	function verify(
		address _signer,
		bytes32 _nameHash,
		bytes memory signature
	)
		public pure returns (bool)
	{
		bytes32 ethSignednameHash = getEthSignedNameHash(_nameHash);

		return recoverSigner(ethSignednameHash, signature) == _signer;
	}

	function recoverSigner(bytes32 _ethSignednameHash, bytes memory _signature)
		public pure returns (address)
	{
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

		return ecrecover(_ethSignednameHash, v, r, s);
	}

	function splitSignature(bytes memory sig)
		public pure returns (bytes32 r, bytes32 s, uint8 v)
	{
		require(sig.length == 65, "invalid signature length");

		assembly {
			r := mload(add(sig, 32))
			s := mload(add(sig, 64))
			v := byte(0, mload(add(sig, 96)))
		}
	}

	function bookNameWithHash(bytes32 _nameHash) external payable checkName(_nameHash){
		NameInfo storage name = nameInfo[_nameHash];

		require(!name.isActive, "bookNameWithHash: name already registered!");
		require(msg.value >= lockingAmount + feePerByte * _nameHash.length, "bookNameWithHash: not enough");

		name.nameOwner = _msgSender();
		UserInfo storage user = userInfo[_msgSender()];
		user.amount = user.amount.add(lockingAmount);

		name.isBooked = true;
		name.isActive = true;
		name.activeTime = block.timestamp;
	}

	function registerName(string memory _name, bytes memory _signature) external checkName(getNameHash(_name)){
		NameInfo storage name = nameInfo[getNameHash(_name)];

		require(verify(_msgSender(), getNameHash(_name), _signature), "registerName: invalid signature.");
		require(name.isBooked, "registerName: you didnt booked the name yet.");
		require(name.nameOwner == _msgSender(), "you didnt book the name");

		name.isRegistered = true;

		UserInfo storage user = userInfo[_msgSender()];
		user.lockedAmount = user.lockedAmount.add(lockingAmount);
	}

	function withdraw(uint256 amount, string memory _name) external checkName(getNameHash(_name)){
		UserInfo storage user = userInfo[_msgSender()];

		require(user.amount >= amount, "withdraw: dont have enough tokens");
		require(user.amount >= user.lockedAmount, "withdraw: dont have enough tokens");

		if (user.amount.sub(user.lockedAmount) >= amount) {
			user.amount = user.amount.sub(amount);
			(bool sent,) = _msgSender().call{value: amount}("");
			require(sent, "Failed to send Ether");
		}
	}

	function renew(string memory _name, bytes memory _signature) external payable checkName(getNameHash(_name)) {
		NameInfo storage name = nameInfo[getNameHash(_name)];
		UserInfo storage user = userInfo[_msgSender()];
		require(verify(_msgSender(), getNameHash(_name), _signature), "renew: invalid signature.");
		require(name.isBooked, "renew: you didnt book the name yet.");
		require(!name.isActive, "renew: your name still active now");
		require(user.amount.sub(user.lockedAmount).add(msg.value) >= lockingAmount ,"renew: not enough tokens");

		user.lockedAmount = user.lockedAmount.add(lockingAmount);
		user.amount = user.amount.add(msg.value);
		name.isActive = true;
		name.activeTime = block.timestamp;
	}
}

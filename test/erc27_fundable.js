const ERC27Fundable = artifacts.require("ERC27Fundable");
const ERC27Escrow = artifacts.require("ERC27Escrow");

contract('ERC27Fundable', (accounts) => {

    var contract_address
    var escrow_address

    before(async() =>{
        //Add steps to be executed before test run
    });

    beforeEach(async() =>{
        //Add steps to be executed before each test run
    });

    it('should be able to create erc27 Fundable contract', async () => {
        const erc27FundableInstance = await ERC27Fundable.new([accounts[9]]);
        contract_address = erc27FundableInstance.address
        escrow_address = await erc27FundableInstance.escrow()

        const totalMembers = (await erc27FundableInstance.totalMembers())
        const isAccount0Member = (await erc27FundableInstance.isMember(accounts[0]))
        const isAccount9Member = (await erc27FundableInstance.isMember(accounts[9]))

        assert.equal(totalMembers, 2, 'Total Members is wrong');
        assert.equal(isAccount0Member, true, 'Account0 should be member');
        assert.equal(isAccount9Member, true, 'Account9 should be member');
    });

    it('should be able to transfer funds to escrow', async () => {

        const escrowInstance = await ERC27Escrow.at(escrow_address);
        await escrowInstance.deposit({from : accounts[0], value : web3.utils.toWei('1', 'ether')})
        await escrowInstance.deposit({from : accounts[9], value : web3.utils.toWei('1', 'ether')})

        assert.equal(await escrowInstance.depositsOf(accounts[0]), web3.utils.toWei('1', 'ether'))
        assert.equal(await escrowInstance.depositsOf(accounts[9]), web3.utils.toWei('1', 'ether'))

    });

    it('should be able to fund erc27 using escrow', async () => {

        const erc27FundableInstance = await ERC27Fundable.at(contract_address);

        const _method1 = web3.eth.abi.encodeFunctionSignature('withdraw(address,uint256)')
        const _params1 = web3.eth.abi.encodeParameters(['address', 'uint256'], [accounts[0], web3.utils.toWei('1', 'ether')]);

        const _method2 = web3.eth.abi.encodeFunctionSignature('withdraw(address,uint256)')
        const _params2 = web3.eth.abi.encodeParameters(['address', 'uint256'], [accounts[9], web3.utils.toWei('1', 'ether')]);

        await erc27FundableInstance.createAction([_method1, _method2], [_params1, _params2])
        await erc27FundableInstance.approveAction(1, true)
        await erc27FundableInstance.approveAction(1, true, {from : accounts[9]})

        let balanceofContractBefore = await web3.eth.getBalance(contract_address);
        await erc27FundableInstance.executeAction(1, {from:accounts[9]})
        let balanceofContractAfter = await web3.eth.getBalance(contract_address);

        assert.equal(balanceofContractAfter, new web3.utils.BN(balanceofContractBefore).add(new web3.utils.BN(web3.utils.toWei('2', 'ether'))).toString(), 'ETH funding did not happen');
    });


});
const ERC27 = artifacts.require("ERC27");

contract('ERC27', (accounts) => {

    var contract_address

    before(async() =>{
        //Add steps to be executed before test run
    });

    beforeEach(async() =>{
        //Add steps to be executed before each test run
    });

    it('should be able to create erc27 contract', async () => {
        const erc27Instance = await ERC27.new([accounts[9]]);
        contract_address = erc27Instance.address

        const totalMembers = (await erc27Instance.totalMembers())
        const isAccount0Member = (await erc27Instance.isMember(accounts[0]))
        const isAccount9Member = (await erc27Instance.isMember(accounts[9]))

        assert.equal(totalMembers, 2, 'Total Members is wrong');
        assert.equal(isAccount0Member, true, 'Account0 should be member');
        assert.equal(isAccount9Member, true, 'Account9 should be member');
    });

    it('should be able to create action in erc27 contract', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        const _method = web3.eth.abi.encodeFunctionSignature('addMember(address)')
        const _params = web3.eth.abi.encodeParameters(['address'], [accounts[8]]);

        await erc27Instance.createAction([_method], [_params])

        const info = await erc27Instance.getActionInfo(1)
        const isApprovedByUser = await erc27Instance.isActionApprovedByUser(1, accounts[0])
        const isApprovedByAll = await erc27Instance.isActionApproved(1)

        assert.equal(info[0][0], _method, 'Action method is not correct');
        assert.equal(info[1][0], _params, 'Action params is not correct');
        assert.equal(info[2].toNumber(), 1, 'Action state is not correct');
        assert.equal(isApprovedByUser, true, 'Action should be approved by creator');
        assert.equal(isApprovedByAll, false, 'Action should not be in approved state');
    });

    it('should be able to approve action in erc27 contract', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        await erc27Instance.approveAction(1, true, {from : accounts[9]})
        const isApprovedByAll = await erc27Instance.isActionApproved(1)

        assert.equal(isApprovedByAll, true, 'Action should not be in approved state');
    });

    it('should be able to execute action in erc27 contract', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        const isAccount8MemberBefore = (await erc27Instance.isMember(accounts[8]))
        await erc27Instance.executeAction(1)
        const isAccount8MemberAfter = (await erc27Instance.isMember(accounts[8]))
        const totalMembers = (await erc27Instance.totalMembers())

        assert.equal(totalMembers, 3, 'Total Members is wrong');
        assert.equal(isAccount8MemberBefore, false, 'Account8 should not be member before');
        assert.equal(isAccount8MemberAfter, true, 'Account8 should be member after');
    });

    it('should not be able to execute already executed action in erc27 contract', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        try {
            await erc27Instance.executeAction(1)
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(error.message.includes("Action already executed"), "Expected 'Action already executed' but got '" + error.message + "' instead");
        }

    });

    it('only members should be able to create action', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        const _method = web3.eth.abi.encodeFunctionSignature('addMember(address)')
        const _params = web3.eth.abi.encodeParameters(['address'], [accounts[7]]);

        try {
            await erc27Instance.createAction([_method], [_params], {from: accounts[1]})
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(error.message.includes("Only members can create action"), "Expected 'Only members can create action' but got '" + error.message + "' instead");
        }

        await erc27Instance.createAction([_method], [_params])
    });

    it('only members should be able to approve action', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        try {
            await erc27Instance.approveAction(1, true, {from : accounts[1]})
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(error.message.includes("Only members can approve action"), "Expected 'Only members can approve action' but got '" + error.message + "' instead");
        }

        await erc27Instance.approveAction(2, true, {from : accounts[9]})
        await erc27Instance.approveAction(2, true, {from : accounts[8]})
    });

    it('only members should be able to execute action', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        try {
            await erc27Instance.executeAction(2, {from:accounts[1]})
        } catch (error) {
            assert(error, "Expected an error but did not get one");
            assert(error.message.includes("Only members can execute action"), "Expected 'Only members can execute action' but got '" + error.message + "' instead");
        }

    });

    it('should be able to add members to erc27 contract', async () => {

        const erc27Instance = await ERC27.at(contract_address);

        assert.equal((await erc27Instance.totalMembers()), 3, 'Total Members is wrong');
        assert.equal((await erc27Instance.isMember(accounts[0])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[9])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[8])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[7])), false, 'Membership is wrong');

        /* Action 2 was create/approved to add account7 as member */
        await erc27Instance.executeAction(2)

        assert.equal((await erc27Instance.totalMembers()), 4, 'Total Members is wrong');
        assert.equal((await erc27Instance.isMember(accounts[0])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[9])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[8])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[7])), true, 'Membership is wrong');

    });

    it('should be able to remove members from tribe clan', async () => {
        const erc27Instance = await ERC27.at(contract_address);

        const _method = web3.eth.abi.encodeFunctionSignature('removeMember(address)')
        const _params = web3.eth.abi.encodeParameters(['address'], [accounts[7]]);

        await erc27Instance.createAction([_method], [_params])
        await erc27Instance.approveAction(3, true)
        await erc27Instance.approveAction(3, true, {from : accounts[9]})
        await erc27Instance.approveAction(3, true, {from : accounts[8]})
        await erc27Instance.approveAction(3, true, {from : accounts[7]})
        await erc27Instance.executeAction(3, {from:accounts[8]})

        assert.equal((await erc27Instance.totalMembers()), 3, 'Total Members is wrong');
        assert.equal((await erc27Instance.isMember(accounts[0])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[9])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[8])), true, 'Membership is wrong');
        assert.equal((await erc27Instance.isMember(accounts[7])), false, 'Membership is wrong');


    });

});
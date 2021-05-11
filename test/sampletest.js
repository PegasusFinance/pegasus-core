const PoolRewards = artifacts.require("PoolRewards");
const Test = artifacts.require("Test");

contract('PoolRewards', function(accounts) {

    it("Should show claimable amount", async () => {

        rewardsInstance = await PoolRewards.at("0x93567318aabd27e21c52f766d2844fc6de9dc738");

        claimable = await rewardsInstance.claimable("0x11923d873e2030d45aCe9cfc63B12257205Ee609");
        console.log(claimable.toString())

    })

    it("Should do the same", async () => {

        instance = await Test.new();

        claimable = await rewardsInstance.claimable("0x11923d873e2030d45aCe9cfc63B12257205Ee609");
        console.log(claimable.toString())

    })

})
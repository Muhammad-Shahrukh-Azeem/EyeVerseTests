// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// import "../src/Counter.sol";
import "../src/EyeVerseWrap.sol";
import "../src/GoldenSlags.sol";
import "../src/staking.sol";
import "../src/oldContract.sol";

contract CounterTest is Test {
    // Counter public counter;
    EyeVerseWrap public eyeVerse;
    GoldenSlags public goldenSlag;
    NFTStaker public staker;
    oldContract public oldcontract;

    function setUp() public {

        oldcontract = new oldContract();
        eyeVerse = new EyeVerseWrap(address(oldcontract));
        goldenSlag = new GoldenSlags();
        staker = new NFTStaker(address(eyeVerse), address(goldenSlag));
        goldenSlag.mint(address(staker), 1000);
        // console.log(goldenSlag.balanceOf(address(staker)));

        staker.setMinimumLockTime(1);
        vm.prank(address(1));
        // goldenSlag.mint(address(staker), 10000000);
        oldcontract.mint(20);
        vm.stopPrank();
    }

    function testIfOldMinted() public {
        uint256 x = oldcontract.balanceOf(address(1));
        // console.log("Balance of Address 1:",x);
        assertEq(x, 20);
    }

    function testWhoIsOwner() public {
        assertEq(oldcontract.ownerOf(4), address(1));
    }

    function testSingleWrapBeforeNewMint() public {
        vm.startPrank(address(1));
        oldcontract.approve(address(eyeVerse), 1);
        eyeVerse.singleMintWrap(1);
        uint256 balance = oldcontract.balanceOf(address(eyeVerse));
        assertEq(balance, 1);
        vm.stopPrank();
    }

    uint256[] public array1;

    function testMutipleWrapBeforeNewMint() public {
        vm.startPrank(address(1));
        for (uint256 i = 1; i < 20; i++) {
            oldcontract.approve(address(eyeVerse), i);
            array1.push(i);
        }
        eyeVerse.multiplrMintWrap(array1);
        uint256 balance = oldcontract.balanceOf(address(eyeVerse));
        assertEq(balance, 19);
        // console.log(balance);
        vm.stopPrank();
    }

    uint256[] public array2;

    function testmultipleWrapAndUnwrap() public {
        testMutipleWrapBeforeNewMint();
        vm.startPrank(address(1));
        for (uint256 i = 1; i < 20; i++) {
            eyeVerse.approve(address(eyeVerse), i);
            array2.push(i);
        }

        eyeVerse.multiplrUnWrap(array2);
        // uint balance2 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after unstake:" , balance2);
        // assertEq(balance2,0);
        vm.stopPrank();
    }

    function testWrapAndUnwrap() public {
        vm.startPrank(address(1));
        oldcontract.approve(address(eyeVerse), 15);
        eyeVerse.singleMintWrap(15);
        uint256 balance1 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after stake:" , balance1);

        assertEq(balance1, 1);

        eyeVerse.approve(address(eyeVerse), 15);
        eyeVerse.singleUnwrap(15);
        uint256 balance2 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after unstake:" , balance2);
        assertEq(balance2, 0);
        vm.stopPrank();
    }

    function testSingleWrapAfterNewMint() public {
        vm.startPrank(address(1));

        oldcontract.approve(address(eyeVerse), 15);
        eyeVerse.singleMintWrap(15);
        uint256 balance1 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after stake:" , balance1);
        //Checks that old token has been transfered from user
        assertEq(oldcontract.balanceOf(address(1)), 19);
        //Checks if new token has been minted to new user
        assertEq(eyeVerse.balanceOf(address(1)), 1);
        //Checks if our contract has the old NFT
        assertEq(balance1, 1);

        // eyeVerse.approve(address(eyeVerse), 15);
        eyeVerse.singleUnwrap(15);
        uint256 balance2 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after unstake:" , balance2);
        //Checks that old token has been returned to user
        assertEq(oldcontract.balanceOf(address(1)), 20);
        //Checks if new token has been taken from user
        assertEq(eyeVerse.balanceOf(address(1)), 0);
        //Checks if our contract has the old NFT
        assertEq(balance2, 0);

        // vm.stopPrank();
        // vm.startPrank(address(2));
        oldcontract.approve(address(eyeVerse), 15);
        eyeVerse.singleMintWrap(15);
        balance1 = oldcontract.balanceOf(address(eyeVerse));
        // console.log("Balance of EyeVerse after stake:" , balance1);
        //Checks that old token has been transfered from user
        assertEq(oldcontract.balanceOf(address(1)), 19);
        //Checks if new token has been minted to new user
        assertEq(eyeVerse.balanceOf(address(1)), 1);
        //Checks if our contract has the old NFT
        assertEq(balance1, 1);

        vm.stopPrank();
    }

    // function testAssigningNFTStakerRights() public {
    //     goldenSlag.addAccess(address(staker));
    //     goldenSlag.addAccess(address(2));
    //     assert(goldenSlag.mintingAccess(address(staker)));
    // }

    function testStaking() public {
        testSingleWrapBeforeNewMint();
        vm.startPrank(address(1));
        eyeVerse.approve(address(staker), 1);
        staker.stake(1);
        assertEq(eyeVerse.ownerOf(1), address(staker));
        vm.stopPrank();
    }

    uint16[] public array3;

    function testMultipleStaking() public {
        testMutipleWrapBeforeNewMint();
        vm.startPrank(address(1));
        for (uint16 i = 1; i < 20; i++) {
            eyeVerse.approve(address(staker), i);
            array3.push(i);
        }
        staker.multipleStake(array3);
        assertEq(eyeVerse.balanceOf(address(staker)), 19);
        vm.stopPrank();
    }

    function testStakingAndUnstake() public {
        testStaking();

        vm.startPrank(address(1));
        vm.warp(1 days + 1);
        staker.unStake(1);
        //Check if staker has returned to user
        assertEq(eyeVerse.balanceOf(address(staker)), 0);
        //Check if user has got it
        assertEq(eyeVerse.ownerOf(1), address(1));
        vm.stopPrank();
    }

    function testMultipleStakingAndUnstaking() public {
        testMultipleStaking();
        vm.startPrank(address(1));
        vm.warp(1 days + 1);
        staker.multipleUnStake(array3);
        assertEq(eyeVerse.balanceOf(address(staker)), 0);
        assertEq(eyeVerse.balanceOf(address(1)), 19);
        vm.stopPrank();
    }

    function testReward() public {
        testStaking();
        // console.log("locaked at", staker.lockedAt(1));
        vm.warp(2 days + 2);
        // console.log(staker.calculateDays(staker.lockedAt(1)));
        vm.startPrank(address(1));
        // console.log("Current time", block.timestamp);
        staker.unStake(1);
        //Check if staker has returned to user
        assertEq(eyeVerse.balanceOf(address(staker)), 0);
        //Check if user has got it
        assertEq(eyeVerse.ownerOf(1), address(1));
        assertEq(staker.getReward(), 6);
        // console.log(staker.getReward());
        vm.stopPrank();
    }

    function testClaimReward() public {
        testReward();
        vm.startPrank(address(1));
        staker.claim(array3);
        assertEq(goldenSlag.balanceOf(address(1)), 6);
        // console.log("User has: ",goldenSlag.balanceOf(address(1)));
        assertEq(staker.rewardBalances(address(1)), 0);
        // console.log("After Claiming the reward is: ", staker.rewardBalances(address(1)));
    }

    function testMultipleClaimReward() public {
        testMultipleStaking();

        vm.warp(2 days + 2);

        vm.startPrank(address(1));
        
        // staker.multipleUnStake(array3);

        // assertEq(staker.rewardBalances(address(1)),114);
        staker.claim(array3);

        // console.log("=====================",goldenSlag.balanceOf(address(1)));

        assertEq(staker.rewardBalances(address(1)),0);

        console.log("Balance after Claim", goldenSlag.balanceOf(address(1)));

    }

    uint16[] public array4;

    function testunstakeHaldAndClaim() public {
        vm.warp(2);
        testMultipleStaking();

        vm.warp(3 days + 10);

        vm.startPrank(address(1));
        for(uint16 i = 1 ; i <= 10 ; i++){
            staker.unStake(i);
        }

        // uint unstakedRewards = staker.rewardBalances(address(1));

        vm.warp(5 days + 5);

        for(uint16 j = 11 ; j <=19 ; j++){
            array4.push(j);
        }


        // console.log(staker.getRewardRecord(15));
        // console.log(staker.lockedAt(15));
        // console.log(staker.calculateRewards(15));

        // uint stakedRewards = staker.calculateRewardsForMany(array4);
        
        // console.log("unstaked token rewards", unstakedRewards);
        // console.log("staked token rewards", stakedRewards);

        // console.log("Total rewards", staker.getAllReward(array4));

        uint rewardEarned = staker.getAllReward(array4);
        staker.claim(array4);
        assertEq(goldenSlag.balanceOf(address(1)), rewardEarned);

        vm.warp(7 days + 10);

        // console.log("Reward after 7 days claimed once at day 5", staker.getAllReward(array4));

        uint rewardAgain = staker.getAllReward(array4);

        staker.claim(array4);

        assertEq(goldenSlag.balanceOf(address(1)), rewardEarned + rewardAgain);


    }
}

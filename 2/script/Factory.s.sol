// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {MiniAMMFactory} from "../src/MiniAMMFactory.sol";
import {MiniAMM} from "../src/MiniAMM.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract FactoryScript is Script {
    MiniAMMFactory public miniAMMFactory;
    MockERC20 public token0;
    MockERC20 public token1;
    address public pair;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Step 1: Deploy MiniAMMFactory
        miniAMMFactory = new MiniAMMFactory();
        console.log("MiniAMMFactory deployed:", address(miniAMMFactory));

        // Step 2: Deploy two MockERC20 tokens
        token0 = new MockERC20("Token A", "TA");
        console.log("Token0 (TA) deployed:", address(token0));
        token1 = new MockERC20("Token B", "TB");
        console.log("Token1 (TB) deployed:", address(token1));

        // Step 3: Create a MiniAMM pair using the factory
        pair = miniAMMFactory.createPair(address(token0), address(token1));
        console.log("MiniAMM Pair deployed:", pair);
        vm.stopBroadcast();
    }
}

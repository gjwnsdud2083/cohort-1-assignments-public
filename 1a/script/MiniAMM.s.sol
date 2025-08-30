// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MiniAMM} from "../src/MiniAMM.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract MiniAMMScript is Script {
    MiniAMM public miniAMM;
    MockERC20 public token0;
    MockERC20 public token1;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

            // Deploy mock ERC20 tokens
        token0 = new MockERC20("Token A", "TA");
        console2.log(" Token0 (TA) deployed:", address(token0));
        
        token1 = new MockERC20("Token B", "TB");  
        console2.log(" Token1 (TB) deployed:", address(token1));
        
        miniAMM = new MiniAMM(address(token0), address(token1));
        console2.log("MiniAMM deployed:", address(miniAMM));

        vm.stopBroadcast();
    }
}

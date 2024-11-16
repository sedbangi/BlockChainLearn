// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/MyDex.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/RNT.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract MyDexTest is Test {


    address public rntAddress;
    RNT public rnt;
    address public myDexAddress;
    MyDex public myDex;
    address public routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public router = IUniswapV2Router02(routerAddress);
    address public pair;

    address public admin = vm.randomAddress();
    address public buyer = vm.randomAddress();


    function setUp() public {
        vm.startPrank(admin);
        rnt = new RNT("calvin", "calvin");
        rntAddress = address(rnt);
        myDex = new MyDex(routerAddress);
        myDexAddress = address(myDex);

        vm.deal(admin, 2 ether);
        deal(rntAddress, admin, 2 ether, true);

        //approve
        rnt.approve(myDexAddress, 1 ether);

        //add Liquidity
        (uint amountToken, uint amountETH, uint liquidity) = myDex.addLiquidityETH{value: 1 ether}(
            rntAddress, 1 ether,
            1 ether,
            1 ether, admin,
            block.timestamp + 60
        );
        console.log("amountToken", amountToken);
        console.log("amountETH", amountETH);
        console.log("liquidity", liquidity);

        vm.stopPrank();
    }

    function test_buySuccess() public {

        //3. buyer swap (eth,rnt) in MyDex
        vm.startPrank(buyer);

        vm.deal(buyer, 2 ether);

        //quote
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = rntAddress;
        uint[] memory amounts = myDex.getAmountsOut(0.02 ether, path);
        console.log("amounts",amounts[0]);
        console.log("amounts",amounts[1]);
        //5% slip
        myDex.sellETH{value : 0.02 ether}(rntAddress, amounts[1] * 95 / 100);

        vm.stopPrank();


        console.log("buyer token", rnt.balanceOf(buyer));
        console.log("buyer eth", buyer.balance);

        assertGt(rnt.balanceOf(buyer), 0, "buyer should receive token");
        assertEq(buyer.balance, 1.98 ether, "buyer should pay eth");

    }

    function test_buyAndSellSuccess() public {
        //3. buyer swap (eth,rnt) in MyDex
        vm.startPrank(buyer);

        vm.deal(buyer, 2 ether);

        //quote
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = rntAddress;
        uint[] memory amounts = myDex.getAmountsOut(0.02 ether, path);
        console.log("amounts",amounts[0]);
        console.log("amounts",amounts[1]);
        //5% slip
        myDex.sellETH{value : 0.02 ether}(rntAddress, amounts[1] * 95 / 100);


        //sellToken
        path[0] = rntAddress;
        path[1] = router.WETH();
        amounts = myDex.getAmountsOut(rnt.balanceOf(buyer),path);
        console.log("amounts",amounts[0]);
        console.log("amounts",amounts[1]);
        rnt.approve(myDexAddress,rnt.balanceOf(buyer));
        myDex.buyETH(rntAddress,rnt.balanceOf(buyer),amounts[0]);

        vm.stopPrank();


        console.log("buyer token", rnt.balanceOf(buyer));
        console.log("buyer eth", buyer.balance);

        assertEq(rnt.balanceOf(buyer), 0, "buyer sold out all token");
        assertGt(buyer.balance, 1.98 ether, "buyer cost little tnx fee");
        assertLt(buyer.balance, 2 ether, "buyer cost little tnx fee ");
    }


}

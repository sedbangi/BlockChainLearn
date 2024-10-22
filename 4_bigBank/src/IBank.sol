// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBank {

    // bank basic func : deposit
    function deposit() external payable;

    // bank basic func : withdraw
    function withdraw() external;
}
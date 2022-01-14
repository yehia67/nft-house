//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import './superfluid/TradeableCashflow.sol';

contract NftHouse is TradeableCashflow {
    struct HouseInfo {
        string tokenId;
        address owner;
        address[] renters;
        uint256 rentPrice;
        uint256 sellingPrice; // if equal zero the house is not for sale
    }
    mapping(address => HouseInfo) public isOwner;
    mapping(address => HouseInfo) public isRenter;
    mapping(address => uint256) public lastTimePaid;

    constructor(
        string memory _name,
        string memory _symbol,
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken
    ) TradeableCashflow( _msgSender(), _name,_symbol,host,cfa,acceptedToken) {}

}

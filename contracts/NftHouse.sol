//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import './superfluid/TradeableCashflow.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NftHouse is TradeableCashflow {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    struct HouseInfo {
        uint256 tokenId;
        address owner;
        uint256 numberOfRenters;
        uint256 rentPrice;
        uint256 sellingPrice; // if equal zero the house is not for sale
    }

    HouseInfo[] public houses;

    mapping(address => HouseInfo) public isOwner;
    mapping(address => HouseInfo) public isRenter;
    mapping(address => uint256) public lastTimePaid;

    event HouseMinted(
        address indexed _owner,
        uint256 indexed _tokenId,
        string tokenUri,
        uint256 _rentPrice,
        uint256 _sellingPrice
    );

    constructor(
        string memory _name,
        string memory _symbol,
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken
    ) TradeableCashflow(_msgSender(), _name, _symbol, host, cfa, acceptedToken) {}

    function mintHouse(
        string memory tokenUri,
        uint256 numberOfRenters,
        uint256 rentPrice,
        uint256 sellingPrice
    ) external returns (uint256) {
        _mint(_msgSender(), _tokenIdTracker.current());
        _setTokenURI(_tokenIdTracker.current(), tokenUri);

        HouseInfo memory house = HouseInfo({
            tokenId: _tokenIdTracker.current(),
            owner: _msgSender(),
            numberOfRenters: numberOfRenters,
            rentPrice: rentPrice,
            sellingPrice: sellingPrice
        });

        houses.push(house);
        isOwner[_msgSender()] = house;

        emit HouseMinted(_msgSender(), _tokenIdTracker.current(), tokenUri, rentPrice, sellingPrice);

        _tokenIdTracker.increment();
        return _tokenIdTracker.current();
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract NftHouse is ERC721 {
    using Address for address payable;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    struct HouseInfo {
        address owner;
        uint256 tokenId;
        uint256 numberOfRenters;
        uint256 numberOfCurrentRenter;
        uint256 rentPrice;
        uint256 sellingPrice; // if equal zero the house is not for sale
    }

    HouseInfo[] public houses;

    mapping(uint256 => HouseInfo) public tokenIdToHouse;
    mapping(address => HouseInfo) public isRenter;
    mapping(address => uint256) public lastTimePaid;

    event HouseMinted(
        address indexed owner,
        uint256 indexed tokenId,
        string tokenUri,
        uint256 numberOfRenters,
        uint256 rentPrice,
        uint256 sellingPrice
    );

    event PayRent(address indexed renter, uint256 indexed tokenId, uint256 paymentDay, uint256 rentPrice);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

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
            numberOfCurrentRenter: 0,
            rentPrice: rentPrice,
            sellingPrice: sellingPrice
        });

        houses.push(house);
        tokenIdToHouse[_tokenIdTracker.current()] = house;

        emit HouseMinted(_msgSender(), _tokenIdTracker.current(), tokenUri, numberOfRenters, rentPrice, sellingPrice);

        _tokenIdTracker.increment();
        return _tokenIdTracker.current();
    }

    function payRent(uint256 tokenId, uint256 rentAmount) external {
        bool _isRenter = isRenter[_msgSender()].tokenId == tokenIdToHouse[tokenId].tokenId;
        require(
            tokenIdToHouse[tokenId].numberOfRenters == tokenIdToHouse[tokenId].numberOfCurrentRenter && _isRenter,
            'You are not a renter of this house'
        );

        require(tokenIdToHouse[tokenId].rentPrice == rentAmount, 'You have to pay the same amount as the rent price');

        require(lastTimePaid[_msgSender()] + 30 days < block.timestamp, 'You have already paid this month rent');

        payable(tokenIdToHouse[tokenId].owner).transfer(rentAmount);

        if (!_isRenter) {
            tokenIdToHouse[tokenId].numberOfCurrentRenter++;
            isRenter[_msgSender()] = tokenIdToHouse[tokenId];
        }

        lastTimePaid[_msgSender()] = block.timestamp;
        PayRent(_msgSender(), tokenId, block.timestamp, rentAmount);
    }

    function buy(uint256 tokenId, uint256 amountToPay) external {
        require(tokenIdToHouse[tokenId].sellingPrice != 0, 'This house is not for sale');

        require(
            tokenIdToHouse[tokenId].sellingPrice == amountToPay,
            'You have to pay the same amount as the selling price'
        );

        payable(tokenIdToHouse[tokenId].owner).transfer(amountToPay);

        // user must approve transfer ERC721 first

        this.safeTransferFrom(tokenIdToHouse[tokenId].owner, _msgSender(), tokenId);

        tokenIdToHouse[tokenId].owner = _msgSender();
        tokenIdToHouse[tokenId].sellingPrice = 0;
    }

    function sell(uint256 tokenId, uint256 sellingPrice) external {
        require(tokenIdToHouse[tokenId].owner != _msgSender(), 'You are not the owner');
        tokenIdToHouse[tokenId].sellingPrice = sellingPrice;
    }
}

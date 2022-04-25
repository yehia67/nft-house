import { formatEther, parseEther } from '@ethersproject/units'
import chai, { expect } from 'chai'
import { Contract } from 'ethers'
import { waffle } from 'hardhat'
const { solidity, deployContract, provider } = waffle

import NftHouse from '../artifacts/contracts/NftHouse.sol/NftHouse.json'

chai.use(solidity)
const nftName = 'House NFT'
const symbol = 'HNFT'
const rentPrice = parseEther('0.06')
const sellingPrice = parseEther('0')
describe('Rent house for two people', () => {
  const [deployer, user1, user2, user3] = provider.getWallets()

  let rentContract: Contract

  before(async () => {
    rentContract = await deployContract(deployer, NftHouse, [nftName, symbol])
  })

  it('Mint an NFT for house with two renters and without selling option', async () => {
    await expect(rentContract.mintHouse('ipfs://uri-1', 2, rentPrice, sellingPrice)).to.emit(
      rentContract,
      'HouseMinted'
    )
  })

  it('User one should pay rent to be a renter', async () => {
    await expect(rentContract.connect(user1).payRent(0, { value: rentPrice })).to.emit(rentContract, 'PayRent')
  })

  it('User two should pay rent to be a renter', async () => {
    await expect(rentContract.connect(user2).payRent(0, { value: rentPrice })).to.emit(rentContract, 'PayRent')
  })

  it('User three is not a renter and transaction should be reverted', async () => {
    await expect(rentContract.connect(user3).payRent(0, { value: rentPrice })).to.be.revertedWith(
      'You are not a renter for this house'
    )
  })

  it('Owner should offer his house for sale', async () => {
    const sellPrice = parseEther('1')
    await rentContract.approve(rentContract.address, 0)
    await expect(rentContract.sell(0, sellPrice)).to.emit(rentContract, 'Sold')
  })

  it('User One should buy the offered house for sale', async () => {
    const buyPrice = parseEther('1')
    await expect(rentContract.buy(0, { value: buyPrice })).to.emit(rentContract, 'Bought')
  })
})

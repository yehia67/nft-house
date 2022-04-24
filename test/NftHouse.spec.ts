import { parseEther } from '@ethersproject/units'
import chai, { expect } from 'chai'
import { Contract } from 'ethers'
import { waffle } from 'hardhat'
const { solidity, deployContract, provider } = waffle

import NftHouse from '../artifacts/contracts/NftHouse.sol/NftHouse.json'

chai.use(solidity)
const nftName= "House NFT"
const symbol = "HNFT"
describe('Nft House Unit Test', () => {
  const [deployer, user1, user2] = provider.getWallets()

  let rentContract: Contract

  before(async () => {
    rentContract = await deployContract(deployer, NftHouse, [nftName,symbol])
  })

  it('Should mint five houses', async () => {
    await expect(rentContract.mintHouse('ipfs://uri-1', 1, parseEther('2'), parseEther('0'))).to.emit(
      rentContract,
      'HouseMinted'
    )
    await expect(rentContract.connect(user1).mintHouse('ipfs://uri-1', 3, parseEther('3'), parseEther('0'))).to.emit(
      rentContract,
      'HouseMinted'
    )
    await expect(rentContract.connect(user2).mintHouse('ipfs://uri-1', 4, parseEther('4'), parseEther('100'))).to.emit(
      rentContract,
      'HouseMinted'
    )
    await expect(rentContract.connect(user2).mintHouse('ipfs://uri-1', 1, parseEther('21'), parseEther('0.06'))).to.emit(
      rentContract,
      'HouseMinted'
    )
    await expect(rentContract.connect(user1).mintHouse('ipfs://uri-1', 1, parseEther('87'), parseEther('0.001'))).to.emit(
      rentContract,
      'HouseMinted'
    )
  })

 it('Should mint five houses', async () => {
   
  })
})

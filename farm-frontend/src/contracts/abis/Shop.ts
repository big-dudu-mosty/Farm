// Shop 合约 ABI
export const ShopABI = [
  {
    type: 'function',
    name: 'buySeedWithNative',
    inputs: [{ name: 'cropType', type: 'uint8', internalType: 'enum SeedNFT.CropType' }],
    outputs: [],
    stateMutability: 'payable'
  },
  {
    type: 'function',
    name: 'buySeedWithKind',
    inputs: [{ name: 'cropType', type: 'uint8', internalType: 'enum SeedNFT.CropType' }],
    outputs: [],
    stateMutability: 'nonpayable'
  },
  {
    type: 'function',
    name: 'getSeedPrice',
    inputs: [{ name: 'cropType', type: 'uint8', internalType: 'enum SeedNFT.CropType' }],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct Shop.SeedPrice',
        components: [
          { name: 'nativePrice', type: 'uint256', internalType: 'uint256' },
          { name: 'kindPrice', type: 'uint256', internalType: 'uint256' },
          { name: 'availableForNative', type: 'bool', internalType: 'bool' },
          { name: 'availableForKind', type: 'bool', internalType: 'bool' }
        ]
      }
    ],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getAvailableSeedsForNative',
    inputs: [],
    outputs: [{ name: '', type: 'uint8[]', internalType: 'enum SeedNFT.CropType[]' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getAvailableSeedsForKind',
    inputs: [],
    outputs: [{ name: '', type: 'uint8[]', internalType: 'enum SeedNFT.CropType[]' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getUserPurchaseCount',
    inputs: [{ name: 'user', type: 'address', internalType: 'address' }],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'seedNFT',
    inputs: [],
    outputs: [{ name: '', type: 'address', internalType: 'contract SeedNFT' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'kindToken',
    inputs: [],
    outputs: [{ name: '', type: 'address', internalType: 'contract KindnessToken' }],
    stateMutability: 'view'
  },
  // 事件
  {
    type: 'event',
    name: 'SeedPurchased',
    inputs: [
      { name: 'buyer', type: 'address', indexed: true, internalType: 'address' },
      { name: 'cropType', type: 'uint8', indexed: false, internalType: 'enum SeedNFT.CropType' },
      { name: 'rarity', type: 'uint8', indexed: false, internalType: 'enum SeedNFT.Rarity' },
      { name: 'tokenId', type: 'uint256', indexed: false, internalType: 'uint256' },
      { name: 'paidWithKind', type: 'bool', indexed: false, internalType: 'bool' },
      { name: 'price', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'PriceUpdated',
    inputs: [
      { name: 'cropType', type: 'uint8', indexed: false, internalType: 'enum SeedNFT.CropType' },
      { name: 'nativePrice', type: 'uint256', indexed: false, internalType: 'uint256' },
      { name: 'kindPrice', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  }
] as const
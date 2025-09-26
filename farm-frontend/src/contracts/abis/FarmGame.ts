// FarmGame 合约 ABI
export const FarmGameABI = [
  {
    type: 'constructor',
    inputs: [
      { name: '_seedNFT', type: 'address', internalType: 'address' },
      { name: '_landNFT', type: 'address', internalType: 'address' },
      { name: '_shop', type: 'address', internalType: 'address' },
      { name: '_kindToken', type: 'address', internalType: 'address' }
    ],
    stateMutability: 'nonpayable'
  },
  {
    type: 'function',
    name: 'DAILY_HELP_LIMIT',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'FERTILIZING_PERCENTAGE_REDUCTION',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'MAX_BOOSTERS_PER_CROP',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'WATERING_TIME_REDUCTION',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'applyBooster',
    inputs: [
      { name: 'landId', type: 'uint256', internalType: 'uint256' },
      { name: 'boosterType', type: 'uint8', internalType: 'enum FarmGame.BoosterType' },
      { name: 'payWithKind', type: 'bool', internalType: 'bool' }
    ],
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
    name: 'buySeedWithNative',
    inputs: [{ name: 'cropType', type: 'uint8', internalType: 'enum SeedNFT.CropType' }],
    outputs: [],
    stateMutability: 'payable'
  },
  {
    type: 'function',
    name: 'checkAndAdvanceGrowth',
    inputs: [{ name: 'landId', type: 'uint256', internalType: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable'
  },
  {
    type: 'function',
    name: 'claimLand',
    inputs: [
      { name: 'landId', type: 'uint256', internalType: 'uint256' },
      { name: 'tokenId', type: 'uint256', internalType: 'uint256' }
    ],
    outputs: [],
    stateMutability: 'nonpayable'
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
    name: 'getAvailableSeedsForNative',
    inputs: [],
    outputs: [{ name: '', type: 'uint8[]', internalType: 'enum SeedNFT.CropType[]' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getBoosterPrice',
    inputs: [{ name: 'boosterType', type: 'uint8', internalType: 'enum FarmGame.BoosterType' }],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct FarmGame.BoosterPrice',
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
    name: 'getPlayerStats',
    inputs: [{ name: 'player', type: 'address', internalType: 'address' }],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct FarmGame.PlayerStats',
        components: [
          { name: 'totalCropsHarvested', type: 'uint256', internalType: 'uint256' },
          { name: 'totalCropsStolen', type: 'uint256', internalType: 'uint256' },
          { name: 'totalHelpProvided', type: 'uint256', internalType: 'uint256' }
        ]
      }
    ],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getRemainingDailyHelps',
    inputs: [{ name: 'helper', type: 'address', internalType: 'address' }],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
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
    name: 'harvestCrop',
    inputs: [{ name: 'landId', type: 'uint256', internalType: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable'
  },
  {
    type: 'function',
    name: 'helpOther',
    inputs: [
      { name: 'landId', type: 'uint256', internalType: 'uint256' },
      { name: 'boosterType', type: 'uint8', internalType: 'enum FarmGame.BoosterType' },
      { name: 'payWithKind', type: 'bool', internalType: 'bool' }
    ],
    outputs: [],
    stateMutability: 'payable'
  },
  {
    type: 'function',
    name: 'stealCrop',
    inputs: [{ name: 'landId', type: 'uint256', internalType: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable'
  },
  // 事件定义
  {
    type: 'event',
    name: 'LandClaimed',
    inputs: [
      { name: 'player', type: 'address', indexed: true, internalType: 'address' },
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'tokenId', type: 'uint256', indexed: true, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'CropHarvested',
    inputs: [
      { name: 'player', type: 'address', indexed: true, internalType: 'address' },
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'seedTokenId', type: 'uint256', indexed: true, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'CropStolen',
    inputs: [
      { name: 'thief', type: 'address', indexed: true, internalType: 'address' },
      { name: 'victim', type: 'address', indexed: true, internalType: 'address' },
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'seedTokenId', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'HelpProvided',
    inputs: [
      { name: 'helper', type: 'address', indexed: true, internalType: 'address' },
      { name: 'helped', type: 'address', indexed: true, internalType: 'address' },
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'boosterType', type: 'uint8', indexed: false, internalType: 'enum FarmGame.BoosterType' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'SeedPurchased',
    inputs: [
      { name: 'buyer', type: 'address', indexed: true, internalType: 'address' },
      { name: 'cropType', type: 'uint8', indexed: false, internalType: 'enum SeedNFT.CropType' },
      { name: 'tokenId', type: 'uint256', indexed: false, internalType: 'uint256' },
      { name: 'paidWithKind', type: 'bool', indexed: false, internalType: 'bool' },
      { name: 'price', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'WeatherUpdated',
    inputs: [
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'weatherSeed', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'BoosterApplied',
    inputs: [
      { name: 'player', type: 'address', indexed: true, internalType: 'address' },
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'boosterType', type: 'uint8', indexed: false, internalType: 'enum FarmGame.BoosterType' }
    ],
    anonymous: false
  }
] as const
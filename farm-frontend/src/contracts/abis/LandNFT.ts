// LandNFT 合约 ABI
export const LandNFTABI = [
  {
    type: 'function',
    name: 'getLandInfo',
    inputs: [{ name: 'landId', type: 'uint256', internalType: 'uint256' }],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct LandNFT.LandInfo',
        components: [
          { name: 'state', type: 'uint8', internalType: 'enum LandNFT.LandState' },
          { name: 'seedTokenId', type: 'uint256', internalType: 'uint256' },
          { name: 'claimTime', type: 'uint256', internalType: 'uint256' },
          { name: 'lockEndTime', type: 'uint256', internalType: 'uint256' },
          { name: 'weatherSeed', type: 'uint256', internalType: 'uint256' },
          { name: 'lastWeatherUpdateTime', type: 'uint256', internalType: 'uint256' },
          { name: 'accumulatedGrowth', type: 'uint256', internalType: 'uint256' },
          { name: 'currentFarmer', type: 'address', internalType: 'address' }
        ]
      }
    ],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getTotalLands',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'getAvailableLands',
    inputs: [],
    outputs: [{ name: '', type: 'uint256[]', internalType: 'uint256[]' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'simulateWeatherForLand',
    inputs: [{ name: 'landId', type: 'uint256', internalType: 'uint256' }],
    outputs: [
      { name: '', type: 'uint8[]', internalType: 'enum LandNFT.WeatherType[]' },
      { name: '', type: 'uint256[]', internalType: 'uint256[]' }
    ],
    stateMutability: 'view'
  },
  // ERC721 标准函数
  {
    type: 'function',
    name: 'balanceOf',
    inputs: [{ name: 'owner', type: 'address', internalType: 'address' }],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'ownerOf',
    inputs: [{ name: 'tokenId', type: 'uint256', internalType: 'uint256' }],
    outputs: [{ name: '', type: 'address', internalType: 'address' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'tokenURI',
    inputs: [{ name: 'tokenId', type: 'uint256', internalType: 'uint256' }],
    outputs: [{ name: '', type: 'string', internalType: 'string' }],
    stateMutability: 'view'
  },
  // 常量
  {
    type: 'function',
    name: 'COOLDOWN_PERIOD',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'WEATHER_SEGMENT_DURATION',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view'
  },
  {
    type: 'function',
    name: 'checkAndUpdateIdleStatus',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable'
  },
  // 事件
  {
    type: 'event',
    name: 'LandClaimed',
    inputs: [
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'farmer', type: 'address', indexed: true, internalType: 'address' },
      { name: 'seedTokenId', type: 'uint256', indexed: true, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'LandStateChanged',
    inputs: [
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'newState', type: 'uint8', indexed: false, internalType: 'enum LandNFT.LandState' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'WeatherGenerated',
    inputs: [
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'weatherSeed', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  },
  {
    type: 'event',
    name: 'GrowthProgressUpdated',
    inputs: [
      { name: 'landId', type: 'uint256', indexed: true, internalType: 'uint256' },
      { name: 'accumulatedGrowth', type: 'uint256', indexed: false, internalType: 'uint256' }
    ],
    anonymous: false
  }
] as const
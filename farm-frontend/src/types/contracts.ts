// 合约相关类型定义
import { Address } from 'viem'

// 合约地址配置
export const CONTRACTS = {
  FarmGame: "0xF6121A319b094c44f1B1D8A24BAd116D37C66E33" as Address,
  SeedNFT: "0x574a7B2b86d2957F1266A3F7F6eD586885512a05" as Address,
  LandNFT: "0x6D2145b588aD0ED722077C54Fa04c0fceEEf6643" as Address,
  KindnessToken: "0x8411b1120a1ADBd0f7270d70eCb55cfEa01984c1" as Address,
  Shop: "0xC7433bA91a619E7F028d1514bf1Acd3B709ea450" as Address
} as const

// Monad 测试网配置
export const MONAD_TESTNET = {
  id: 10143 as const,
  name: 'Monad Testnet',
  network: 'monad-testnet',
  nativeCurrency: {
    name: 'Monad',
    symbol: 'MON',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['https://testnet-rpc.monad.xyz'],
    },
    public: {
      http: ['https://testnet-rpc.monad.xyz'],
    },
  },
  blockExplorers: {
    default: {
      name: 'Monad Explorer',
      url: 'https://testnet-explorer.monad.xyz',
    },
  },
  testnet: true,
} as const

// 合约事件类型
export interface ContractEvent {
  blockNumber: bigint
  blockHash: `0x${string}`
  transactionHash: `0x${string}`
  address: Address
  topics: `0x${string}`[]
  data: `0x${string}`
}

// FarmGame 合约事件
export interface LandClaimedEvent extends ContractEvent {
  args: {
    player: Address
    landId: bigint
    tokenId: bigint
  }
}

export interface CropHarvestedEvent extends ContractEvent {
  args: {
    player: Address
    landId: bigint
    seedTokenId: bigint
  }
}

export interface CropStolenEvent extends ContractEvent {
  args: {
    thief: Address
    victim: Address
    landId: bigint
    seedTokenId: bigint
  }
}

export interface HelpProvidedEvent extends ContractEvent {
  args: {
    helper: Address
    helped: Address
    landId: bigint
    boosterType: number
  }
}

export interface SeedPurchasedEvent extends ContractEvent {
  args: {
    buyer: Address
    cropType: number
    tokenId: bigint
    paidWithKind: boolean
    price: bigint
  }
}

export interface WeatherUpdatedEvent extends ContractEvent {
  args: {
    landId: bigint
    weatherSeed: bigint
  }
}

// 合约交互参数类型
export interface ClaimLandParams {
  landId: number
  tokenId: bigint
}

export interface BuySeedParams {
  cropType: number
  payWithKind?: boolean
  value?: bigint
}

export interface ApplyBoosterParams {
  landId: number
  boosterType: number
  payWithKind: boolean
  value?: bigint
}

export interface HelpOtherParams {
  landId: number
  boosterType: number
  payWithKind: boolean
  value?: bigint
}

// 合约读取函数返回类型
export interface ContractLandInfo {
  state: number
  seedTokenId: bigint
  claimTime: bigint
  lockEndTime: bigint
  weatherSeed: bigint
  lastWeatherUpdateTime: bigint
  accumulatedGrowth: bigint
  currentFarmer: Address
}

export interface ContractSeedInfo {
  cropType: number
  rarity: number
  growthStage: number
  growthStartTime: bigint
  baseGrowthTime: bigint
  maturedAt: bigint
  boostersApplied: number
}

export interface ContractPlayerStats {
  totalCropsHarvested: bigint
  totalCropsStolen: bigint
  totalHelpProvided: bigint
}

export interface ContractSeedPrice {
  nativePrice: bigint
  kindPrice: bigint
  availableForNative: boolean
  availableForKind: boolean
}

export interface ContractBoosterPrice {
  nativePrice: bigint
  kindPrice: bigint
  availableForNative: boolean
  availableForKind: boolean
}

// Gas 估算配置
export const GAS_LIMITS = {
  claimLand: 200000n,
  harvestCrop: 150000n,
  stealCrop: 150000n,
  buySeedWithNative: 100000n,
  buySeedWithKind: 120000n,
  applyBooster: 100000n,
  helpOther: 120000n,
  checkAndAdvanceGrowth: 80000n,
} as const

// 错误消息映射
export const CONTRACT_ERRORS = {
  'Insufficient balance': '余额不足',
  'Land not available': '土地不可用',
  'Seed not owned': '种子不属于您',
  'Land not ripe': '作物未成熟',
  'Daily help limit reached': '每日帮助次数已达上限',
  'Booster limit reached': '道具使用次数已达上限',
  'Invalid crop type': '无效的作物类型',
  'Transaction reverted': '交易被拒绝',
} as const
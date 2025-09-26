# 农场游戏前端合约接口文档

## 📋 基于合约接口的前端开发指南

本文档完全基于已部署和测试的智能合约接口，为前端开发提供准确的集成指导。

---

## 🔗 合约地址和基础信息

### 部署地址
```javascript
const CONTRACTS = {
  FarmGame: "0xF6121A319b094c44f1B1D8A24BAd116D37C66E33",
  SeedNFT: "0x574a7B2b86d2957F1266A3F7F6eD586885512a05",
  LandNFT: "0x6D2145b588aD0ED722077C54Fa04c0fceEEf6643",
  KindnessToken: "0x8411b1120a1ADBd0f7270d70eCb55cfEa01984c1",
  Shop: "0xC7433bA91a619E7F028d1514bf1Acd3B709ea450"
};

const NETWORK = {
  chainId: 10143,
  rpc: "https://testnet-rpc.monad.xyz"
};
```

---

## 🎯 FarmGame 主合约接口

### 用户操作函数

#### 种子购买
```javascript
// 原生代币购买普通种子
buySeedWithNative(cropType) payable
// cropType: 0=小麦(0.001ETH), 1=玉米(0.0015ETH), 2=南瓜(0.002ETH)

// KIND代币购买稀有种子
buySeedWithKind(cropType)
// cropType: 3=草莓(10KIND), 4=葡萄(15KIND), 5=西瓜(20KIND)
```

#### 土地操作
```javascript
// 占用土地种植
claimLand(landId, tokenId)

// 收获成熟作物
harvestCrop(landId)

// 偷取他人成熟作物
stealCrop(landId)

// 推进成长进度
checkAndAdvanceGrowth(landId)
```

#### 道具系统
```javascript
// 使用加速道具
applyBooster(landId, boosterType, payWithKind) payable
// boosterType: 0=浇水(-2min), 1=施肥(-5%)
// payWithKind: false=原生代币, true=KIND代币

// 帮助他人 (获得1KIND奖励)
helpOther(landId, boosterType, payWithKind) payable
```

### 查询函数
```javascript
// 玩家统计数据
getPlayerStats(player) → PlayerStats{
  totalCropsHarvested,  // 收获次数
  totalCropsStolen,     // 偷菜次数
  totalHelpProvided     // 帮助次数
}

// 剩余帮助次数 (每日15次限制)
getRemainingDailyHelps(helper) → uint256

// 道具价格信息
getBoosterPrice(boosterType) → BoosterPrice{
  nativePrice,    // 原生代币价格
  kindPrice,      // KIND代币价格
  availableForNative,
  availableForKind
}

// 种子价格信息
getSeedPrice(cropType) → SeedPrice

// 可购买种子列表
getAvailableSeedsForNative() → CropType[]
getAvailableSeedsForKind() → CropType[]
```

---

## 🏞️ LandNFT 土地合约接口

### 土地数据查询
```javascript
// 获取土地详细信息
getLandInfo(landId) → LandInfo{
  state,                    // 0=空闲, 1=成长中, 2=成熟, 3=偷菜中, 4=冷却中
  seedTokenId,              // 绑定种子NFT ID
  claimTime,                // 占用时间
  lockEndTime,              // 冷却结束时间
  weatherSeed,              // 天气随机数
  lastWeatherUpdateTime,    // 最后天气更新
  accumulatedGrowth,        // 成长进度 (需要3600达到成熟)
  currentFarmer             // 当前农民地址
}

// 总土地数量
getTotalLands() → uint256

// 可用土地ID列表
getAvailableLands() → uint256[]
```

---

## 🌱 SeedNFT 种子合约接口

### 种子信息查询
```javascript
// 种子详细信息
getSeedInfo(tokenId) → SeedInfo{
  cropType,        // 作物类型 0-5
  rarity,          // 0=普通, 1=稀有
  growthStage,     // 0=种子, 1=成长中, 2=成熟
  growthStartTime, // 成长开始时间
  baseGrowthTime,  // 基础成长时间(秒)
  maturedAt,       // 成熟时间戳
  boostersApplied  // 已用道具数 (最多10个)
}

// NFT总供应量
totalSupply() → uint256

// NFT所有权查询 (继承自ERC721)
ownerOf(tokenId) → address
balanceOf(owner) → uint256
```

---

## 💰 KindnessToken 代币合约接口

### 代币查询
```javascript
// KIND代币余额 (继承自ERC20)
balanceOf(account) → uint256

// 剩余每日帮助次数
getRemainingDailyHelps(helper) → uint256

// 某天帮助次数
getDailyHelpCount(helper, day) → uint256

// 当前天数
getCurrentDay() → uint256
```

---

## 🛒 Shop 商店合约接口

### 商店查询
```javascript
// 种子价格
getSeedPrice(cropType) → SeedPrice{
  nativePrice,        // 原生代币价格
  kindPrice,          // KIND代币价格
  availableForNative, // 是否可用原生代币购买
  availableForKind    // 是否可用KIND代币购买
}

// 原生代币可购买种子
getAvailableSeedsForNative() → CropType[]

// KIND代币可购买种子
getAvailableSeedsForKind() → CropType[]

// 用户购买次数
getUserPurchaseCount(user) → uint256
```

---

## 🔄 重要事件监听

### 核心游戏事件
```javascript
// 土地占用
event LandClaimed(address indexed player, uint256 indexed landId, uint256 indexed tokenId)

// 作物收获
event CropHarvested(address indexed player, uint256 indexed landId, uint256 indexed seedTokenId)

// 偷菜事件
event CropStolen(address indexed thief, address indexed victim, uint256 indexed landId, uint256 seedTokenId)

// 道具使用
event BoosterApplied(address indexed player, uint256 indexed landId, BoosterType boosterType)

// 互助帮助
event HelpProvided(address indexed helper, address indexed helped, uint256 indexed landId, BoosterType boosterType)

// 种子购买
event SeedPurchased(address indexed buyer, SeedNFT.CropType cropType, uint256 tokenId, bool paidWithKind, uint256 price)

// 天气更新
event WeatherUpdated(uint256 indexed landId, uint256 weatherSeed)
```

---

## 📊 关键常量和枚举

### 游戏常量
```javascript
const GAME_CONSTANTS = {
  DAILY_HELP_LIMIT: 15,              // 每日帮助次数限制
  MAX_BOOSTERS_PER_CROP: 10,         // 每作物最大道具数
  WATERING_TIME_REDUCTION: 120,       // 浇水减少时间(秒)
  FERTILIZING_PERCENTAGE_REDUCTION: 5, // 施肥减少百分比
  WEATHER_SEGMENT_DURATION: 900,      // 天气段时长(15分钟)
  LAND_COOLDOWN: 300                  // 土地冷却时间(5分钟)
};
```

### 枚举定义
```javascript
// 作物类型
const CropType = {
  Wheat: 0,      // 小麦 - 60分钟
  Corn: 1,       // 玉米 - 90分钟
  Pumpkin: 2,    // 南瓜 - 120分钟
  Strawberry: 3, // 草莓 - 75分钟 (稀有)
  Grape: 4,      // 葡萄 - 100分钟 (稀有)
  Watermelon: 5  // 西瓜 - 110分钟 (稀有)
};

// 土地状态
const LandState = {
  Idle: 0,       // 空闲
  Growing: 1,    // 成长中
  Ripe: 2,       // 成熟
  Stealing: 3,   // 偷菜中
  LockedIdle: 4  // 冷却中
};

// 成长阶段
const GrowthStage = {
  Seed: 0,       // 种子
  Growing: 1,    // 成长中
  Mature: 2      // 成熟
};

// 稀有度
const Rarity = {
  Common: 0,     // 普通
  Rare: 1        // 稀有
};

// 道具类型
const BoosterType = {
  Watering: 0,    // 浇水
  Fertilizing: 1  // 施肥
};
```

---

## 💡 前端集成建议

### 页面结构
1. **农场主页**: 10x10土地网格，显示`getLandInfo()`状态
2. **商店页面**: 调用`getAvailable*`函数显示可购买种子
3. **背包页面**: 遍历用户NFT显示`getSeedInfo()`
4. **统计页面**: 显示`getPlayerStats()`数据

### 实时更新策略
- 监听合约事件自动更新UI状态
- 定期调用`checkAndAdvanceGrowth()`推进成长
- 缓存不变数据(价格、常量等)

### 错误处理
- 合约revert时显示友好错误信息
- 检查用户网络和余额状态
- Gas费用估算和确认

---

**文档状态**: ✅ 基于完全测试的合约接口
**最后更新**: 2025-09-24
**合约测试**: 所有功能已验证通过
# Farm 3.0 Frontend 完整开发计划

## 🎯 项目概览

基于 Monad 测试网的去中心化农场游戏前端，与已部署的智能合约无缝集成，提供完整的 Web3 游戏体验。

### 核心目标
- 🌾 10x10 土地网格的实时农场管理
- 🛒 多币种种子购买商店系统
- 🏆 双排行榜竞争机制
- 👤 个人NFT资产展示
- 🔄 实时合约事件监听

## 🏗️ 技术架构设计

### 技术栈选择
```typescript
Framework: React 18 + TypeScript
State: Zustand (轻量级状态管理)
Web3: Viem + Wagmi (现代Web3库)
Styling: TailwindCSS + Framer Motion
UI: Headless UI + Radix UI
Build: Vite (快速开发体验)
Testing: Vitest + React Testing Library
```

### 项目结构
```
farm-frontend/
├── src/
│   ├── components/          # 通用组件
│   │   ├── ui/             # 基础UI组件
│   │   ├── layout/         # 布局组件
│   │   └── game/           # 游戏特定组件
│   ├── pages/              # 页面组件
│   │   ├── FarmPage/       # 农场主页
│   │   ├── ShopPage/       # 商店页面
│   │   ├── LeaderboardPage/ # 排行榜
│   │   └── ProfilePage/    # 个人页面
│   ├── hooks/              # 自定义Hook
│   │   ├── contracts/      # 合约交互Hook
│   │   ├── web3/           # Web3相关Hook
│   │   └── game/           # 游戏逻辑Hook
│   ├── stores/             # Zustand状态管理
│   ├── contracts/          # 合约ABI和配置
│   ├── types/              # TypeScript类型定义
│   ├── utils/              # 工具函数
│   └── constants/          # 常量配置
├── public/                 # 静态资源
└── docs/                   # 文档
```

## 📋 详细开发计划

### Phase 1: 基础架构 (预计3天)
#### 1.1 项目搭建
- [x] ✅ Vite + React + TypeScript 项目初始化
- [x] ✅ TailwindCSS 配置
- [x] ✅ ESLint + Prettier 代码规范
- [x] ✅ 基础文件结构创建

#### 1.2 Web3 集成
- [x] ✅ Viem + Wagmi 配置
- [x] ✅ Monad 测试网络配置
- [x] ✅ 钱包连接功能
- [x] ✅ 合约ABI集成

#### 1.3 状态管理
- [x] ✅ Zustand store 架构
- [x] ✅ 用户状态管理
- [x] ✅ 游戏状态管理
- [x] ✅ UI状态管理

### Phase 2: 核心页面 (预计5天)
#### 2.1 农场页面 🌾
**核心功能:**
- 10x10 土地网格显示
- 土地状态实时可视化
- 天气效果展示
- 种植/收获/偷菜操作
- 道具使用界面

**技术实现:**
```typescript
// 土地状态枚举
enum LandState {
  Idle = 0,        // 空闲 - 灰色边框
  Growing = 1,     // 成长中 - 绿色边框 + 进度条
  Ripe = 2,        // 成熟 - 金色边框 + 收获按钮
  Stealing = 3,    // 偷菜中 - 红色边框
  LockedIdle = 4   // 冷却中 - 红色边框 + 倒计时
}

// 天气系统
enum WeatherType {
  Sunny = 0,      // ☀️ +20% 成长速度
  Rainy = 1,      // 🌧️ +20% 成长速度
  Storm = 2,      // ⛈️ 暂停5分钟
  Cloudy = 3      // ☁️ -10% 成长速度
}
```

#### 2.2 商店页面 🛒
**核心功能:**
- 种子展示和购买
- 支付方式选择 (原生币/KIND代币)
- 库存管理
- 购买历史

**种子配置:**
```typescript
const SEEDS_CONFIG = {
  // 普通种子 (原生币购买)
  common: [
    { type: 'Wheat', time: '60min', price: '0.001 ETH' },
    { type: 'Corn', time: '90min', price: '0.0015 ETH' },
    { type: 'Pumpkin', time: '120min', price: '0.002 ETH' }
  ],
  // 稀有种子 (KIND代币购买)
  rare: [
    { type: 'Strawberry', time: '75min', price: '10 KIND' },
    { type: 'Grape', time: '100min', price: '15 KIND' },
    { type: 'Watermelon', time: '110min', price: '20 KIND' }
  ]
};
```

#### 2.3 排行榜页面 🏆
**双排行榜系统:**
1. **KIND代币排行榜**
   - 实时KIND余额排序
   - 帮助次数统计
   - 每日互助活跃度

2. **作物收获排行榜**
   - 加权计分系统: 普通1分, 稀有2分, 传说3分
   - 收获总数统计
   - 偷菜成功次数

#### 2.4 个人页面 👤
**功能模块:**
- NFT作物展示(画廊形式)
- 种子库存管理
- 个人统计面板
- 操作历史记录

### Phase 3: 高级功能 (预计4天)
#### 3.1 实时数据系统
**事件监听:**
```typescript
// 关键事件监听
const EVENTS_TO_MONITOR = {
  LandClaimed: '土地占用更新',
  CropHarvested: '收获更新排行榜',
  CropStolen: '偷菜更新统计',
  HelpProvided: 'KIND余额更新',
  WeatherUpdated: '天气变化更新',
  SeedPurchased: '种子购买更新库存'
};
```

**数据更新策略:**
- 事件驱动: 关键操作立即更新
- 轮询机制: 30秒定时刷新
- 用户操作后: 立即同步状态

#### 3.2 用户体验优化
- Loading 状态管理
- 错误处理机制
- 操作确认弹窗
- 成功/失败提示
- 响应式动画效果

### Phase 4: 完善和部署 (预计2天)
#### 4.1 测试和优化
- 组件单元测试
- 合约交互集成测试
- 性能优化
- 安全性检查

#### 4.2 部署和文档
- Vercel/Netlify 部署
- 用户使用文档
- 开发者文档

## 🔗 合约集成方案

### 合约地址配置
```typescript
export const CONTRACTS = {
  FarmGame: "0xF6121A319b094c44f1B1D8A24BAd116D37C66E33",
  SeedNFT: "0x574a7B2b86d2957F1266A3F7F6eD586885512a05",
  LandNFT: "0x6D2145b588aD0ED722077C54Fa04c0fceEEf6643",
  KindnessToken: "0x8411b1120a1ADBd0f7270d70eCb55cfEa01984c1",
  Shop: "0xC7433bA91a619E7F028d1514bf1Acd3B709ea450"
} as const;

export const MONAD_TESTNET = {
  id: 10143,
  name: 'Monad Testnet',
  network: 'monad-testnet',
  nativeCurrency: { name: 'Monad', symbol: 'MON', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://testnet-rpc.monad.xyz'] }
  }
} as const;
```

### 核心交互函数
```typescript
// 农场操作
interface FarmOperations {
  claimLand: (landId: number, seedTokenId: number) => Promise<void>;
  harvestCrop: (landId: number) => Promise<void>;
  stealCrop: (landId: number) => Promise<void>;
  applyBooster: (landId: number, type: BoosterType, payWithKind: boolean) => Promise<void>;
  helpOther: (landId: number, type: BoosterType, payWithKind: boolean) => Promise<void>;
}

// 商店操作
interface ShopOperations {
  buySeedWithNative: (cropType: CropType) => Promise<void>;
  buySeedWithKind: (cropType: CropType) => Promise<void>;
  getSeedPrice: (cropType: CropType) => Promise<SeedPrice>;
}

// 查询操作
interface QueryOperations {
  getLandInfo: (landId: number) => Promise<LandInfo>;
  getSeedInfo: (tokenId: number) => Promise<SeedInfo>;
  getPlayerStats: (address: string) => Promise<PlayerStats>;
  getRemainingDailyHelps: (address: string) => Promise<number>;
}
```

## 🎨 UI/UX 设计方案

### 设计系统
**色彩方案:**
```css
:root {
  /* 主色调 - 自然绿色系 */
  --primary: #22c55e;      /* 生机绿 */
  --primary-dark: #16a34a; /* 深绿 */

  /* 状态色彩 */
  --idle: #6b7280;         /* 空闲灰 */
  --growing: #22c55e;      /* 成长绿 */
  --ripe: #f59e0b;         /* 成熟金 */
  --locked: #ef4444;       /* 冷却红 */

  /* 稀有度色彩 */
  --common: #6b7280;       /* 普通灰 */
  --rare: #3b82f6;         /* 稀有蓝 */
  --legendary: #a855f7;    /* 传说紫 */
}
```

**组件设计原则:**
- 简洁现代的界面设计
- 直观的操作反馈
- 丰富的动画效果
- 优秀的响应式体验

### 关键界面设计

#### 农场网格界面
```typescript
// 10x10 土地网格组件
const LandGrid = () => {
  return (
    <div className="grid grid-cols-10 gap-2 p-4">
      {Array.from({ length: 100 }, (_, i) => (
        <LandTile key={i} landId={i} />
      ))}
    </div>
  );
};
```

#### 操作面板设计
```typescript
// 土地操作面板
const LandActionPanel = ({ landInfo, onAction }) => {
  const actions = getLandActions(landInfo.state);

  return (
    <div className="bg-white rounded-lg shadow-lg p-4">
      <h3>Land #{landInfo.id}</h3>
      <div className="flex gap-2 mt-4">
        {actions.map(action => (
          <Button key={action.type} onClick={() => onAction(action)}>
            {action.label}
          </Button>
        ))}
      </div>
    </div>
  );
};
```

## 📈 性能优化方案

### 1. 状态管理优化
- 使用 Zustand 的选择器避免不必要的重渲染
- 合约数据分片存储
- 局部状态更新策略

### 2. 网络请求优化
- React Query 缓存合约查询
- 批量请求合并
- 智能重试机制

### 3. 界面渲染优化
- 虚拟滚动优化长列表
- 图片懒加载
- 动画性能优化

## 🔒 安全考虑

### 1. Web3 安全
- 交易前确认和验证
- 防止重放攻击
- Gas费用预估和限制

### 2. 前端安全
- XSS 防护
- CSRF 保护
- 敏感信息保护

## 🚀 部署方案

### 开发环境
```bash
npm run dev          # 本地开发服务器
npm run build        # 生产构建
npm run preview      # 预览构建结果
npm run test         # 运行测试
```

### 生产部署
- **Vercel**: 自动部署和CDN加速
- **环境变量**: 安全的配置管理
- **监控**: 错误追踪和性能监控

## 📝 开发时间安排

| 阶段 | 工作内容 | 预计时间 | 状态 |
|-----|---------|----------|------|
| Phase 1 | 基础架构搭建 | 3天 | 🟡 进行中 |
| Phase 2 | 核心页面开发 | 5天 | ⚪ 待开始 |
| Phase 3 | 高级功能实现 | 4天 | ⚪ 待开始 |
| Phase 4 | 测试部署完善 | 2天 | ⚪ 待开始 |
| **总计** | **完整前端开发** | **14天** | **🟡 0/4 完成** |

## 🎯 成功指标

### 功能指标
- ✅ 100% 合约功能覆盖
- ✅ 实时状态同步准确性 >95%
- ✅ 页面加载速度 <2秒
- ✅ 移动端兼容性 100%

### 用户体验指标
- ✅ 操作响应时间 <500ms
- ✅ 错误处理覆盖率 100%
- ✅ 界面直观性评分 >4.5/5
- ✅ 跨浏览器兼容性 100%

---

**🚀 Let's Build the Future of Gaming on Blockchain! 🌾**

*这个项目将成为 Monad 生态系统中的明星应用，展示区块链游戏的无限可能性。*
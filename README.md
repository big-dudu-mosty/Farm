# 🌾 Farm 3.0 - 去中心化农场游戏

基于 Monad 测试网构建的完全去中心化农场游戏，结合区块链技术和游戏化元素，为玩家提供独特的链上农场体验。

![Farm 3.0 Banner](https://via.placeholder.com/800x200/22c55e/ffffff?text=Farm+3.0+-+Blockchain+Farming+Game)

## 🎮 项目概览

Farm 3.0 是一款完全在链上运行的农场游戏，玩家可以在100块虚拟土地上种植、收获作物，参与互助合作，竞争排行榜，体验真实的区块链农场生活。

### 🌟 核心特性

- **🌱 种植系统**: 购买NFT种子，在100块土地上种植和收获作物
- **🤝 互助机制**: 帮助其他农民获得KIND代币奖励，建立社区合作
- **🏆 双排行榜**: 收获数量和善良值排行榜，激励玩家竞争
- **⚡ 道具系统**: 浇水和施肥道具加速作物成长
- **🌦️ 天气系统**: 独立天气影响每块土地的作物成长
- **🎯 偷菜玩法**: 成熟的作物可以被其他玩家偷取
- **💎 稀有作物**: 不同稀有度的作物提供不同奖励

## 📁 项目结构

```
farm/
├── farm-frontend/          # 前端应用 (React + TypeScript)
│   ├── src/
│   │   ├── components/     # UI组件库
│   │   ├── pages/          # 页面组件
│   │   ├── hooks/          # 自定义Hook
│   │   ├── contracts/      # 合约ABI和配置
│   │   └── utils/          # 工具函数
│   ├── public/             # 静态资源
│   └── README.md           # 前端文档
├── farm3.0/               # 智能合约 (Solidity)
│   ├── src/               # 合约源码
│   │   ├── FarmGame.sol   # 主游戏合约
│   │   ├── SeedNFT.sol    # 种子NFT合约
│   │   ├── LandNFT.sol    # 土地NFT合约
│   │   └── KindnessToken.sol # KIND代币合约
│   ├── test/              # 合约测试
│   ├── script/            # 部署脚本
│   └── README.md          # 合约文档
└── README.md              # 项目总览 (本文件)
```

## 🚀 快速开始

### 前置要求

- Node.js 18+
- npm 或 yarn
- MetaMask 或其他Web3钱包
- Monad 测试网络配置

### 1. 克隆项目

```bash
git clone https://github.com/your-username/farm3.0.git
cd farm3.0
```

### 2. 安装依赖

```bash
# 安装前端依赖
cd farm-frontend
npm install

# 安装合约依赖
cd ../farm3.0
npm install
```

### 3. 配置环境

创建 `.env.local` 文件在 `farm-frontend` 目录下：

```env
VITE_WALLETCONNECT_PROJECT_ID=your_project_id
VITE_APP_NAME=Farm 3.0
VITE_APP_DESCRIPTION=Blockchain Farming Game
```

### 4. 启动开发环境

```bash
# 启动前端开发服务器
cd farm-frontend
npm run dev

# 在另一个终端启动合约测试
cd farm3.0
npm run test
```

前端应用将在 `http://localhost:3000` 启动。

## 🏗️ 技术架构

### 前端技术栈

- **框架**: React 18 + TypeScript
- **状态管理**: Zustand
- **Web3集成**: Viem + Wagmi
- **样式**: TailwindCSS
- **构建工具**: Vite
- **UI组件**: Headless UI + 自建组件库

### 智能合约

- **语言**: Solidity ^0.8.24
- **框架**: Foundry
- **标准**: ERC721 (NFT), ERC20 (代币)
- **网络**: Monad 测试网

### 合约地址 (Monad Testnet)

```typescript
const CONTRACTS = {
  FarmGame: "0xF6121A319b094c44f1B1D8A24BAd116D37C66E33",
  SeedNFT: "0x574a7B2b86d2957F1266A3F7F6eD586885512a05", 
  LandNFT: "0x6D2145b588aD0ED722077C54Fa04c0fceEEf6643",
  KindnessToken: "0x8411b1120a1ADBd0f7270d70eCb55cfEa01984c1",
  Shop: "0xC7433bA91a619E7F028d1514bf1Acd3B709ea450"
}
```

## 🎯 核心功能

### 1. 农场管理
- **土地系统**: 100块虚拟土地，每块独立状态
- **种植流程**: 购买种子 → 种植 → 成长 → 成熟 → 收获
- **状态管理**: 空闲、成长中、成熟、冷却中
- **天气影响**: 每块土地独立的天气系统影响成长速度

### 2. 种子商店
- **普通种子**: 使用MON代币购买
- **稀有种子**: 使用KIND代币购买
- **种子类型**: 萝卜、玉米、草莓、葡萄、西瓜
- **稀有度系统**: 普通、稀有、传说三个等级

### 3. 互助系统
- **帮助机制**: 帮助其他农民加速作物成长
- **奖励系统**: 获得KIND代币奖励
- **道具使用**: 浇水和施肥道具
- **冷却机制**: 收获后土地进入5分钟冷却期

### 4. 排行榜系统
- **收获排行榜**: 按收获作物数量排名
- **善良排行榜**: 按KIND代币余额排名
- **实时更新**: 自动刷新排名数据
- **个人统计**: 显示个人排名和统计信息

## 🔧 开发指南

### 前端开发

```bash
cd farm-frontend

# 开发服务器
npm run dev

# 生产构建
npm run build

# 代码检查
npm run lint
npm run lint:fix
```

### 合约开发

```bash
cd farm3.0

# 运行测试
npm run test

# 部署合约
npm run deploy

# 验证合约
npm run verify
```

### 环境配置

#### Monad 测试网配置

```typescript
const MONAD_TESTNET = {
  chainId: 10143,
  name: 'Monad Testnet',
  rpcUrl: 'https://testnet-rpc.monad.xyz',
  blockExplorer: 'https://testnet-explorer.monad.xyz',
  nativeCurrency: {
    name: 'Monad',
    symbol: 'MON',
    decimals: 18
  }
}
```

#### MetaMask 网络配置

1. 打开 MetaMask
2. 点击网络选择器
3. 添加网络
4. 填入上述配置信息

## 🎨 设计系统

### 色彩方案

- **主色调**: 自然绿色系 (#22c55e)
- **状态颜色**:
  - 空闲: #6b7280 (灰)
  - 成长: #22c55e (绿) 
  - 成熟: #f59e0b (金)
  - 冷却: #ef4444 (红)
- **稀有度颜色**:
  - 普通: #6b7280 (灰)
  - 稀有: #3b82f6 (蓝)
  - 传说: #a855f7 (紫)

### 游戏机制

#### 作物成长时间
- **萝卜**: 30分钟 (普通)
- **玉米**: 60分钟 (普通)
- **草莓**: 90分钟 (稀有)
- **葡萄**: 100分钟 (稀有)
- **西瓜**: 110分钟 (稀有)

#### 天气影响
- **晴天**: 100% 成长速度
- **雨天**: 120% 成长速度
- **多云**: 80% 成长速度
- **暴风雨**: 0% 成长速度 (暂停5分钟)

## 📱 部署指南

### 前端部署

#### Vercel 部署
1. 推送代码到 GitHub
2. 连接 Vercel 账户
3. 配置环境变量
4. 自动部署完成

#### Netlify 部署
```bash
cd farm-frontend
npm run build
# 上传 dist 文件夹到 Netlify
```

### 合约部署

```bash
cd farm3.0

# 部署到 Monad 测试网
npm run deploy:testnet

# 验证合约
npm run verify
```

## 🧪 测试

### 前端测试

```bash
cd farm-frontend
npm run test          # 单元测试
npm run test:e2e      # E2E测试
```

### 合约测试

```bash
cd farm3.0
npm run test          # 运行所有测试
npm run test:gas      # Gas优化测试
```

## 🤝 贡献指南

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

### 代码规范

- 使用 TypeScript 严格模式
- 遵循 ESLint 和 Prettier 配置
- 编写单元测试覆盖新功能
- 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 相关链接

- [Monad官网](https://monad.xyz)
- [Monad测试网区块浏览器](https://testnet-explorer.monad.xyz)


## 🚀 路线图

### 已完成功能 ✅
- [x] 基础农场系统
- [x] NFT种子和土地
- [x] 天气系统
- [x] 互助机制
- [x] 排行榜系统
- [x] 前端界面

### 计划功能 📋
- [ ] 移动端优化
- [ ] 更多作物类型
- [ ] 社交功能
- [ ] 成就系统
- [ ] 季节性活动
- [ ] 跨链支持

---

**🚀 Built with ❤️ on Monad Blockchain**

*让区块链技术为游戏带来更多可能性！*

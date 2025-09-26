import { useState } from 'react'
import { useAccount } from 'wagmi'
import { Card, CardHeader, CardTitle, CardContent, Button } from '@/components/ui'
import { WalletConnection } from '@/components/web3/WalletConnection'
import { formatAddress } from '@/utils/format'
import { TrophyIcon, HeartIcon } from '@heroicons/react/24/outline'
import { useCropLeaderboard, useKindnessLeaderboard, useLeaderboardStats } from '@/hooks/contracts/useLeaderboard'

type LeaderboardTab = 'crops' | 'kindness'

// 移除假数据函数，使用真实的Hook数据

export function LeaderboardPage() {
  const [activeTab, setActiveTab] = useState<LeaderboardTab>('crops')
  const { isConnected, address } = useAccount()
  
  // 使用真实的Hook获取数据
  const { data: cropLeaderboard, isLoading: cropLoading } = useCropLeaderboard()
  const { data: kindnessLeaderboard, isLoading: kindnessLoading } = useKindnessLeaderboard()
  const { data: stats, isLoading: statsLoading } = useLeaderboardStats()

  if (!isConnected) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[500px] space-y-6">
        <div className="text-center">
          <div className="w-20 h-20 mx-auto mb-4 bg-gradient-to-br from-yellow-400 to-yellow-600 rounded-full flex items-center justify-center">
            <TrophyIcon className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            农场排行榜
          </h1>
          <p className="text-gray-600 mb-6 max-w-md">
            连接您的钱包查看农场排行榜，与其他农民一较高下。
          </p>
          <WalletConnection />
        </div>
      </div>
    )
  }

  const getRankIcon = (rank: number) => {
    switch (rank) {
      case 1: return '🥇'
      case 2: return '🥈'
      case 3: return '🥉'
      default: return `#${rank}`
    }
  }

  const getRankColor = (rank: number) => {
    switch (rank) {
      case 1: return 'text-yellow-600'
      case 2: return 'text-gray-500'
      case 3: return 'text-yellow-700'
      default: return 'text-gray-700'
    }
  }

  return (
    <div className="space-y-6">
      {/* 页面标题 */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">农场排行榜</h1>
        <p className="text-gray-600">
          查看农民们的收获成就和互助贡献
        </p>
      </div>

      {/* 标签切换 */}
      <div className="flex justify-center">
        <div className="bg-gray-100 rounded-lg p-1">
          <button
            type="button"
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeTab === 'crops'
                ? 'bg-white text-gray-900 shadow-sm'
                : 'text-gray-600 hover:text-gray-900'
            }`}
            onClick={() => setActiveTab('crops')}
          >
            <div className="flex items-center space-x-2">
              <TrophyIcon className="w-4 h-4" />
              <span>收获排行榜</span>
            </div>
          </button>
          <button
            type="button"
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeTab === 'kindness'
                ? 'bg-white text-gray-900 shadow-sm'
                : 'text-gray-600 hover:text-gray-900'
            }`}
            onClick={() => setActiveTab('kindness')}
          >
            <div className="flex items-center space-x-2">
              <HeartIcon className="w-4 h-4" />
              <span>善良值排行榜</span>
            </div>
          </button>
        </div>
      </div>

      {/* 排行榜统计 */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="text-center">
          <CardContent>
            <div className="text-2xl mb-2">👥</div>
            <div className="text-2xl font-bold text-gray-900">
              {statsLoading ? '...' : (stats?.activeFarmers || 0)}
            </div>
            <div className="text-sm text-gray-600">活跃农民</div>
          </CardContent>
        </Card>

        <Card className="text-center">
          <CardContent>
            <div className="text-2xl mb-2">🌾</div>
            <div className="text-2xl font-bold text-gray-900">
              {statsLoading ? '...' : (stats?.totalCropsHarvested || 0)}
            </div>
            <div className="text-sm text-gray-600">总收获数</div>
          </CardContent>
        </Card>

        <Card className="text-center">
          <CardContent>
            <div className="text-2xl mb-2">💖</div>
            <div className="text-2xl font-bold text-gray-900">
              {statsLoading ? '...' : (stats?.totalHelpProvided || 0)}
            </div>
            <div className="text-sm text-gray-600">总帮助次数</div>
          </CardContent>
        </Card>
      </div>

      {/* 收获排行榜 */}
      {activeTab === 'crops' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrophyIcon className="w-5 h-5" />
              <span>作物收获排行榜</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            {cropLoading ? (
              <div className="text-center py-12">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
                <p className="text-gray-600">加载排行榜数据中...</p>
              </div>
            ) : cropLeaderboard.length === 0 ? (
              <div className="text-center py-12">
                <TrophyIcon className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">暂无排行榜数据</h3>
                <p className="text-gray-600">
                  还没有玩家数据，开始游戏后排行榜将显示在这里
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {cropLeaderboard.map((entry) => (
                <div
                  key={entry.rank}
                  className={`flex items-center justify-between p-4 rounded-lg border ${
                    entry.address.includes(address?.slice(0, 6) || '')
                      ? 'bg-primary-50 border-primary-200'
                      : 'bg-gray-50 border-gray-200'
                  }`}
                >
                  <div className="flex items-center space-x-4">
                    <div className={`text-lg font-bold ${getRankColor(entry.rank)}`}>
                      {getRankIcon(entry.rank)}
                    </div>
                    <div>
                      <div className="font-medium font-mono text-sm">
                        {formatAddress(entry.address)}
                      </div>
                      <div className="text-sm text-gray-600">
                        收获: {entry.cropsHarvested} | 偷菜: {entry.cropsStolen}
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-lg font-bold text-gray-900">
                      {entry.score}
                    </div>
                    <div className="text-sm text-gray-600">总分</div>
                  </div>
                </div>
                ))}
              </div>
            )}

            <div className="text-center mt-6">
              <Button variant="secondary" size="sm">
                查看更多
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* 善良值排行榜 */}
      {activeTab === 'kindness' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <HeartIcon className="w-5 h-5 text-primary-600" />
              <span>善良值排行榜</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            {kindnessLoading ? (
              <div className="text-center py-12">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
                <p className="text-gray-600">加载排行榜数据中...</p>
              </div>
            ) : kindnessLeaderboard.length === 0 ? (
              <div className="text-center py-12">
                <HeartIcon className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">暂无排行榜数据</h3>
                <p className="text-gray-600">
                  还没有玩家数据，开始游戏后排行榜将显示在这里
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {kindnessLeaderboard.map((entry) => (
                <div
                  key={entry.rank}
                  className={`flex items-center justify-between p-4 rounded-lg border ${
                    entry.address.includes(address?.slice(0, 6) || '')
                      ? 'bg-primary-50 border-primary-200'
                      : 'bg-gray-50 border-gray-200'
                  }`}
                >
                  <div className="flex items-center space-x-4">
                    <div className={`text-lg font-bold ${getRankColor(entry.rank)}`}>
                      {getRankIcon(entry.rank)}
                    </div>
                    <div>
                      <div className="font-medium font-mono text-sm">
                        {formatAddress(entry.address)}
                      </div>
                      <div className="text-sm text-gray-600">
                        帮助次数: {entry.helpProvided}
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-lg font-bold text-primary-600">
                      {entry.kindBalance}
                    </div>
                    <div className="text-sm text-primary-600">KIND</div>
                  </div>
                </div>
                ))}
              </div>
            )}

            <div className="text-center mt-6">
              <Button variant="secondary" size="sm">
                查看更多
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* 如何提升排名 */}
      <Card>
        <CardHeader>
          <CardTitle>如何提升排名？</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="font-semibold text-green-700 mb-3">提升收获排名</h3>
              <ul className="space-y-2 text-sm text-gray-600">
                <li className="flex items-start space-x-2">
                  <span className="text-green-500">•</span>
                  <span>种植更多作物，增加收获数量</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500">•</span>
                  <span>种植稀有作物获得更高分数</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500">•</span>
                  <span>合理偷菜增加作物获取</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500">•</span>
                  <span>使用道具加速作物成长</span>
                </li>
              </ul>
            </div>

            <div>
              <h3 className="font-semibold text-primary-700 mb-3">提升善良值排名</h3>
              <ul className="space-y-2 text-sm text-gray-600">
                <li className="flex items-start space-x-2">
                  <span className="text-primary-500">•</span>
                  <span>每天帮助其他农民15次</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-primary-500">•</span>
                  <span>积累KIND代币购买稀有种子</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-primary-500">•</span>
                  <span>持续参与社区互助活动</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-primary-500">•</span>
                  <span>保持长期的游戏活跃度</span>
                </li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
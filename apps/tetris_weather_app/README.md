# Tetris Weather · 晴天 MVP

基于 Flutter 3.24.5（FVM）和 melos 的俄罗斯方块化天气演示。核心场景为「晴天」，包含方块堆叠、温度曲线、日出日落与基础交互。

## 快速开始

```bash
# 确认使用 Flutter 3.24.5（已在根目录 .fvm 配置）
fvm use 3.24.5

# 安装依赖（可选 melos，也可直接进应用目录执行）
melos bootstrap
# 或
cd apps/tetris_weather_app
fvm flutter pub get --offline

# 运行（以本机设备为例）
melos exec --scope tetris_weather -- fvm flutter run
```

## 交互要点
- 顶部展示晴朗状态、温度趋势、日出/日落。
- 中部为方块玩法：点击旋转、双击直落，底部按钮支持左右移、软降/直降。
- 晴天场景会自动缓慢掉落并消行，代表天气稳定。

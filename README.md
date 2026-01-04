# Tetris Weather Workspace

单体仓库结构，使用 FVM（Flutter 3.24.5）与 melos 管理：

```
.
├── apps
│   └── tetris_weather_app   # Flutter 天气 App（晴天 MVP）
├── packages                 # 预留组件/插件目录（当前为空）
├── tetris_weather_assets    # 设计稿/示意资产
├── weather.md               # 产品/视觉说明
├── mvp.md                   # 需求补充（待填）
└── melos.yaml / pubspec.yaml
```

## 快速开始
```bash
fvm use 3.24.5   # 已在 .fvm/fvm_config.json 配置

# 安装依赖（workspace 层）
fvm dart pub get

# 引导所有包（使用 melos）
melos bootstrap

# 进入 App 运行
cd apps/tetris_weather_app
fvm flutter run
```

如未安装 melos，可先 `fvm dart pub global activate melos` 或在本仓库执行 `fvm dart pub get` 后用 `fvm dart run melos bootstrap`。

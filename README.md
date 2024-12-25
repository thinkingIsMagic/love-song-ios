# Love Song iOS App

一个优雅的视频播放应用，使用 SwiftUI 开发。

## 功能特点

- 自定义视频播放器界面
- 流畅的视频播放控制
- 优雅的用户界面设计
- 支持视频播放/暂停控制
- 自定义关闭按钮

## 技术栈

- SwiftUI
- AVKit (用于视频播放)
- iOS 14.0+

## 项目结构

```
love-song-ios-2/
├── ContentView.swift        # 主视图
├── Views/                   # 视图组件
│   ├── CloseButton.swift    # 关闭按钮组件
│   ├── VideoPlayerView.swift # 视频播放器视图
│   ├── PlayButton.swift     # 播放按钮组件
│   └── CustomVideoPlayer.swift # 自定义视频播放器
└── Models/                  # 数据模型
    └── VideoLoader.swift    # 视频加载器
```

## 开发要求

- Xcode 13.0+
- iOS 14.0+
- Swift 5.5+

## 如何运行

1. 克隆项目到本地
2. 使用 Xcode 打开 `love-song-ios-2.xcodeproj`
3. 选择目标设备或模拟器
4. 点击运行按钮或按下 `Cmd + R`

## 许可证

Copyright © 2023 Love Song. All rights reserved. 
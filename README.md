# react-native-wmm-aliyunplayer

## 说明

本库基于 `react-native-wmm-aliyunplayer`创建, 在原有播放器基础上添加了新功能，并封装了阿里云播的下载功能。
本库是阿里云播放器的，**_非全量_** 封装。支持功能**_播放、下载_**功能。

### 常用 Script

```shell
//  安装依赖
yarn bootstrap
//  运行iOS
yarn example ios
//  运行安卓
yarn example android
```

## Installation

```sh
npm install react-native-wmm-aliyunplayer

// or
yarn add react-native-wmm-aliyunplayer
```

### 安卓

Project build.gradle 添加 meaven 依赖`maven {url 'https://maven.aliyun.com/repository/releases'}`

### API

[播放器文档](./doc/API.md)

## TODO

- 下载列表，基于 sqlite 的 native 实现。
- example 播放器和下载的案例
- 下载 API 文档

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Contributor
<a href="https://github.com/nbhhcty"><img src="https://avatars.githubusercontent.com/u/11188644?v=4" width=100 height=100 style="border-radius:50px" /></a>
<a href="https://github.com/Feihua-czl"><img src="https://avatars.githubusercontent.com/u/21188352?v=4" width=100 height=100 style="border-radius:50px" /></a>
<a href="https://github.com/iHZW"><img src="https://avatars.githubusercontent.com/u/13400958?v=4" width=100 height=100 style="border-radius:50px" /></a>
<a href="https://github.com/JeversonJee"><img src="https://avatars.githubusercontent.com/u/16621180?v=4" width=100 height=100 style="border-radius:50px" /></a>

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

## Q&A

> iOS 调试代码 `yarn example ios`

> 关于 iOS `Hermes engine` pod install failure 时，可在`example/ios/Podfile`中将 `:hermes_enabled => false`

> 关于 iOS M1 Slice 问题

```shell
Undefined symbols for architecture x86_64:
  "_OBJC_CLASS_$_RCTBridge", referenced from:
      objc-class-ref in AppDelegate.o
  "_OBJC_CLASS_$_RCTBundleURLProvider", referenced from:
      objc-class-ref in AppDelegate.o
  "_RCTAppSetupDefaultRootView", referenced from:
      -[AppDelegate application:didFinishLaunchingWithOptions:] in AppDelegate.o
  "_RCTAppSetupPrepareApp", referenced from:
      -[AppDelegate application:didFinishLaunchingWithOptions:] in AppDelegate.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)

```

此处模拟器`x86_64`问题应在`PodFile` 中添加`config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"`

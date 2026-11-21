# netSpeedMini（迷你网速）

[![DMS Plugin](https://img.shields.io/badge/dux--shell-plugin-4f7cff)](#)
[![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey)](./LICENSE)

给 dux-shell（DMS）状态栏用的**窄版网速条**：只显示上下行速度，数字用短格式
（`12K` / `8M` / `1G`），不带图标不带单位，宽度大概是内置网速条的一半。

机制跟内置的 `NetworkMonitor` 完全一致——同一个 `DgopService` 数据源、同一个
惰性 `Ref` 激活方式、同样的 1 KB/s 空闲阈值和收缩动画——只是把外观做了减法。

```
↓ 10K  ↑ 6K          ← plain  极简箭头
( ↓ 10K  ↑ 6K )      ← chip   胶囊
10K · 6K             ← dot    点分
↓ 10K  ↑ 6K          ← mono   单色（不带颜色，最不抢眼）
```

## 样式

| 样式 | 样子 | 说明 |
| --- | --- | --- |
| `plain`（默认） | `↓ 10K ↑ 6K` | 下载蓝、上传橙，其余用文字色 |
| `chip` | 半透明圆角托底 | 自带一层毛玻璃感的底，像个小岛 |
| `dot` | `10K · 6K` | 没箭头，用中点分隔，最窄 |
| `mono` | 全同色 | 不跟随主题强调色，适合配色克制的栏 |

哪个方向低于 1 KB/s（闲着）就自动压暗一档，一眼看出是只有下载还是在传。

## 安装

```bash
git clone https://github.com/PandaAQI/netSpeedMini.git \
  ~/.config/dms/plugins/netSpeedMini
```

然后 `dms kill && dms run -d`（或重新登录）。DMS 会扫描 `~/.config/dms/plugins/`
下的目录，插件 id 就是 `netSpeedMini`，在设置里把「迷你网速」加到左侧/中间/右侧
任意一段即可。改样式不用重启，设置面板里点一下即时生效。

## 设置

| 键 | 默认 | 说明 |
| --- | --- | --- |
| `style` | `plain` | 上面那四套样式 |
| `hideWhenIdle` | `false` | 上传下载都低于 1 KB/s 时淡出，有流量再出现 |

两键都存在 `~/.config/dms/plugin_settings.json`，也可以直接改文件（改文件要重启
shell 才读到）。

## 说明

- 取数是 `DgopService.networkRxRate` / `networkTxRate`（字节/秒），跟内置同源。
- `compactRate()` 是从 DMS 的 `Common/Format.js` 里 `formatRateCompact(bytes, true)`
  抄过来内联的——插件目录不能跨目录 `import`，为了让插件自身可独立分发。
- 只在栏上可见时才订阅网络模块（`Ref { active: ... }`），不看的时候不耗。

## 致谢

结构参照 dux-shell 内置的 `Modules/DBar/Widgets/NetworkMonitor.qml`
（MIT，Copyright (c) 2025 Avenge Media LLC）。本仓库按 MIT 分发，见 [LICENSE](./LICENSE)。

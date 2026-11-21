# 更新记录

## 1.1.0 — 2026-11-21

- 新增四套样式：`plain` 极简箭头 / `chip` 胶囊 / `dot` 点分 / `mono` 单色，设置面板里切换，即时生效。
- 设置面板新增「样式」选择项。
- 修正读取配置的方式：改用 `SettingsData.getPluginSetting(pluginId, key, default)`，
  之前读的 `root.cfg.*` 在插件上下文里根本不存在，导致「空闲时隐藏」开关无效。
- 修正颜色引用：`Theme.contentColor` 不存在，改用 `Theme.widgetTextColor`。

## 1.0.0 — 2026-11-21

- 首版：一行式上下行速度，短格式数字，无图标无单位。

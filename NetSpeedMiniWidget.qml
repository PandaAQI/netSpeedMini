import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets

// 迷你网速：机制全抄内置 Modules/DBar/Widgets/NetworkMonitor.qml
// （BasePill 宿主壳、DgopService 取数、Ref 惰性激活、hideWhenIdle 阈值、
// 收缩动画），外观上做减法 + 四套可选样式。配置读取走
// SettingsData.getPluginSetting —— 与设置面板（NetSpeedMiniSettings.qml）
// 写入的是同一个键。
PluginComponent {
    id: root

    readonly property bool hideWhenIdle: SettingsData.getPluginSetting(pluginId, "hideWhenIdle", false)
    // plain 极简箭头 / chip 胶囊 / dot 点分 / mono 单色
    readonly property string style: SettingsData.getPluginSetting(pluginId, "style", "plain")
    readonly property real rxRate: DgopService.networkRxRate ?? 0
    readonly property real txRate: DgopService.networkTxRate ?? 0
    // 抄内置：低于 1KB/s 视为空闲
    readonly property bool shouldHide: hideWhenIdle && Math.max(rxRate, txRate) < 1024
    readonly property real textSize: Theme.barTextSize(barThickness, barConfig?.fontScale, barConfig?.maximizeWidgetText)

    readonly property bool showArrow: style === "plain" || style === "chip" || style === "mono"
    readonly property bool showDot: style === "dot"
    readonly property bool showChip: style === "chip"
    readonly property color chipColor: Theme.withAlpha(Theme.surfaceText, 0.09)
    // 下载用冷色、上传用暖色；mono 样式整体走文字色，不抢眼
    readonly property color downAccent: style === "mono" ? Theme.widgetTextColor : Theme.info
    readonly property color upAccent: style === "mono" ? Theme.widgetTextColor : Theme.warning
    readonly property real chipPad: showChip ? Theme.spacingS : 0
    // 空闲方向（<1KB/s）压暗一档，只有真正在跑的方向是亮的
    function rateColor(bytesPerSec) {
        return bytesPerSec < 1024 ? Theme.withAlpha(Theme.widgetTextColor, 0.55) : Theme.widgetTextColor;
    }

    // Copied from DMS Common/Format.js formatRateCompact(bytes, true):
    // "12M" / "1G" / "0K", keeps the plugin self-contained.
    function compactRate(bytesPerSec) {
        const units = ["K", "M", "G", "T"];
        let value = bytesPerSec / 1024;
        let unit = 0;
        while (unit < units.length - 1 && Math.round(value) >= 1000) {
            value /= 1024;
            unit++;
        }
        const shown = bytesPerSec > 0 ? Math.max(1, Math.round(value)) : 0;
        return shown + units[unit];
    }

    // 抄内置 Ref：没网速展示需求时不开 DgopService 的 network 轮询。
    Ref {
        service: DgopService
        modules: ["network"]
        active: (root.shouldHide || (root.visible && root.enabled)) && (root.Window.window?.visible ?? false)
    }

    horizontalBarPill: Component {
        Item {
            // 空闲收缩：内容宽度归零，宿主 BasePill 的 visualWidth
            // 由 contentLoader.item.implicitWidth 推导，自动跟着收窄。
            implicitWidth: root.shouldHide ? 0 : (contentRow.implicitWidth + root.chipPad * 2)
            implicitHeight: root.widgetThickness
            opacity: root.shouldHide ? 0 : 1

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            // chip 样式的胶囊底：半透明文字色，跟装它的 bar 主题自动适配
            Rectangle {
                anchors.centerIn: parent
                visible: root.showChip
                // 不绑 parent.width：宿主给内容项的 width 可能是 0，
                // 直接按内容宽度 + 内边距算
                width: contentRow.implicitWidth + root.chipPad * 2
                height: Math.min(root.widgetThickness - 2, Math.round(root.textSize * 1.9))
                radius: height / 2
                color: root.chipColor
            }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: root.showDot ? Theme.spacingXS : Theme.spacingXXS

                StyledText {
                    visible: root.showArrow
                    text: "↓"
                    font.pixelSize: root.textSize
                    color: root.downAccent
                }

                NumericText {
                    text: root.compactRate(root.rxRate)
                    reserveText: "888M"
                    font.pixelSize: root.textSize
                    color: root.rateColor(root.rxRate)
                }

                StyledText {
                    visible: root.showDot
                    text: "·"
                    font.pixelSize: root.textSize
                    color: Theme.withAlpha(Theme.widgetTextColor, 0.55)
                }

                // chip / dot 用一点额外间隔把上下行拉开，plain 靠箭头自然分隔
                StyledText {
                    visible: root.showArrow && !root.showDot
                    text: "↑"
                    font.pixelSize: root.textSize
                    color: root.upAccent
                    leftPadding: root.showChip ? Theme.spacingXS : 0
                }

                NumericText {
                    text: root.compactRate(root.txRate)
                    reserveText: "888M"
                    font.pixelSize: root.textSize
                    color: root.rateColor(root.txRate)
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: root.shouldHide ? 0 : vContent.implicitHeight
            opacity: root.shouldHide ? 0 : 1

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            Column {
                id: vContent
                anchors.centerIn: parent
                spacing: Theme.spacingXXS

                Row {
                    spacing: Theme.spacingXXS
                    StyledText {
                        visible: root.showArrow
                        text: "↓"
                        font.pixelSize: root.textSize
                        color: root.downAccent
                    }
                    NumericText {
                        text: root.compactRate(root.rxRate)
                        reserveText: "888M"
                        font.pixelSize: root.textSize
                        color: root.rateColor(root.rxRate)
                    }
                }

                Row {
                    spacing: Theme.spacingXXS
                    StyledText {
                        visible: root.showArrow
                        text: "↑"
                        font.pixelSize: root.textSize
                        color: root.upAccent
                    }
                    NumericText {
                        text: root.compactRate(root.txRate)
                        reserveText: "888M"
                        font.pixelSize: root.textSize
                        color: root.rateColor(root.txRate)
                    }
                }
            }
        }
    }
}

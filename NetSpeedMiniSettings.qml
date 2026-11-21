import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root

    pluginId: "netSpeedMini"

    StyledText {
        width: parent.width
        text: I18n.tr("迷你网速")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Theme.fontWeightMedium
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: I18n.tr("一行式上传/下载速度，数字短格式，比内置网速条窄一半。")
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceTextSecondary
        wrapMode: Text.WordWrap
    }

    SelectionSetting {
        settingKey: "style"
        label: I18n.tr("样式")
        description: I18n.tr("极简＝纯文字带彩色箭头；胶囊＝加一层半透明圆角底；点分＝去掉箭头用中点分隔；单色＝全部同色最不抢眼。")
        options: [
            { value: "plain", label: I18n.tr("极简箭头") },
            { value: "chip", label: I18n.tr("胶囊") },
            { value: "dot", label: I18n.tr("点分") },
            { value: "mono", label: I18n.tr("单色") }
        ]
        defaultValue: "plain"
    }

    ToggleSetting {
        settingKey: "hideWhenIdle"
        label: I18n.tr("空闲时隐藏")
        description: I18n.tr("上传下载都低于 1KB/s 时自动淡出，有流量再出现。")
        defaultValue: false
    }
}

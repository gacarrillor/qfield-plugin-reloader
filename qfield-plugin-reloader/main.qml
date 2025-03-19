import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Theme

Item {
    property
    var mainWindow: iface.mainWindow()
    property string pluginUuid: ""
    property string pluginName: ""

    Component.onCompleted: {
        iface.addItemToPluginsToolbar(reloadButton);
    }

    QfToolButton {
        id: reloadButton
        iconSource: 'icon.svg'
        iconColor: Theme.mainColor
        bgcolor: Theme.darkGray
        round: true

        onClicked: {
            if (pluginName != "" && pluginUuid != "") {
                confirmationDialog.open()
            } else {
                mainWindow.displayToast(qsTr("Press and hold to configure the plugin."))
            }
        }
        onPressAndHold: {
            pluginSelectionDialog.open()
        }
    }

    Dialog {
        id: confirmationDialog
        parent: mainWindow.contentItem
        visible: false
        modal: true
        font: Theme.defaultFont
        standardButtons: Dialog.Yes | Dialog.No
        title: qsTr("Reload plugin")

        x: (mainWindow.width - width) / 2
        y: (mainWindow.height - height) / 2

        ColumnLayout {
            Label {
                width: parent.width
                wrapMode: Text.Wrap
                text: qsTr("Are you sure you want to reload the plugin '%1'?").arg(pluginName)
            }
        }

        onAccepted: {
            if (pluginManager.isAppPluginEnabled(pluginUuid)) {
                pluginManager.disableAppPlugin(pluginUuid)
            }
            pluginManager.enableAppPlugin(pluginUuid)
            mainWindow.displayToast(qsTr("Reloading plugin '%1'...").arg(pluginName))
        }
    }

    Dialog {
        id: pluginSelectionDialog
        parent: mainWindow.contentItem
        visible: false
        modal: true
        font: Theme.defaultFont
        standardButtons: Dialog.Ok | Dialog.Cancel
        title: qsTr("Plugin selection")

        x: (mainWindow.width - width) / 2
        y: (mainWindow.height - height) / 2

        ColumnLayout {
            spacing: 10

            Label {
                id: labelSelection
                wrapMode: Text.Wrap
                text: qsTr("Select the (app) plugin you would like to reload")
            }

            ComboBox {
                id: comboBoxPlugins
                Layout.fillWidth: true

                textRole: "name"
                valueRole: "uuid"
                model: pluginManager.availableAppPlugins
            }
        }

        onAccepted: {
            mainWindow.displayToast(qsTr("Plugin '%1' selected to be reloaded!").arg(comboBoxPlugins.currentText));
            pluginName = comboBoxPlugins.currentText
            pluginUuid = comboBoxPlugins.currentValue
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

import Theme

Item {
    property var mainWindow: iface.mainWindow()

    Component.onCompleted: {
        iface.addItemToPluginsToolbar(reloadButton);
    }

    Settings {
        id: reloaderSettings
        property string pluginUuid: ""
        property string pluginName: ""
        property bool skipConfirmation: false
    }
    
    QfToolButton {
        id: reloadButton
        iconSource: 'icon.svg'
        iconColor: Theme.mainColor
        bgcolor: Theme.darkGray
        round: true

        onClicked: {
            if (reloaderSettings.pluginName != "" && reloaderSettings.pluginUuid != "") {
                if (!reloaderSettings.skipConfirmation) {
                  confirmationDialog.open();
                } else {
                  confirmationDialog.accepted();
                }
            } else {
                mainWindow.displayToast(qsTr("Press and hold to configure the plugin."));
            }
        }
        onPressAndHold: {
            pluginSelectionDialog.open();
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
                text: qsTr("Are you sure you want to reload the plugin '%1'?").arg(reloaderSettings.pluginName)
            }
        }

        onAccepted: {
            if (pluginManager.isAppPluginEnabled(reloaderSettings.pluginUuid)) {
                pluginManager.disableAppPlugin(reloaderSettings.pluginUuid);
            }
            pluginManager.enableAppPlugin(reloaderSettings.pluginUuid);
            mainWindow.displayToast(qsTr("Reloading plugin '%1'...").arg(reloaderSettings.pluginName));
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

        onAboutToShow: {
          comboBoxPlugins.currentIndex = comboBoxPlugins.indexOfValue(reloaderSettings.pluginUuid);
        }

        ColumnLayout {
            spacing: 10

            Label {
                id: labelSelection
                wrapMode: Text.Wrap
                text: qsTr("Select the (app) plugin you would like to reload")
                font: Theme.defaultFont
            }

            ComboBox {
                id: comboBoxPlugins
                Layout.fillWidth: true

                textRole: "name"
                valueRole: "uuid"
                model: pluginManager.availableAppPlugins
            }
            
            CheckBox {
                id: checkBoxSkipConfirmation
                Layout.fillWidth: true
                text: qsTr("Skip confirmation dialog when reloading")
                font: Theme.defaultFont
                
                checked: reloaderSettings.skipConfirmation
                
                onClicked: {
                    reloaderSettings.skipConfirmation = !reloaderSettings.skipConfirmation;
                }
            }   
        }

        onAccepted: {
            mainWindow.displayToast(qsTr("Plugin '%1' selected to be reloaded!").arg(comboBoxPlugins.currentText));
            reloaderSettings.pluginName = comboBoxPlugins.currentText;
            reloaderSettings.pluginUuid = comboBoxPlugins.currentValue;
        }
    }
}

/*
    SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
    SPDX-FileCopyrightText: 2025 Patryk Szela <53914832+PatrickSzela@users.noreply.github.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "../code/main.js" as Config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.faces as Faces

ColumnLayout {
    id: root

    property string cfg_fullRepresentationFaceId
    property alias cfg_spacing: spacingSpinBox.value
    property alias cfg_config: config.text
    property alias cfg_formatter: formatter.text
    property alias cfg_forceCompactRepresentation: forceCompactCheckbox.checked
    property var faceController: controller
    // The pluginId role from the FacesModel. FacesModel is a private class that
    // is only created by FaceController, so we can't access its roles from QML.
    // So declare this here since we need to use it in multiple places.
    readonly property int pluginIdRole: Qt.UserRole + 1

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.label: i18nc("@title:group", "Compact Representation")
            Kirigami.FormData.isSection: true
        }

        SpinBox {
            id: spacingSpinBox

            Kirigami.FormData.label: i18n("Spacing between items:")
            editable: true
            from: 0
            to: 999
            textFromValue: function(value) {
                return (i18n("%1px", value));
            }
            valueFromText: function(text) {
                return parseInt(text);
            }
        }

        TextArea {
            id: config

            function parse() {
                return JSON.parse(config.text.trim() || '[]');
            }

            function format() {
                config.text = JSON.stringify(config.parse(), null, 2);
            }

            Kirigami.FormData.label: i18n("Configuration:")
            Kirigami.FormData.labelAlignment: config.lineCount > 1 ? Qt.AlignTop : Qt.AlignVCenter
            Kirigami.SpellCheck.enabled: false
            Layout.fillWidth: true
            Layout.minimumWidth: 200
            wrapMode: TextEdit.Wrap
            font.family: "monospace"
        }

        ColumnLayout {
            // workaround for an entire app freezing when the formatter TextArea has `Layout.fillWidth` set to `true` and `wrapMode` set to `TextEdit.Wrap`
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Formatter:")
            Kirigami.FormData.labelAlignment: formatter.lineCount > 1 ? Qt.AlignTop : Qt.AlignVCenter

            TextArea {
                id: formatter

                function parse() {
                    return JSON.parse(formatter.text.trim() || '[]');
                }

                function format() {
                    formatter.text = JSON.stringify(formatter.parse(), null, 2);
                }

                function addNewFormatter(item) {
                    const data = formatter.parse();
                    data.push(item);
                    formatter.text = JSON.stringify(data);
                    formatter.format();
                }

                function addIcon(iconName) {
                    formatter.addNewFormatter(Config.buildIconFormatter(iconName));
                }

                function addSensor() {
                    const data = formatter.parse();
                    let index = data.reduce((acc, i, idx) => {
                        return acc + Number(i.type === "sensor");
                    }, 0);
                    formatter.addNewFormatter({
                        "type": "sensor",
                        "sensorIndex": index
                    });
                }

                function addText() {
                    formatter.addNewFormatter(Config.buildTextFormatter("Text"));
                }

                Kirigami.SpellCheck.enabled: false
                Layout.fillWidth: true
                Layout.minimumWidth: 200
                wrapMode: TextEdit.Wrap
                font.family: "monospace"
            }

        }

        Kirigami.ActionToolBar {
            actions: [
                Kirigami.Action {
                    text: "Icon"
                    icon.name: "symbols-symbolic"
                    tooltip: "Append Icon to the Formatter"
                    onTriggered: iconDialog.open()
                },
                Kirigami.Action {
                    text: "Sensor"
                    icon.name: "show-gpu-effects-symbolic"
                    tooltip: "Append Sensor to the Formatter"
                    onTriggered: formatter.addSensor()
                },
                Kirigami.Action {
                    text: "Text"
                    icon.name: "edit-select-text-symbolic"
                    tooltip: "Append Text to the Formatter"
                    onTriggered: formatter.addText()
                },
                Kirigami.Action {
                    text: "Format"
                    icon.name: "format-justify-right"
                    tooltip: "Format JSON in the Formatter"
                    onTriggered: {
                        config.format();
                        formatter.format();
                    }
                }
            ]
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18nc("@title:group", "Full Representation")
            Kirigami.FormData.isSection: true
        }

        ComboBox {
            id: faceCombo

            Kirigami.FormData.label: i18nc("@label:listbox items are sensor face names", "Display style:")
            textRole: "display"
            currentIndex: {
                // TODO just make an indexOf invocable on the model?
                for (var i = 0; i < count; ++i) {
                    const pluginId = model.data(model.index(i, 0), root.pluginIdRole);
                    if (pluginId === root.cfg_fullRepresentationFaceId)
                        return i;

                }
                return -1;
            }
            onActivated: function(index) {
                root.cfg_fullRepresentationFaceId = model.data(model.index(index, 0), root.pluginIdRole);
            }

            model: KItemModels.KSortFilterProxyModel {
                sourceModel: controller.availableFacesModel
                filterRowCallback: function(row, parent) {
                    const pluginId = sourceModel.data(sourceModel.index(row, 0, parent), root.pluginIdRole);
                    const excludedPlugins = ["org.kde.ksysguard.facegrid", "org.kde.ksysguard.colorgrid", "org.kde.ksysguard.applicationstable", "org.kde.ksysguard.processtable"];
                    return !excludedPlugins.includes(pluginId);
                }
                sortRoleName: "display"
            }

        }

        CheckBox {
            id: forceCompactCheckbox

            text: i18nc("@option:check", "Force Compact Representation")
        }

    }

    KIconThemes.IconDialog {
        id: iconDialog

        onIconNameChanged: {
            formatter.addIcon(iconDialog.iconName);
        }
    }

    Faces.FaceLoader {
        id: loader

        parentController: root.faceController
        groupName: "TextIcon"
        faceId: root.cfg_fullRepresentationFaceId
        readOnly: false
    }

    Item {
        id: faceConfigId

        Layout.fillWidth: true
        implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
        children: root.cfg_fullRepresentationFaceId !== "com.patrickszela.texticon" && loader.controller ? loader.controller.faceConfigUi : null
        onWidthChanged: {
            if (children.length > 0)
                children[0].width = width;

        }

        Connections {
            function onConfigurationChanged() {
                loader.controller.faceConfigUi.saveConfig();
                root.faceController.faceConfigUi.configurationChanged();
            }

            target: root.cfg_fullRepresentationFaceId !== "com.patrickszela.texticon" && loader.controller ? loader.controller.faceConfigUi : null
        }

    }

}

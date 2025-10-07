/*
    SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
    SPDX-FileCopyrightText: 2025 Patryk Szela <53914832+PatrickSzela@users.noreply.github.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/
import "../code/main.js" as Config
import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.8 as Kirigami
import org.kde.ksysguard.faces 1.0 as Faces
import org.kde.ksysguard.formatter 1.0 as Formatter
import org.kde.ksysguard.sensors 1.0 as Sensors

GridLayout {
    // flow: formFactor === Faces.SensorFace.Vertical ? Grid.TopToBottom : Grid.LeftToRight

    id: root

    property var sensorIds
    property int updateRateLimit
    property var formFactor
    property var config
    property var formatter
    property int spacing
    property var parsedConfig
    property var sensors: []
    readonly property real contentWidth: {
        let width = Math.ceil(children.reduce((acc, i, idx) => {
            return acc + i.width;
        }, 0));
        // we use `repeater.count` instead of `children.length` because repeater is added at the end of the list of grid's children
        width += spacing * Math.max(repeater.count - 1, 0);
        return width + (width % 2);
    }

    function updateConfig() {
        // force reload
        parsedConfig = [];
        parsedConfig = Config.updateConfig(formatter, sensorIds, config);
    }

    onSensorsChanged: updateConfig()
    onFormatterChanged: updateConfig()
    onConfigChanged: updateConfig()
    columnSpacing: spacing
    Layout.minimumHeight: Kirigami.Units.gridUnit
    Layout.minimumWidth: contentWidth
    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    Instantiator {
        model: sensorIds
        onObjectAdded: function(index, sensor) {
            root.sensors = Config.onSensorAdded(index, sensor, root.sensors);
        }
        onObjectRemoved: function(index, sensor) {
            root.sensors = Config.onSensorRemoved(index, sensor, root.sensors);
        }

        Sensors.Sensor {
            sensorId: modelData
            updateRateLimit: root.updateRateLimit
        }

    }

    Repeater {
        id: repeater

        model: root.parsedConfig

        Loader {
            sourceComponent: modelData.type === "sensor" ? sensorC : modelData.type === "icon" ? iconC : textC

            Component {
                id: sensorC

                Label {
                    id: value

                    text: Config.format(modelData, sensor, Formatter.Formatter)
                    Component.onCompleted: Config.applyConfigToComponent(value, modelData, sensor, root.sensors, Kirigami)

                    font {
                        features: {
                            "tnum": 1
                        }
                    }

                    Sensors.Sensor {
                        id: sensor

                        sensorId: modelData.sensorId
                        updateRateLimit: root.updateRateLimit
                    }

                }

            }

            Component {
                id: textC

                Label {
                    id: text

                    text: modelData.text
                    Component.onCompleted: Config.applyConfigToComponent(text, modelData, null, root.sensor, Kirigami)
                }

            }

            Component {
                id: iconC

                Kirigami.Icon {
                    id: icon

                    source: modelData.icon
                    roundToIconSize: false
                    implicitWidth: modelData.iconSize ?? 16
                    implicitHeight: modelData.iconSize ?? 16
                    Component.onCompleted: Config.applyConfigToComponent(icon, modelData, null, root.sensors, Kirigami)
                }

            }

        }

    }

}

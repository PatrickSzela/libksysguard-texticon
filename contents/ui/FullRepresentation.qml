/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
    SPDX-FileCopyrightText: 2025 Patryk Szela <53914832+PatrickSzela@users.noreply.github.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.faces as Faces

Faces.SensorFace {
    id: root

    Layout.preferredWidth: 200 * (root.controller.highPrioritySensorIds.length || 1)
    Layout.preferredHeight: 150
    Layout.minimumWidth: Kirigami.Units.gridUnit * 8

    contentItem: Loader {
        id: loader

        sourceComponent: root.controller.faceConfiguration.fullRepresentationFaceId === "com.patrickszela.texticon" ? textIconC : chartsC
        anchors.fill: parent

        Component {
            id: chartsC

            ColumnLayout {
                id: charts

                property bool compact: root.controller.faceConfiguration.forceCompactRepresentation
                readonly property real preferredWidth: titleMetrics.width

                Kirigami.Heading {
                    id: heading

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: root.controller.title
                    visible: !charts.compact && root.controller.showTitle && text.length > 0
                    level: 2

                    TextMetrics {
                        id: titleMetrics

                        font: heading.font
                        text: heading.text
                    }

                }

                RowLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Repeater {
                        id: chartsRepeater

                        model: root.controller.highPrioritySensorIds

                        FaceLoader {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 0
                            Layout.preferredHeight: 0
                            compact: charts.compact
                            controller: root.controller
                            sensors: [modelData]
                            fullRepresentationFaceId: root.controller.faceConfiguration.fullRepresentationFaceId
                        }

                    }

                }

            }

        }

        Component {
            id: textIconC

            ColumnLayout {
                Layout.fillHeight: true
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    id: heading

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: root.controller.title
                    visible: root.controller.showTitle && text.length > 0
                    level: 2

                    TextMetrics {
                        id: titleMetrics

                        font: heading.font
                        text: heading.text
                    }

                }

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: Kirigami.Units.smallSpacing
                    }

                    TextIcon {
                        sensorIds: root.controller.highPrioritySensorIds
                        updateRateLimit: root.controller.updateRateLimit
                        formFactor: root.formFactor
                        config: root.controller.faceConfiguration.config
                        formatter: root.controller.faceConfiguration.formatter
                        spacing: root.controller.faceConfiguration.spacing
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: Kirigami.Units.smallSpacing
                    }

                }

            }

        }

    }

}

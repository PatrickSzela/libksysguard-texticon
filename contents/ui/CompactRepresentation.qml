/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
    SPDX-FileCopyrightText: 2025 Patryk Szela <53914832+PatrickSzela@users.noreply.github.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.faces as Faces

Faces.CompactSensorFace {
    id: root

    Layout.minimumWidth: root.formFactor == Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit : contentItem.Layout.minimumWidth
    Layout.minimumHeight: Kirigami.Units.gridUnit

    contentItem: RowLayout {
        spacing: 0

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

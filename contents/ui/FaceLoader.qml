/*
    SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
    SPDX-FileCopyrightText: 2025 Patryk Szela <53914832+PatrickSzela@users.noreply.github.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.ksysguard.faces as Faces

Control {
    id: control

    property var controller
    property var sensors: []
    property var sensorNames: []
    property string fullRepresentationFaceId
    property bool compact

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    Layout.minimumWidth: contentItem?.Layout.minimumWidth ?? -1
    Layout.minimumHeight: contentItem?.Layout.minimumHeight ?? -1
    Layout.preferredWidth: contentItem?.Layout.preferredWidth ?? -1
    Layout.preferredHeight: contentItem?.Layout.preferredHeight ?? -1
    Layout.maximumWidth: contentItem?.Layout.maximumWidth ?? -1
    Layout.maximumHeight: contentItem?.Layout.maximumHeight ?? -1

    implicitWidth: contentItem?.implicitWidth ?? 0
    implicitHeight: contentItem?.implicitHeight ?? 0

    onCompactChanged: function() {
        // a workaround for graphs disappearing after toggling checkbox twice
        const temp = loader.controller.fullRepresentationFaceId
        loader.controller.fullRepresentationFaceId = "com.patrickszela.texticon"
        loader.controller.fullRepresentationFaceId = temp
    }

    Faces.FaceLoader {
        id: loader
        parentController: control.controller
        groupName: "TextIcon"
        sensors: control.sensors
        faceId: control.fullRepresentationFaceId
        colors: control.controller.sensorColors
        labels: control.controller.sensorLabels
        updateRateLimit: control.controller.updateRateLimit
    }

    Component.onCompleted: updateContentItem()

    Connections {
        target: loader.controller
        function onFaceIdChanged() {
            control.updateContentItem()
        }
    }

    function updateContentItem() {
        if (control.compact) {
            loader.controller.compactRepresentation.formFactor = Faces.SensorFace.Constrained;
            control.contentItem = loader.controller.compactRepresentation;
        } else {
            loader.controller.fullRepresentation.formFactor = Faces.SensorFace.Constrained;
            control.contentItem = loader.controller.fullRepresentation;
        }
    }

    Connections {
        target: root.controller.faceConfigUi
        function onConfigurationChanged() {
            loader.controller.reloadFaceConfiguration()
        }
    }
}

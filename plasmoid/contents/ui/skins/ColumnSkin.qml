/**
 * Copyright 2013-2016 Dhaby Xiloj, Konstantin Shtepa
 *
 * This file is part of plasma-simpleMonitor.
 *
 * plasma-simpleMonitor is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or any later version.
 *
 * plasma-simpleMonitor is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-simpleMonitor.  If not, see <http://www.gnu.org/licenses/>.
 **/

import QtQuick 2.15
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents

import "../monitorWidgets"
import "../components"
import "../../code/code.js" as Code

BaseSkin {
    id: root

    implicitWidth: mainLayout.implicitWidth
                   + mainLayout.anchors.leftMargin
                   + mainLayout.anchors.rightMargin
    implicitHeight: mainLayout.implicitHeight
                    + mainLayout.anchors.topMargin
                    + mainLayout.anchors.bottomMargin

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: 5
        spacing: 0

        Item {
            implicitHeight: datePicker.implicitHeight
            implicitWidth: datePicker.implicitWidth

            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            Layout.minimumWidth: implicitWidth

            DatePicker {
                id: datePicker

                anchors { left: parent.left; leftMargin: 10 }
            }

            UptimePicker {
                id: uptimePicker

                anchors { top: parent.top; right: parent.right }
                visible: showUptime
                uptime: root.uptime
            }
        }

        GridLayout {
            columns: 2
            rows: 3
            columnSpacing: 0
            rowSpacing: 0

            Layout.fillWidth: true
            Layout.topMargin: 5

            ColumnLayout {
                id: distroInfo

                Layout.rowSpan: 3
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight

                LogoImage {
                    id: distroLogo
                    Layout.minimumWidth: (implicitWidth < implicitHeight) ? 100*implicitWidth/implicitHeight : 100
                    Layout.minimumHeight: (implicitHeight < implicitWidth) ? 100*implicitHeight/implicitWidth : 100
                    Layout.preferredWidth: (Layout.fillWidth) ? Layout.minimumWidth : height * implicitWidth/implicitHeight
                    Layout.preferredHeight: (Layout.fillHeight) ? Layout.minimumHeight : width * implicitHeight/implicitWidth
                    Layout.fillWidth: (implicitWidth < implicitHeight) ? false: true
                    Layout.fillHeight: !Layout.fillWidth
                    Layout.alignment: Qt.AlignCenter

                    image.source: "../" + Code.getStandardLogo(logo, osInfoItem.distroId)

                    fillScale: plasmoid.configuration.logoScale
                    onFillScaleChanged: if (fillScale !== plasmoid.configuration.logoScale) plasmoid.configuration.logoScale = fillScale

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: logoPopup.open(mouse.x, mouse.y)
                    }

                    PlasmaComponents.ContextMenu {
                        id: logoPopup

                        PlasmaComponents.MenuItem {
                            text: distroLogo.editMode ? i18n("Lock image scaling") : i18n("Unlock image scaling")
                            onClicked: distroLogo.editMode = !distroLogo.editMode
                        }
                    }
                }

                OsInfoItem {
                    id: osInfoItem

                    distroName: root.distroName
                    distroId: root.distroId
                    distroVersion: root.distroVersion
                    kernelName: root.kernelName
                    kernelVersion: root.kernelVersion

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    Layout.topMargin: 2
                    Layout.minimumHeight: implicitHeight
                    Layout.maximumHeight: implicitHeight
                    Layout.minimumWidth: implicitWidth
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }
            }

            TimePicker {
                id: timePicker

                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: -5
                Layout.leftMargin: 10
                Layout.bottomMargin: 5
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }

            Rectangle {
                color: "white"

                Layout.leftMargin: 2
                Layout.fillWidth: true
                Layout.minimumHeight: 3
                Layout.maximumHeight: 3
                Layout.preferredHeight: 3
            }


            CoreTempList {
                id: coreTempList

                model: coreTempModel
                highTemp: cpuHighTemp
                criticalTemp: criticalTemp
                tempUnit: root.tempUnit
                direction: root.direction

                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Layout.topMargin: 5
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
    
                CoreTempList {
                    id: coreTempList
    
                    model: coreTempModel
                    highTemp: cpuHighTemp
                    criticalTemp: criticalTemp
                    tempUnit: root.tempUnit
                    direction: root.direction
    
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.topMargin: 5
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }
    
                GpuTempList {
                    id: gpuTempList
    
                    model: gpuTempModel
                    highTemp: cpuHighTemp
                    criticalTemp: criticalTemp
                    tempUnit: root.tempUnit
                    direction: root.direction
    
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.topMargin: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }
            }
        }

        Rectangle {
            color: "white"

            Layout.fillWidth: true
            Layout.minimumHeight: 3
            Layout.maximumHeight: 3
            Layout.preferredHeight: 3
            Layout.topMargin: 5
        }

        CpuWidget {
            id: cpuList

            direction: root.direction

            Layout.leftMargin: 5
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
        }

        Rectangle {
            color: "white"

            Layout.fillWidth: true
            Layout.minimumHeight: 3
            Layout.maximumHeight: 3
            Layout.preferredHeight: 3
            Layout.topMargin: 5
        }

        MemArea {
            id: memArea

            memFree: root.memFree
            memTotal: root.memTotal
            memCached: root.memCached
            memUsed: root.memUsed
            memBuffers: root.memBuffers

            Layout.columnSpan: 2
            Layout.topMargin: 2
            Layout.leftMargin: 10
            Layout.rightMargin: 5
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.maximumHeight: implicitHeight
        }

        Rectangle {
            visible: showSwap
            color: "white"

            Layout.fillWidth: true
            Layout.minimumHeight: 3
            Layout.maximumHeight: 3
            Layout.preferredHeight: 3
            Layout.topMargin: 5
        }

        MemArea {
            id: swapArea

            visible: showSwap
            memTypeLabel: i18n("Swap:")
            memFree: root.swapFree
            memTotal: root.swapTotal
            memUsed: root.swapUsed

            Layout.columnSpan: 2
            Layout.topMargin: 2
            Layout.leftMargin: 10
            Layout.rightMargin: 5
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.maximumHeight: implicitHeight
        }
    }
}

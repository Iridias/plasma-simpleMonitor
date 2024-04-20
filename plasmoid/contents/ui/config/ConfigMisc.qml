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
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kcmutils as KCM

import "../../code/code.js" as Code

KCM.SimpleKCM {
    id: root

    Layout.fillHeight: true
    Layout.fillWidth: true

    implicitHeight: settingsLayout.implicitHeight
    implicitWidth: settingsLayout.implicitWidth

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    property alias cfg_coloredCpuLoad: coloredCpuLoadCheckBox.checked
    property alias cfg_flatCpuLoad: flatCpuLoadCheckBox.checked
    property alias cfg_indicatorHeight: indicatorHeightSpinBox.value
    property alias cfg_updateInterval: updateIntervalSpinBox.value

    ColumnLayout {
        id: settingsLayout
        anchors.fill: parent

        GroupBox {
            title: i18n("Style settings:")
            Layout.fillWidth: true

            GridLayout {
                columns: 2

                Label {
                    text: i18n("CPU load indicator style:")
                    Layout.alignment: Qt.AlignRight
                    Layout.row: 0
                    Layout.column: 0
                }

                CheckBox {
                    id: coloredCpuLoadCheckBox
                    text: i18n("Colored")
                    Layout.row: 0
                    Layout.column: 1
                }

                CheckBox {
                    id: flatCpuLoadCheckBox
                    text: i18n("Flat")
                    Layout.row: 1
                    Layout.column: 1
                }

                SpinBox {
                    id: indicatorHeightSpinBox
                    from: 1
                    to: 99
                    Layout.row: 2
                    Layout.column: 1
                }

                Label {
                    text: i18n("CPU load indicator height:")
                    Layout.alignment: Qt.AlignRight
                    Layout.row: 2
                    Layout.column: 0
                }
            }
        }

        GroupBox {
            title: i18n("Performance settings:")
            Layout.fillWidth: true

            GridLayout {
                columns: 2

                Label {
                    text: i18n('Update interval:')
                    Layout.alignment: Qt.AlignRight
                }

                SpinBox {
                    id: updateIntervalSpinBox
                    stepSize: 1
                    from: 1
                    to: 10
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            color: "transparent"
        }
    }
}

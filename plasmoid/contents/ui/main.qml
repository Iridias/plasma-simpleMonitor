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
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import QtQuick.Controls

import "../code/code.js" as Code

PlasmoidItem {
	id: root
	preferredRepresentation: fullRepresentation

	Rectangle {
		id: main

		width: implicitWidth
		height: implicitHeight

		implicitWidth: loader.implicitWidth
		implicitHeight: loader.implicitHeight

		Layout.minimumWidth: implicitWidth
		Layout.minimumHeight: implicitHeight
		Layout.preferredWidth: implicitWidth
		Layout.preferredHeight: implicitHeight

		color: "black"

		// Control for atk sensor.
		property bool atkPresent: false

		Component.onCompleted: atkPresent = false

		// Configuration properties.
		property bool showGpuTemp:      plasmoid.configuration.showGpuTemp
		property double updateInterval: plasmoid.configuration.updateInterval

		QtObject {
			id: confEngine

			// Configuration properties.
			property int skin:              plasmoid.configuration.skin
			property int bgColor:           plasmoid.configuration.bgColor
			property int logo:              plasmoid.configuration.logo
			property bool showGpuTemp:      plasmoid.configuration.showGpuTemp
			property bool showSwap:         plasmoid.configuration.showSwap
			property bool showUptime:       plasmoid.configuration.showUptime
			property int tempUnit:          plasmoid.configuration.tempUnit
			property int cpuHighTemp:       plasmoid.configuration.cpuHighTemp
			property int cpuCritTemp:       plasmoid.configuration.cpuCritTemp
			property bool coloredCpuLoad:   plasmoid.configuration.coloredCpuLoad
			property bool flatCpuLoad:      plasmoid.configuration.flatCpuLoad
			property int indicatorHeight:   plasmoid.configuration.indicatorHeight
			property double updateInterval: plasmoid.configuration.updateInterval

			property string distroName: "tux"
			property string distroId: "tux"
			property string distroVersion: ""
			property string kernelName: ""
			property string kernelVersion: ""

			property int direction: Qt.LeftToRight

			onSkinChanged: {
				switch (skin) {
				default:
				case 0:
					loader.source = "skins/DefaultSkin.qml";
					root.Layout.maximumWidth = root.Layout.preferredWidth;
					root.Layout.maximumHeight = root.Layout.preferredHeight;
					root.Layout.maximumWidth = Number.POSITIVE_INFINITY;
					root.Layout.maximumHeight = Number.POSITIVE_INFINITY;
					break;
				case 1:
					loader.source = "skins/ColumnSkin.qml"
					root.Layout.maximumWidth = root.Layout.preferredWidth;
					root.Layout.maximumHeight = root.Layout.preferredHeight;
					root.Layout.maximumWidth = Number.POSITIVE_INFINITY;
					root.Layout.maximumHeight = Number.POSITIVE_INFINITY;
					break;
				case 2:
					loader.source = "skins/MinimalisticSkin.qml"
					root.Layout.maximumWidth = root.Layout.preferredWidth;
					root.Layout.maximumHeight = root.Layout.preferredHeight;
					root.Layout.maximumWidth = Number.POSITIVE_INFINITY;
					root.Layout.maximumHeight = Number.POSITIVE_INFINITY;
					break;
				}
			}

			onBgColorChanged: {
				switch (bgColor) {
				default:
				case 0:
					main.color = "black";
					plasmoid.backgroundHints = "StandardBackground";
					break;
				case 1:
					main.color = "transparent";
					plasmoid.backgroundHints = "NoBackground";
					break;
				case 2:
					main.color = "transparent";
					plasmoid.backgroundHints = "TranslucentBackground";
					break;
				}
			}

			Component.onCompleted: {
				Code.getDistroInfo(function(info) {
					distroName = info['name']
					distroId = info['id']
					distroVersion = (info['version'] !== undefined)?info['version']:""
				}, this);

				Code.getKernelInfo(function(info){
					kernelName = info['name']
					kernelVersion = info['version']
				}, this);
			}
		}

		ListModel {
			id: cpuModel

			function getAll() {
				let list = [];
				for(let i=0; i < cpuModel.count; i++) {
					list.push(cpuModel.get(i));
				}
				return list;
			}
		}

		ListModel {
			id: coreTempModel

			function getAll() {
				let list = [];
				for(let i=0; i < coreTempModel.count; i++) {
					list.push(coreTempModel.get(i));
				}
				return list;
			}
		}

		ListModel {
			id: gpuTempModel
		}

		Plasma5Support.DataSource {
			id: sensorsDataSource
			engine: "executable"
			interval: main.updateInterval * 2000
			
			connectedSources: ['/usr/bin/sensors -j']

			onNewData: {
				if (data['exit code'] != 0 || data.stdout == '') {
					print('sensors data error: ' + data['exit code'] + ' ' + data.stderr);
					return;
				}
				var sensorData = JSON.parse(data.stdout);
				for(var key in sensorData) {
					if(!Code.isMatchCpuTempSensor(key)) {
						continue;
					}
					for(var k in sensorData[key]) {
						if(!Code.isMatchCpuCore(k)) {
							continue;
						}
						for(var entry in sensorData[key][k]) {
							if(entry.match("temp\\d+_input")) {
								var currentSensorValue = sensorData[key][k][entry];
								var currentCpuIndex = Code.determineCurrentCpuIndex(key, k, entry);
								var currentCoreLabel = Code.determineCpuCoreLabel(key, k);
								
								if (coreTempModel.count <= currentCpuIndex) {
									coreTempModel.append({'val':currentSensorValue, 'dataUnits':'°C', 'coreLabelStr':currentCoreLabel});
								} else {
									coreTempModel.set(currentCpuIndex,{'val':currentSensorValue, 'dataUnits':'°C', 'coreLabelStr':currentCoreLabel});
								}
							}
						}
					}
				}
			}
		}
		
		Plasma5Support.DataSource {
			id: meminfoDataSource
			engine: "executable"
			interval: main.updateInterval * 5000
			
			connectedSources: ['cat /proc/meminfo']

			property alias delegate: loader.item
			
			onNewData: {
				if (data['exit code'] != 0 || data.stdout == '') {
					print('meminfo data error: ' + data['exit code'] + ' ' + data.stderr);
					return;
				}
				
				var memData = data.stdout.split('\n');
				var memTotal = 0;
				var memAvailable = 0;
				
				for(var line of memData) {
					var value = line.replace(/.*: +(.*) kB/, '$1')
					var valueInGB = value/1048576;
					
					if(line.startsWith("MemTotal:")) {
						delegate.memTotal=valueInGB;
						memTotal = value;
					} else if(line.startsWith("MemFree:")) {
						delegate.memFree=valueInGB;
					} else if(line.startsWith("MemAvailable:")) {
						delegate.memAvailable=valueInGB;
						memAvailable = value;
					} else if(line.startsWith("Buffers:")) {
						delegate.memBuffers=valueInGB;
					} else if(line.startsWith("Cached:")) {
						delegate.memCached=valueInGB;
					} else if(line.startsWith("SwapTotal:")) {
						delegate.swapTotal=valueInGB;
					} else if(line.startsWith("SwapFree:")) {
						delegate.swapFree=valueInGB;
					}
				}

				var memUsed = (memTotal - memAvailable)/1048576;
				delegate.memUsed=memUsed;
			}
		}

		Plasma5Support.DataSource {
			id: cpuUsageDataSource
			engine: "executable"
			interval: main.updateInterval * 1000
			
			connectedSources: ['grep "cpu[0-9]" /proc/stat']

			onNewData: {
				if (data['exit code'] != 0 || data.stdout == '') {
					print('cpuUsage data error: ' + data['exit code'] + ' ' + data.stderr);
					return;
				}
				
				var cpuData = data.stdout.split('\n');
				
				for(var line of cpuData) {
					if(line.trim().length == 0) {
						continue;
					}
					var coreStat = Code.createCoreStat(line);
					if (Code.coreStats.has(coreStat.coreName)) {
						var previousStat = Code.coreStats.get(coreStat.coreName);
						var usage = previousStat.calcUsage(coreStat);
						
						if (cpuModel.count <= coreStat.coreId) {
							cpuModel.append({'val':usage});
						} else {
							cpuModel.set(coreStat.coreId,{'val':usage});
						}
					}
					
					Code.coreStats.set(coreStat.coreName, coreStat);
				}
			}
		}

		Plasma5Support.DataSource {
			id: uptimeDataSource
			engine: "executable"
			interval: main.updateInterval * 5000
			
			connectedSources: ['cat /proc/uptime']

			property alias delegate: loader.item
			
			onNewData: {
				if (data['exit code'] != 0 || data.stdout == '') {
					print('uptime data error: ' + data['exit code'] + ' ' + data.stderr);
					return;
				}
				
				var uptimeInSeconds = parseInt(data.stdout.split('.')[0]);
				delegate.uptime = uptimeInSeconds;
			}
		}
		
		
		Plasma5Support.DataSource {
			id: nvidiaDataSource
			engine: 'executable'
			interval: if (main.showGpuTemp) main.updateInterval * 1000; else 0

			connectedSources: [ 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader' ]

			property bool gpuAppended: false

			onNewData: function(data) {
				var dataName = "NVIDIA";
				var gpuLabelStr = "NVIDIA GPU"
				var temperature = 0
				if (data['exit code'] != 0 || data.stdout == '') {
	//                print('NVIDIA data error: ' + data.stderr)
					return
				} else {
					temperature = parseFloat(data.stdout)
					if (isNaN(temperature))
						return
				}

				if (gpuAppended == false) {
					gpuTempModel.append({'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
					gpuAppended = true
				} else {
					gpuTempModel.set(dataName,{'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
				}
			}
		}

		Plasma5Support.DataSource {
			id: atiDataSource
			engine: 'executable'
			interval: if (main.showGpuTemp) main.updateInterval * 1000; else 0

			connectedSources: [ 'aticonfig --od-gettemperature | tail -1 | cut -c 43-44' ]

			property bool gpuAppended: false

			onNewData: function(data) {
				var dataName = "ATI";
				var gpuLabelStr = "ATI GPU"
				var temperature = 0
				if (data['exit code'] != 0 || data.stdout == '') {
	//                print('ATI data error: ' + data.stderr)
					return
				} else {
					temperature = parseFloat(data.stdout)
					if (isNaN(temperature))
						return
				}

				if (gpuAppended == false) {
					gpuTempModel.append({'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
					gpuAppended = true
				} else {
					gpuTempModel.set(dataName,{'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
				}
			}
		}

		Plasma5Support.DataSource {
			id: amdDataSource
			engine: 'executable'
			interval: if (main.showGpuTemp) main.updateInterval * 1000; else 0

			connectedSources: [ 'amdconfig --od-gettemperature | tail -1 | cut -c 43-44' ]

			property bool gpuAppended: false

			onNewData: function(data) {
				var dataName = "AMD";
				var gpuLabelStr = "AMD GPU"
				var temperature = 0
				if (data['exit code'] != 0 || data.stdout == '') {
	//                print('AMD data error: ' + data.stderr)
					return
				} else {
					temperature = parseFloat(data.stdout)
					if (isNaN(temperature))
						return
				}

				if (gpuAppended == false) {
					gpuTempModel.append({'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
					gpuAppended = true
				} else {
					gpuTempModel.set(dataName,{'val':temperature, 'dataUnits':'°C', 'gpuLabelStr':gpuLabelStr});
				}
			}
		}

		Loader {
			id: loader
			anchors.fill: parent
			source: "skins/DefaultSkin.qml"
		}
	}
}

#!/bin/sh

cd "${0%/*}"


ACTION="-i"

if [[ $(kpackagetool6 -l -t "Plasma/Applet" | grep "org.kde.simpleMonitor" | wc -l) -gt 0 ]]; then
	ACTION="-u"
fi


# Install or upgrade the Simple System Monitor plasmoid.
kpackagetool6 -t "Plasma/Applet" ${ACTION} ./plasmoid

# Install the Simple System Monitor icon.
ICON_PATH=${HOME}/.local/share/icons/hicolor/scalable/apps/
mkdir -p ${ICON_PATH}
cp plasmoid/contents/images/simpleMonitor_icon.svg ${ICON_PATH}


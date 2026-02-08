import QtQuick
import Quickshell
import Quickshell.Io
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen
  property var pluginApi: null

  icon: "refresh"
  tooltipText: "Nobara Updater"

  Process {
    id: updaterProcess
    command: ["sh", "-c", "kitty -e sudo nobara-sync cli &"]
  }

  onClicked: {
    updaterProcess.running = true
  }
}

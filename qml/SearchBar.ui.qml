import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.Window

Item {
  id: sbContainer

  function listProperties(item) {
      var properties = "";
      for (var p in item) if (typeof item[p] != "function") {
          properties += (p + ": " + item[p] + "\n");
      }
      return properties;
  }

  function listFunctions(item) {
      var functions = "";
      for (var f in item) if (typeof item[f] == "function") {
          functions += (f + ": " + item[f] + "\n");
      }
      return functions;
  }

  GridLayout {
    id: sbGridLayout

    columns: 2
    columnSpacing: 10
    anchors.fill: parent

    TextField {
      id: sbTextField
      font.pointSize: 20
      Layout.preferredWidth: 656
      Component.onCompleted: {
        console.log("Width: " + width)
      }
      Loader {
        id: sbSearchLoader
        width: parent.width
        anchors.top: sbTextField.bottom
        onStatusChanged: {
          console.log("sbSearchLoader status: " + parent)
        }
      }
    }

    Button {
      id: sbSearchButton
      objectName: "sbSearchButton"
      text: "Search"
      font.pointSize: 20
      Layout.alignment: Qt.AlignRight
      onClicked: {
        console.log("clickInitiator check: " + clickInitiator)

        if (clickInitiator == "swSongSearchButton") {
          window.songButtonClicked(sbTextField.text)
          sbSearchLoader.sourceComponent = sbListViewComponent
        } else if (clickInitirator == "swPlaylistSearchButton") {
          window.playlistButtonClicked(sbTextField.text)
          sbSearchLoader.sourceComponent = sbListViewComponent
        } else if (clickInitiator == "swSelfPlaylistButton") {
          window.selfButtonClicked(sbTextField.text)
          sbSearchLoader.sourceComponent = sbListViewComponent
        }
      }
    }
  
    Component {
      id: sbListViewComponent

      ListView {
        id: sbListView
        height: 300
        clip: true
        model: listModel
        delegate: Component {
          Rectangle {
            width: sbListView.width
            height: 40
            color: ((index % 2 == 0)?"#222":"#111")

            Text {
              id: title
              elide: Text.ElideRight
              color: "white"
              text: item
              font.bold: true
              anchors.leftMargin: 10
              anchors.fill: parent
              verticalAlignment: Text.AlignVCenter
            }
          }
        }
        Component.onCompleted: {
          console.log("model: " + sbListView.model)
        }
      }
    }
  }


}

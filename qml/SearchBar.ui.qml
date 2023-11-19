import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.Window

Item {
  id: sbContainer

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
          console.log("sbSearchLoader status: " + status)
        }
      }
    }

    Button {
      id: sbSearchButton
      text: "Search"
      font.pointSize: 20
      Layout.alignment: Qt.AlignRight
      onClicked: {
        sbSearchLoader.sourceComponent = sbListViewComponent
      }
    }
  
    Component {
      id: sbListViewComponent

      ListView {
        id: sbListView
        height: 300
        delegate: Component {
          Rectangle {
            width: sbListView.width
            height: 40
            color: ((index % 2 == 0)?"#222":"#111")

            Text {
              id: title
              elide: Text.ElideRight
              color: "white"
              text: displayText
              font.bold: true
              anchors.leftMargin: 10
              anchors.fill: parent
              verticalAlignment: Text.AlignVCenter
            }
          }
        }
        Component.onCompleted: {
          sbListView.model = playlistModel.get_playlist_model()
          console.log("sbListView model type: " + typeof(sbListView.model))
          console.log("sbListView completed")
          console.log("sbListView width: " + width)
        }
      }
    }
  }


}

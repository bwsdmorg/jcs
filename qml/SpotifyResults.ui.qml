import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.VirtualKeyboard
import QtQuick.Window

Item {
  id: srContainer

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
  


  ListView {
    id: srListView
    height: 300
    width: 656
    clip: true
    model: listModel
    delegate: Component {
      Rectangle {
        width: srListView.width
        height: 40
        color: ((index % 2 == 0)?"#222":"#111")

        Text {
          id: title
          elide: Text.ElideRight
          color: "white"
          font.bold: true
          anchors.leftMargin: 10
          anchors.fill: parent
          verticalAlignment: Text.AlignVCenter
        }

        Component.onCompleted: {
          if (clickInitiator == "swSelfPlaylistButton") {
            title.text = item[0]
          } else {
            title.text = item[0] + " by " + item[1]
          }
        } 

        MouseArea {
          id: srListViewMouseArea
          anchors.fill: parent
          onClicked: {
            console.log("Mouse area clicked: " + item)
            console.log("Item[2]: " + item[1])
            window.listViewClicked(item[1])
          }
        }
      }
    }
        
    Component.onCompleted: {
      console.log("ListView Loaded")
    }
  }
}


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  Rectangle {
    id: routeAddressRectangle
    anchors.left: parent.left
    anchors.top: parent.top
    width: 500
    height: 500
    color: "grey"

    Component.onCompleted: {
      console.log("Rectangle created")
    }
  }
}

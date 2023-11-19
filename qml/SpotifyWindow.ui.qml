import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.Window

Item {
  id: swRoot

  Rectangle {
    id: spotifyWindow

    height: 600
    width: 800
    color: "#1DB954"

    Label {
      id: swTitle
      color: "#fff"
      text: "Spotify"
      font.bold: true
      font.pointSize: 16
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
      id: swContainer

      height: parent.height
      width: parent.width
      anchors.rightMargin: 20
      anchors.leftMargin: 20
      anchors.bottomMargin: 20
      anchors.topMargin: 20
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: swTitle.bottom

      GridLayout{
        id: swGridLayout

        columns: 5
        rowSpacing: 10
        anchors.fill: parent
        
        //ListView {
        //  id: swPlaylistList
        //  Layout.fillHeight: true
        //  Layout.fillWidth: true
        //  Layout.columnSpan: 2
        //  model: playlistModel
        //  delegate: Component {
        //    Rectangle {
        //      width: swPlaylistList.width
        //      height: 40
        //      color: ((index % 2 == 0)?"#222":"#111")

        //      Text {
        //        id: title
        //        elide: Text.ElideRight
        //        text: displayText
        //        color: "white"
        //        font.bold: true
        //        anchors.leftMargin: 10
        //        anchors.fill: parent
        //        verticalAlignment: Text.AlignVCenter
        //      }
        //    }
        //  }
        //}

        GridLayout {
          id:swDisplayContainer
          Layout.columnSpan: parent.columns
          Layout.alignment: Qt.AlignTop
          Layout.fillWidth: true

          columns: 3


          Button {
            id: swSongSearchButton
            text: "Search Songs"
            font.pointSize: 20
            Layout.fillWidth: true
            onClicked: {
              swSearchLoader.source = "Search.qml"
            }
          }

          Button {
            id: swPlaylistSearchButton
            text: "Search Playlists"
            font.pointSize: 20
            Layout.fillWidth: true
          }

          Button {
            id: swMyPlaylistButton
            text: "My Playlists"
            font.pointSize: 20
            Layout.fillWidth: true
          }


          Loader {
            id: swSearchLoader
            onStatusChanged: {
              console.log(status)
            }
          }
        }


        RowLayout {
          id: swPlayerContainer
          Layout.columnSpan: parent.columns
          Layout.alignment: Qt.AlignBottom
          

          Button {
            id: swPlayerReverse
            text: "<<"
            font.pointSize: 20
            height: 50
          }

          Button {
            id: swPlayerPlay
            text: "|>"
            font.pointSize: 20

          }

          ProgressBar {
            value: 0.5
            Layout.fillWidth: true
          }

          Button {
            id: swPlayerForward
            text: ">>"
            font.pointSize: 20
          }
        }
      }
    }
  }
}

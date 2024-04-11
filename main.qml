import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.VirtualKeyboard
import "qml"

Window {
    id: window
    width: 1200
    height: 800
    visible: true

    property string mapboxgl_api_token
    property var wnd

    signal songButtonClicked(var songSearchString)
    signal playlistButtonClicked(var playlistSearchString)
    signal selfButtonClicked()

    signal listViewClicked(var uri)

    signal playerPrevButtonClicked()
    signal playerPlayButtonClicked()
    signal playerPauseButtonClicked()
    signal playerNextButtonClicked()


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

    function showRoute(startCoordinate, endCoordinate) {
      routeQuery.addWaypoint(startCoordinate)
      routeQuery.addWaypoint(endCoordinate)
      routeModel.update()
    }

    Plugin {
        id: mapPlugin
        name: "osm"

    }

    GridLayout {
        id: gridLayout
        columns: 2
        rows: 4
        columnSpacing: 0
        rowSpacing: 0
        flow: GridLayout.TopToBottom
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            id: speedView
            width: 200
            height: 200
            color: "red"
            border.color: "black"
            border.width: 1
            Layout.column: 0
            Layout.row: 0
            Layout.alignment: Qt.AlignTop
        }

        Button {
          id: routeAddressButton

          checkable: true
          text: "Search/Routing"
          Layout.preferredHeight: 200
          Layout.fillWidth: true
          Layout.column: 0
          Layout.row: 1
          Layout.alignment: Qt.AlignTop

          onToggled: {
            console.log("We toggled the button")
            if (checked) {
              var component = Qt.createComponent("./qml/RouteAddress.qml", navMap)
            
              wnd = component.createObject(navMap, {
                  "x": 50,
                  "y": 50
              });
            } else {
              wnd.destroy();
            }
          }
        }

        Button {
          id: spotifyButton

          checkable: true
          text: "Open Spotify"
          Layout.preferredHeight: 200
          Layout.fillWidth: true
          Layout.column: 0
          Layout.row: 2
          Layout.alignment: Qt.AlignTop

          onToggled: {
            console.log("We toggled the spotify button")
            if (checked) {
              var component = Qt.createComponent("./qml/Spotify.qml", navMap)
            
              wnd = component.createObject(navMap, {
                  "x": 50,
                  "y": 50
              });
            } else {
              wnd.destroy();
            }
          }
        }


        Rectangle {
          id: spotifyControls

          color: "#1DB954"
          Layout.fillWidth: true
          Layout.fillHeight: true

          ColumnLayout {

            // Volume Buttons
            RowLayout {

              Layout.leftMargin: 2
              Layout.alignment: Qt.AlignCenter
              Layout.fillWidth: true
              Layout.preferredHeight: spotifyControls.height/3

              RoundButton {
                id: muteButton
                implicitWidth: spotifyControls.width/3 - parent.spacing
                implicitHeight: spotifyControls.height/3 - parent.spacing
                icon.height: 50
                icon.width: 50
                icon.source: "./images/round-volume-mute.svg"
                radius: 50
                // onClicked: { muted = !muted }
                onClicked: { console.log(spotifyControls.width)}
              }
              
              RoundButton {
                id: volDownButton
                implicitWidth: spotifyControls.width/3 - parent.spacing
                implicitHeight: spotifyControls.height/3 - parent.spacing
                icon.height: 50
                icon.width: 50
                icon.source: "./images/round-volume-down.svg"
                radius: 50
                // onClicked: { muted = !muted }
                onClicked: { console.log(parent.height)}
              }
              
              RoundButton {
                id: volUpButton
                implicitWidth: spotifyControls.width/3 - parent.spacing
                implicitHeight: spotifyControls.height/3 - parent.spacing
                icon.height: 50
                icon.width: 50
                icon.source: "./images/round-volume-up.svg"
                radius: 50
                // onClicked: { muted = !muted }
                onClicked: { console.log(parent.height)}
              }
            } 

            // Volume Slider

            Slider {
              id: volSlider
              from: 0
              to: 100

              Layout.margins: 5
              Layout.fillWidth: true
              Layout.preferredHeight: spotifyControls.height / 3

              handle: Rectangle {
                x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2

                implicitHeight: 50
                implicitWidth: 50
                radius: 25
              }
            }

            // Song Title

            Item {
              id: marquee

              property string msg: "Long ass message for no reason"
              property color fontColor: 'white'
              property int fontSize: 20

              Layout.fillWidth: true
              Layout.preferredHeight: spotifyControls.height / 3

              Text {
                id: marqueeText
                anchors.verticalCenter: marquee.verticalCenter
                height: marquee.height
                font.family: 'Droid Sans Fallback'
                font.pointSize: marquee.fontSize
                color: 'white'
                text: marquee.msg

                Component.onCompleted: {
                  console.log(listProperties(marquee))
                }


                SequentialAnimation on x {
                  loops: Animation.Infinite
                  PropertyAnimation { to: marquee.width; duration: 10000}
                  PropertyAnimation { to: -marqueeText.width; duration: 10000}
                  running: true

                }
              }
            }
          }
        }
        
        Map {
            id: navMap
            
            property string fromAddress
            property string toAddress

            plugin: mapPlugin
            Layout.rowSpan: gridLayout.rows
            Layout.column: 1
            Layout.row: 0
            center: QtPositioning.coordinate(59.91, 10.75) // Oslo
            zoomLevel: 14
            width: window.width - 200
            height: window.height
            

            RouteQuery {
                id: routeQuery
            }

            RouteModel {
                id: routeModel
                plugin: mapPlugin
                query: routeQuery
                onStatusChanged: {
                  if (status == RouteModel.Ready) {
                    navMap.center = geocodeModel.startCoordinate
                    navMap.zoomLevel = 14
                    navMap.visibleRegion = routeModel.get(0).bounds
                    console.log("RouteModel count: " + routeModel.count)
                  }
                }
            }

            MapItemView {
              parent: navMap
              model: routeModel
              delegate: routeDelegate
              autoFitViewport: true
            }

            Component {
              id: routeDelegate

              MapRoute {
                id: route
                route: routeData
                line.color: "blue"
                line.width: 5
                smooth: true
                opacity: 0.8
              }
            }


            // If only 1, then search that location.
            // pinpoint location on map
            // If 2 or more, get the route
            
            GeocodeModel {
              id: geocodeModel

              property int success: 0
              property variant startCoordinate
              property variant endCoordinate

              plugin: mapPlugin

              onCountChanged: {
                  if (success == 1 && count == 1) {
                      query = navMap.toAddress
                      update();
                  }
              }

              onStatusChanged: {
                  if ((status == GeocodeModel.Ready) && (count > 0)) {
                      success++
                      if (success == 1) {
                          startCoordinate.latitude = get(0).coordinate.latitude
                          startCoordinate.longitude = get(0).coordinate.longitude
                          navMap.center = startCoordinate
                          marker.coordinate = startCoordinate
                          navMap.addMapItem(marker)
                      }
                      if (success == 2) {
                          endCoordinate.latitude = get(0).coordinate.latitude
                          endCoordinate.longitude = get(0).coordinate.longitude
                          success = 0
                          if (startCoordinate.isValid && endCoordinate.isValid)
                              showRoute(startCoordinate,endCoordinate)
                          //else
                              //goButton.enabled = true
                      }
                  } else if ((status == GeocodeModel.Ready) || (status == GeocodeModel.Error)) {
                      var st = (success == 0 ) ? "start" : "end"
                      success = 0
                      if ((status == GeocodeModel.Ready) && (count == 0 )) {
                          console.log("Geocode Error " + "Unsuccessful geocode");
                          //goButton.enabled = true;
                      }
                      else if (status == GeocodeModel.Error) {
                          console.log("Geocode Error unable to find location for the" + " " + st + " " + "point")
                          //goButton.enabled = true;
                      }
                      else if ((status == GeocodeModel.Ready) && (count > 1 )) {
                          console.log("Ambiguous geocode" + count + " " + "results found for the" + " " + st + " " + "point, please specify location")
                          //goButton.enabled = true;
                      }
                  }
              }
            }

            MapQuickItem {
              id: marker
              anchorPoint.x: image.width/2
              anchorPoint.y: image.height
              
              sourceItem: Image {
                id: image
                source: "./images/mapMarker.png"
              }
            }

            Button {
              id: geocodeButton
              text: "Geocode Test Button"
              onClicked: {
                navMap.fromAddress = "1415 S Congress Ave, Austin, TX"
                navMap.toAddress = ""
                geocodeModel.startCoordinate = QtPositioning.coordinate()
                geocodeModel.endCoordinate = QtPositioning.coordinate()
                geocodeModel.query = navMap.fromAddress
                geocodeModel.update()
              }
            }

            Button {
              id: zoomInButton
              anchors.left: geocodeButton.right
              text: "Zoom In"
              onClicked: {
                navMap.zoomLevel += 1
              }
            }
            
            Button {
              id: zoomOutButton
              anchors.left: zoomInButton.right
              text: "Zoom Out"
              onClicked: {
                navMap.zoomLevel -= 1
              }
            }

            Button {
              id: routeButton
              anchors.left: zoomOutButton.right
              text: "Route Test Button"
              onClicked: {
                navMap.fromAddress = "900 Congress Ave, Austin, TX"
                navMap.toAddress = "1415 S Congress Ave, Austin, TX"
                geocodeModel.startCoordinate = QtPositioning.coordinate()
                geocodeModel.endCoordinate = QtPositioning.coordinate()
                geocodeModel.query = navMap.fromAddress
                geocodeModel.update()
              }
            }
            
            Connections {
              function onSendAddresses(fromAddress, toAddress) {
                navMap.fromAddress = fromAddress
                console.log("From address entered: " + navMap.fromAddress)
                navMap.toAddress = toAddress
                console.log("To address entered: " + navMap.toAddress)
                geocodeModel.startCoordinate = QtPositioning.coordinate()
                geocodeModel.endCoordinate = QtPositioning.coordinate()
                geocodeModel.query = navMap.fromAddress
                geocodeModel.update()

              }

              ignoreUnknownSignals: true
              target: wnd
            }
        }

    }
}

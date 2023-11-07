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
        rows: 5
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
          width: 200
          Layout.fillWidth: true
          Layout.fillHeight: true
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

        // TODO Add travel optimizations/options to routes

        // TODO: Zoom on scroll wheel/pinch
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

    // TODO: Fix input panel
    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}

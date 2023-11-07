import QtLocation 5.6
import QtPositioning 5.6
import QtQuick 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.1
import QtQuick.Window 2.14

Item {
    id: rafRoot

    property alias fromAddress: rafFromInput
    property alias toAddress: rafToInput
    property alias goButton: rafAcceptButton
    property alias clearButton: rafClearButton
    property alias routeAddressWindow: routeAddressWindow

    Rectangle {
        id: routeAddressWindow

        height: 250
        width: 400
        color: "#46a2da"

        Label {
            id: rafTitle

            color: "#fff"
            text: "Route Address"
            font.bold: true
            font.pointSize: 16
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id: rafInputContainer

            anchors.rightMargin: 20
            anchors.leftMargin: 20
            anchors.bottomMargin: 20
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rafTitle.bottom

            GridLayout {
                id: rafGridLayout

                rowSpacing: 10
                rows: 1
                columns: 2
                anchors.fill: parent

                Label {
                    id: rafFromLabel

                    text: "From"
                    font.bold: true
                    Layout.columnSpan: 2
                }

                TextInput {
                    id: rafFromTextInput

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    TextField {
                        id: rafFromInput

                        width: rafGridLayout.width
                        height: parent.height
                    }

                }

                Label {
                    id: rafToLabel

                    text: "To"
                    font.bold: true
                    Layout.columnSpan: 2
                }

                TextInput {
                    id: rafToTextInput

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    TextField {
                        id: rafToInput

                        width: rafGridLayout.width
                        height: parent.height
                    }

                }

                RowLayout {
                    id: rafOptionsLayout

                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignRight

                    Button {
                        id: rafAcceptButton

                        text: "Proceed"
                    }

                    Button {
                        id: rafClearButton

                        text: "Clear"
                    }

                }

                Item {
                    Layout.fillHeight: true
                    Layout.columnSpan: 2
                }

            }

        }

    }

}


import QtQuick
import QtLocation
import QtPositioning

RouteAddressForm {

  signal sendAddresses(var fromAddress, var toAddress)

  Component.onCompleted: {
    console.log("Route Address Form completed")
  }

  goButton.onClicked: {
    sendAddresses(fromAddress.text, toAddress.text)
  }
}

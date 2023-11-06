# This Python file uses the following encoding: utf-8
import os
import sys
import json
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


if __name__ == "__main__":

    # opens environment variables stored in the env.json file
    f = open('env.json')
    data = json.load(f)

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    
    # assigns the api key to the qml property mapboxgl_api_key
    engine.rootObjects()[0].setProperty('mapboxgl_api_key', data['MAPBOXGL_API_KEY'])

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

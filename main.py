# This Python file uses the following encoding: utf-8
import os
import sys
import json
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from pathlib import Path
from PySide6.QtCore import QObject, QAbstractListModel, Qt, QModelIndex, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class GetMyPlaylists(QObject):
    def __init__(self, query, parent=None):
        super().__init__(parent)
        self._query = query

    @Slot()
    def get_playlist_model(self):
        data_list = []
        print("Getting Playlist Model")
        results = self._query
        for i, item in enumerate(results["items"]):
            data_list.append(item["name"])
            print("%d %s" % (i, item["name"]))

        self.model = ListModel(data_list)
        return self.model


class ListModel(QAbstractListModel):
    TextRole = Qt.UserRole + 1

    def __init__(self, data, parent=None):
        super().__init__(parent)
        self._data = data

    def rowCount(self, parent):
        return len(self._data)

    def data(self, index, role):
        if index.isValid() and role == self.TextRole:
            return self._data[index.row()]
        return None

    def roleNames(self):
        roles = {self.TextRole: b"displayText"}
        return roles

    @Slot()
    def get(self, row):
        if 0 <= row < self.rowCount(QModelIndex()):
            return self._data[row]


# def get_devicelist_model(query):
#    data_list = []
#    results = query
#    print(results)
#    for i, item in enumerate(results["devices"]):
#        data_list.append(item["name"])
#        print("%d %s" % (i, item["name"]))
#
#    model = ListModel(data_list)
#    return model


if __name__ == "__main__":
    # opens environment variables stored in the env.json file
    f = open("env.json")
    data = json.load(f)

    os.environ["SPOTIPY_CLIENT_ID"] = data["SPOTIPY_CLIENT_ID"]
    os.environ["SPOTIPY_CLIENT_SECRET"] = data["SPOTIPY_CLIENT_SECRET"]
    os.environ["SPOTIPY_REDIRECT_URI"] = data["SPOTIPY_REDIRECT_URI"]

    scope = "playlist-read-private user-read-playback-state"

    sp = spotipy.Spotify(auth_manager=SpotifyOAuth(scope=scope))

    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    playlist_model = GetMyPlaylists(sp.current_user_playlists())
    # devicelist_model = get_devicelist_model(sp.devices())
    context = engine.rootContext()
    context.setContextProperty("playlistModel", playlist_model)
    # context.setContextProperty("deviceModel", devicelist_model)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    # assigns the api key to the qml property mapboxgl_api_key
    engine.rootObjects()[0].setProperty("mapboxgl_api_key", data["MAPBOXGL_API_KEY"])
    engine.rootObjects()[0].setProperty("spotipy_client_id", data["SPOTIPY_CLIENT_ID"])
    engine.rootObjects()[0].setProperty(
        "spotipy_client_secret", data["SPOTIPY_CLIENT_SECRET"]
    )
    engine.rootObjects()[0].setProperty(
        "spotipy_redirect_uri", data["SPOTIPY_REDIRECT_URI"]
    )

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

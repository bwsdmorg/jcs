# This Python file uses the following encoding: utf-8
import os
import sys
import json
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from pathlib import Path
from PySide6.QtCore import (
    QObject,
    QAbstractListModel,
    Qt,
    QModelIndex,
    Slot,
    Signal,
)
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class ListModel(QAbstractListModel):
    ItemRole = Qt.UserRole + 1

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._items)

    def data(self, index, role):
        if 0 <= index.row() < self.rowCount() and index.column() == 0:
            if role == ListModel.ItemRole:
                return self._items[index.row()]
        return None

    def roleNames(self):
        return {ListModel.ItemRole: b"item"}

    @Slot()
    def appendItem(self, item):
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self._items.append(item)
        self.endInsertRows()

    @Slot()
    def updateItem(self, index, newItem):
        if 0 <= index < self.rowCount():
            self._items[index] = newItem
            self.dataChanged.emit(
                self.index(index, 0), self.index(index, 0), [ListModel.ItemRole]
            )

    @Slot()
    def removeItem(self, index):
        if 0 <= index < self.rowCount():
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._items[index]
            self.endRemoveRows()

    @Slot()
    def clear(self):
        while self.rowCount() >= 1:
            self.removeItem(self.rowCount() - 1)


class SignalHandler(QObject):
    playlistButtonClicked = Signal()
    songButtonClicked = Signal()
    selfButtonClicked = Signal()
    listViewClicked = Signal()

    def __init__(self, engine, listModel):
        super().__init__()
        self._engine = engine
        self._listModel = listModel

    @Slot()
    def handleSongButtonClicked(self, signal):
        print("Recieved song signal")
        song_model = getSongModel(
            sp.search(q=signal, type="track", market="US"),
            self._listModel,
        )
        self._engine.rootContext().setContextProperty("songModel", song_model)
        self.songButtonClicked.emit()

    @Slot()
    def handlePlaylistButtonClicked(self, signal):
        print("Recieved playlist signal")
        playlist_model = getPlaylistModel(
            sp.search(q=signal, type="playlist", market="US"),
            self._listModel,
        )
        self._engine.rootContext().setContextProperty("playlistModel", playlist_model)
        self.playlistButtonClicked.emit()

    @Slot()
    def handleSelfButtonClicked(self):
        print("Recieved self playlist signal")
        self_model = getSelfModel(sp.current_user_playlists(), self._listModel)
        self._engine.rootContext().setContextProperty("selfModel", self_model)
        self.selfButtonClicked.emit()

    @Slot()
    def handleListViewClicked(self, deviceId, uri):
        print("Recieved listView signal")
        sp.start_playback(device_id=deviceId, uris=[uri])


def getSongModel(query, listModel):
    print("Getting Song Model")
    listModel.clear()
    results = query
    for i, item in enumerate(results["tracks"]["items"]):
        tempList = []
        tempList.append(item["name"])
        tempList.append(item["artists"][0]["name"])
        tempList.append(item["uri"])
        listModel.appendItem(tempList)
        print(
            "%d %s %s %s" % (i, item["name"], item["artists"][0]["name"], item["uri"])
        )

    return listModel


def getPlaylistModel(query, listModel):
    print("Getting Playlist Model")
    listModel.clear()
    results = query
    for i, item in enumerate(results["playlists"]["items"]):
        tempList = []
        tempList.append(item["name"])
        tempList.append(item["owner"]["display_name"])
        tempList.append(item["uri"])
        listModel.appendItem(tempList)
        print("%d %s %s" % (i, item["name"], item["owner"]["display_name"]))

    return listModel


def getSelfModel(query, listModel):
    print("Getting Self Model")
    listModel.clear()
    results = query
    for i, item in enumerate(results["items"]):
        tempList = []
        tempList.append(item["name"])
        tempList.append(item["uri"])
        listModel.appendItem(tempList)
        print("%d %s" % (i, item["name"]))

    return listModel


def get_devicelist_model(query):
    results = query
    for i, item in enumerate(results["devices"]):
        print("%d %s %s" % (i, item["name"], item["id"]))


if __name__ == "__main__":
    # opens environment variables stored in the env.json file
    f = open("env.json")
    data = json.load(f)

    os.environ["SPOTIPY_CLIENT_ID"] = data["SPOTIPY_CLIENT_ID"]
    os.environ["SPOTIPY_CLIENT_SECRET"] = data["SPOTIPY_CLIENT_SECRET"]
    os.environ["SPOTIPY_REDIRECT_URI"] = data["SPOTIPY_REDIRECT_URI"]

    scope = "playlist-read-private user-read-playback-state user-modify-playback-state"

    sp = spotipy.Spotify(auth_manager=SpotifyOAuth(scope=scope))

    get_devicelist_model(sp.devices())

    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()

    qml_file = Path(__file__).resolve().parent / "main.qml"

    list_model = ListModel()
    engine.rootContext().setContextProperty("listModel", list_model)
    signal_handler = SignalHandler(engine, list_model)
    engine.rootContext().setContextProperty("signalHandler", signal_handler)

    engine.load(qml_file)

    engine.rootObjects()[0].songButtonClicked.connect(
        signal_handler.handleSongButtonClicked
    )
    engine.rootObjects()[0].playlistButtonClicked.connect(
        signal_handler.handlePlaylistButtonClicked
    )
    engine.rootObjects()[0].selfButtonClicked.connect(
        signal_handler.handleSelfButtonClicked
    )
    engine.rootObjects()[0].listViewClicked.connect(
        signal_handler.handleListViewClicked
    )
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

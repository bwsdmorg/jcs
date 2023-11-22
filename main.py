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
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType


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


class SignalHandler(QObject):
    buttonClicked = Signal()

    def __init__(self, engine, listModel):
        super().__init__()
        self._engine = engine
        self._listModel = listModel

    @Slot()
    def handleButtonClicked(self):
        print("Recieved signal")
        playlist_model = getPlaylistModel(sp.current_user_playlists(), self._listModel)
        self._engine.rootContext().setContextProperty("playlistModel", playlist_model)
        self.buttonClicked.emit()


@Slot()
def getPlaylistModel(query, listModel):
    print("Getting Playlist Model")
    results = query
    for i, item in enumerate(results["items"]):
        listModel.appendItem(item["name"])
        print("%d %s" % (i, item["name"]))

    return listModel


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

    # playlist_model = getPlaylistModel(sp.current_user_playlists())
    # devicelist_model = get_devicelist_model(sp.devices())
    # context = engine.rootContext()
    # context.setContextProperty("playlistModel", playlist_model)
    # context.setContextProperty("deviceModel", devicelist_model)

    # context_setter = ContextSetter(engine, "playlistModel", playlist_model)

    qml_file = Path(__file__).resolve().parent / "main.qml"

    list_model = ListModel()
    engine.rootContext().setContextProperty("listModel", list_model)
    signal_handler = SignalHandler(engine, list_model)
    engine.rootContext().setContextProperty("signalHandler", signal_handler)

    engine.load(qml_file)

    engine.rootObjects()[0].buttonClicked.connect(signal_handler.handleButtonClicked)
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

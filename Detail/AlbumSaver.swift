import Foundation
import ManagedModels
import RealmSwift
import RxSwift

protocol AlbumSaveable: AnyObject {
    func saveAlbum(with tracks: TrackResponse, and artist: ArtistResponse) -> Completable
}

final class AlbumSaver: AlbumSaveable {
    func saveAlbum(with tracks: TrackResponse, and artist: ArtistResponse) -> Completable {
        return Completable.create(
            subscribe: { subscriber -> Disposable in
                let realm = Realm.get()
                let disposable = Disposables.create()

                let savedAlbumsIndex = realm.objects(AlbumManagedModel.self)
                    .index(
                        matching: "title = %@ AND artist.title = %@",
                        tracks.album.name,
                        artist.artist.name
                    )
                guard savedAlbumsIndex == nil else {
                    subscriber(.completed)
                    return disposable
                }

                let savingTracks = tracks.album.tracks.track.map { track -> TrackManagedModel in
                    let savingTrack = TrackManagedModel()
                    savingTrack.title = track.name
                    savingTrack.duration = Double(track.duration) ?? 0
                    return savingTrack
                }

                realm.beginWrite()
                let savingArtist = realm.create(
                    ArtistManagedModel.self,
                    value: ["title": artist.artist.name],
                    update: .modified
                )
                savingArtist.information = artist.artist.bio.content
                savingArtist.imageURL = artist.artist.image.lazy.filter { $0.size == .large }.compactMap { $0.text }.first ?? ""

                let newAlbum = realm.create(
                    AlbumManagedModel.self,
                    value: [
                        "title": tracks.album.name,
                        "artist": savingArtist,
                    ],
                    update: .modified
                )
                newAlbum.imageURL = tracks.album.image.lazy.filter { $0.size == .large }.compactMap { $0.text }.first

                newAlbum.tracks.append(objectsIn: savingTracks)
                savingArtist.albums.append(newAlbum)

                realm.add(savingArtist, update: .modified)

                do {
                    try realm.commitWrite()
                } catch {
                    subscriber(.error(error))
                    realm.cancelWrite()
                    return disposable
                }

                subscriber(.completed)
                return disposable
            }
        )
    }

    enum Error: Swift.Error {
        case failedToSave(Swift.Error)
    }
}

import RealmSwift

public final class TrackManagedModel: Object {
    @objc public dynamic var title: String = ""
    @objc public dynamic var duration: Double = 0
    public let albums = LinkingObjects(fromType: AlbumManagedModel.self, property: "tracks")
}

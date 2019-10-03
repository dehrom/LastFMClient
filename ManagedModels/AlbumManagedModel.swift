import RealmSwift

public final class AlbumManagedModel: Object {
    @objc public dynamic var title: String = ""
    @objc public dynamic var imageURL: String?
    @objc public dynamic var url: String?
    @objc public dynamic var artist: ArtistManagedModel?
    public let tracks = List<TrackManagedModel>()

    public override static func primaryKey() -> String? {
        return "title"
    }
}

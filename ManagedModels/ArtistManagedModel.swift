import RealmSwift

public final class ArtistManagedModel: Object {
    @objc public dynamic var title: String = ""
    @objc public dynamic var imageURL: String = ""
    @objc public dynamic var information: String = ""
    public let albums = List<AlbumManagedModel>()

    public override static func primaryKey() -> String? {
        return "title"
    }
}

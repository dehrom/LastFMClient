import RealmSwift

public final class ArtistManagedModel: Object {
    dynamic var title: String = ""
    dynamic var imageURL: String = ""
    dynamic var information: String = ""
    var albums = List<AlbumManagedModel>()
}

import Foundation

final class ViewModelTransformer {
    func transform(from response: AlbumsResponse, with titlesOfSavedAlbums: [String]) -> ViewModel {
        let albums = (response.topalbums.album.filter { $0.name != "(null)" })
        guard
            albums.isEmpty == false
        else { return ViewModel.empty }

        let img = UIImage(named: "saved")?.af_imageScaled(to: CGSize(width: 15, height: 15)) ?? UIImage()
        let rows = albums.map { album -> ViewModel.Album in
            let imageURL = album.image.lazy.filter { $0.size == .large }.compactMap { URL(string: $0.text) }.first
            let isLoaded = titlesOfSavedAlbums.contains(album.name)
            
            let title = { () -> NSAttributedString in
                let font = UIFont.systemFont(ofSize: 12)
                switch isLoaded {
                case true:
                    return NSAttributedString(image: img, string: album.name, font: font)
                case false:
                    return NSAttributedString(string: album.name, attributes: [.font: font])
                }
            }
            
            return .init(identity: album.name, title: title(), imageURL: imageURL)
        }
        return .init(sections: [.init(items: rows)])
    }
}

extension NSAttributedString {
    convenience init(image: UIImage, string: String, font: UIFont) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(
            x: 0,
            y: -((image.size.height - font.capHeight) / 2).rounded(.down),
            width: image.size.width,
            height: image.size.height
        )
        let resultString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        resultString.append(NSAttributedString(string: " \(string)", attributes: [.font: font]))
        
        self.init(attributedString: resultString)
    }
}

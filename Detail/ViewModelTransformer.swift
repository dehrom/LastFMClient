import Foundation
import ManagedModels

final class ViewModelTransformer {
    func transform(_ from: TrackResponse, loadingState: LoadingState = .preloading) -> ViewModel {
        let about = ViewModel.Row.about(
            .init(
                title: from.album.name,
                artistName: from.album.artist,
                imageURL: from.album.image.lazy.filter { $0.size == .extralarge }.compactMap { URL(string: $0.text) }.first,
                loadingState: loadingState.asButtonLoadingState()
            )
        )

        let tracks = from.album.tracks.track.enumerated().map { item -> ViewModel.Row in
            let numberString = NSAttributedString(
                string: "\(item.offset + 1)",
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.6),
                ]
            )

            let duration = Int(item.element.duration)?.asDateString(with: .minute) ?? "null"
            let durationString = NSAttributedString(
                string: duration,
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
            )

            return .track(
                .init(
                    title: item.element.name,
                    number: numberString,
                    duration: durationString
                )
            )
        }

        let totalDuration = from.album
            .tracks
            .track
            .compactMap {
                Int($0.duration)
            }.reduce(into: 0, +=)
            .asDateString(
                with: [
                    .hour,
                    .minute,
                ]
            )

        let information = ViewModel.Row.information(
            NSAttributedString(
                string: "Total Duration: \(totalDuration)",
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
            )
        )

        return .models(
            [
                .init([about]),
                .init(tracks),
                .init([information]),
            ]
        )
    }

    func transform(_ from: AlbumManagedModel) -> ViewModel {
        let about = ViewModel.Row.about(
            .init(
                title: from.title,
                artistName: from.artist?.title ?? "Unknown",
                imageURL: from.imageURL.flatMap { URL(string: $0) },
                loadingState: .loaded
            )
        )

        let tracks = from.tracks.toArray().enumerated().map { item -> ViewModel.Row in
            let numberString = NSAttributedString(
                string: "\(item.offset + 1)",
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.6),
                ]
            )

            let duration = Int(item.element.duration).asDateString(with: .minute)
            let durationString = NSAttributedString(
                string: duration,
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
            )

            return .track(
                .init(
                    title: item.element.title,
                    number: numberString,
                    duration: durationString
                )
            )
        }

        let totalDuration = from.tracks
            .toArray()
            .compactMap {
                Int($0.duration)
            }.reduce(into: 0, +=)
            .asDateString(
                with: [
                    .hour,
                    .minute,
                ]
            )

        let information = ViewModel.Row.information(
            NSAttributedString(
                string: "Total Duration: \(totalDuration)",
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
            )
        )

        return .models(
            [
                .init([about]),
                .init(tracks),
                .init([information]),
            ]
        )
    }
}

extension ViewModelTransformer {
    enum LoadingState: Int {
        case preloading
        case loading
        case loaded
        case unavaliable

        fileprivate func asButtonLoadingState() -> DownloadButton.ButtonState {
            return DownloadButton.ButtonState(rawValue: rawValue) ?? .preloading
        }
    }
}

private extension Int {
    func asDateString(with component: NSCalendar.Unit) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = component
        return formatter.string(from: TimeInterval(self)) ?? "0 min"
    }
}

import ManagedModels
import os
import RealmSwift
import RIBs
import RxCocoa
import RxRealm
import RxSwift
import Utils

protocol Routing: ViewableRouting {
    func routeToSearchScreen()
}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel> { get set }
}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?

    init(presenter: Presentable, transformer: ViewModelTransformer = .init()) {
        self.transformer = transformer
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        fetch()
    }

    func didTapOnSearchButton() {
        router?.routeToSearchScreen()
    }

    private let transformer: ViewModelTransformer
}

private extension Interactor {
    func fetch() {
        guard let realm = try? Realm() else { return }

        let result = realm.objects(AlbumManagedModel.self)
        Observable.collection(from: result)
            .filter { $0.isEmpty == false }
            .map { [transformer] (data: Results<AlbumManagedModel>) -> ViewModel in
                let sortedData = data.sorted(byKeyPath: "title", ascending: true)
                return transformer.transform(from: sortedData.toArray())
            }.observeOn(MainScheduler.instance)
            .ifEmpty(default: .empty)
            .asDriver(
                onErrorRecover: {
                    os_log(.error, log: .logic, "Failed to fetch albums, error: %@", $0.localizedDescription)
                    return .just(.empty)
                }
            ).drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }
}

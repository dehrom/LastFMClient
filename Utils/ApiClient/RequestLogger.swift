import Alamofire
import Foundation
import RxCocoa
import RxSwift

final class RequestLogger {
    init() {
        setupObserving(for: Notification.Name.Task.DidResume, handler: printResumingTask(_:))
        setupObserving(for: Notification.Name.Task.DidComplete, handler: printCompletedTask(_:))
    }

    private let disposeBag = DisposeBag()
}

private extension RequestLogger {
    func setupObserving(for name: Notification.Name, handler: @escaping (Notification) -> Void) {
        NotificationCenter.default
            .rx
            .notification(name)
            .flatMap(Observable.from(optional:))
            .observeOn(MainScheduler.instance)
            .bind(onNext: handler)
            .disposed(by: disposeBag)
    }

    func printResumingTask(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
        else { return }

        print("---------- RESUME TASK ----------")

        print("METHOD: \(httpMethod)")
        print("URL: \(requestURL)")

        if let httpHeadersFields = request.allHTTPHeaderFields {
            logHeaders(headers: httpHeadersFields)
        }

        if let httpBody = request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
            print(httpBodyString)
        }

        print("-------- END RESUME TASK --------")
    }

    func printCompletedTask(_ notification: Notification) {
        guard
            let sessionDelegate = notification.object as? SessionDelegate,
            let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
        else { return }

        print("--------- COMPLETE TASK ---------")

        if let error = task.error {
            print("[Error] \(httpMethod) '\(requestURL.absoluteString)'")
            print(error)
        } else {
            guard let response = task.response as? HTTPURLResponse else { return }

            print("METHOD: \(httpMethod)")
            print("URL: \(requestURL.absoluteString)")
            print("STATUS CODE: \(String(response.statusCode))")
            logHeaders(headers: response.allHeaderFields)

            guard let data = sessionDelegate[task]?.delegate.data else { return print("--- COMPLETE TASK WITH DATA ---") }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                if let string = String(data: prettyData, encoding: .utf8) {
                    print(string)
                }
            } catch {
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                    print("--- COMPLETE TASK WITH ERROR ---")
                }
            }
        }

        print("------- COMPLETE TASK -------")
    }

    func logHeaders(headers: [AnyHashable: Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
}

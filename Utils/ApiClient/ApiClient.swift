import Alamofire
import Foundation
import RxAlamofire
import RxSwift

public protocol ApiClient: AnyObject {
    func get<ResultType>(
        parameters: RequestParamsConvertible,
        resultType: ResultType.Type
    ) -> Observable<ResultType> where ResultType: Codable
}

public final class DefaultApiClient {
    public init(baseURL: String, defaultRequestParameters: RequestParamsConvertible) {
        guard let url = try? baseURL.asURL() else { preconditionFailure("baseURL string has wrong format") }
        self.baseURL = url
        self.defaultRequestParameters = defaultRequestParameters
        requestLogger = .init()
    }

    private let baseURL: URL
    private let defaultRequestParameters: RequestParamsConvertible
    private let requestLogger: RequestLogger
}

extension DefaultApiClient: ApiClient {
    public func get<ResultType>(
        parameters: RequestParamsConvertible,
        resultType: ResultType.Type
    ) -> Observable<ResultType> where ResultType: Codable {
        let parameters = defaultRequestParameters.asDictionary().merge(with: parameters.asDictionary())
        return requestData(
            .get,
            baseURL,
            parameters: parameters,
            headers: SessionManager.defaultHTTPHeaders
        ).map {
            try JSONDecoder().decode(resultType, from: $0.1)
        }
    }
}

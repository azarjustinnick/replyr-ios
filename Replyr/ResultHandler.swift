import Foundation

typealias ResultHandler<Success, Failure: Error> = (Result<Success, Failure>) -> Void

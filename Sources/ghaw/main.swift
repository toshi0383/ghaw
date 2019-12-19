import CoreCLI
import Foundation
import RxCocoa
import RxSwift
import ShellOut

struct Environment {
    let userRepo: String
    let authToken: String
    let session: URLSession =  {
        let session = URLSession.shared
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return session
    }()

    private static var _shared: Environment?

    static func shared() throws -> Environment {
        let environment = try Environment()
        _shared = environment
        return environment
    }

    private init() throws {
        let env = ProcessInfo.processInfo.environment
        guard let authToken = env["GITHUB_ACCESS_TOKEN"] else {
            throw CommandError("GITHUB_ACCESS_TOKEN is not set")
        }
        self.authToken = authToken
        let userRepo = try! shellOut(to: "git remote -v | head -1 | sed -n \'s/.*github.com.\\(.*\\)\\.git.*/\\1/p\'")
        guard userRepo.split(separator: "/").count == 2 else {
            throw CommandError("Failed to parse owner/repoName")
        }
        self.userRepo = userRepo
    }
}

struct Ghaw: CommandType {

    private let version = "0.4.0"

    let argument: Argument

    struct Argument: AutoArgumentsDecodable {
        let version: Bool
        let subCommand: CommandType?

        static let defaultSubCommand: CommandType.Type? = ReadyForReview.self
        static let subCommands: [CommandType.Type] = [FindPullRequests.self,
                                                      JobDone.self,
                                                      ReadyForReview.self]
    }

    init() throws {
        let parser = ArgumentParser(arguments: ProcessInfo.processInfo.arguments)
        self.argument = try Argument(parser: parser)
    }

    func run() throws {
        if argument.version {
            print(version)
            exit(0)
        }

        guard let subCommand = argument.subCommand else {
            throw CommandError("Missing subCommand.")
        }
        try subCommand.run()
    }
}

func isToday(_ submitted_at: Date) -> Bool {
    let unixtoday = submitted_at.timeIntervalSince1970
    let timerange: Range<Double> = {
        let cal = Calendar(identifier: Calendar.Identifier.japanese)
        let dstart = cal.startOfDay(for: Date())
        let dend = dstart.addingTimeInterval(60 * 60 * 24)
        return (dstart.timeIntervalSince1970..<dend.timeIntervalSince1970)
    }()
    return timerange.contains(unixtoday)
}

// workaround: Use of this funciton causes compiler to crash.
//
// class API {
//     func reviews(number: Int, condition: @escaping (Review) -> Bool) -> Observable<[Review]> {
//         let req = ReviewsRequest(number: number, userRepo: userRepo, authToken: authToken)
//         return session.rx
//             .data(request: req.urlRequest)
//             .flatMap { data -> Observable<[Review]> in
//                 let decoder = JSONDecoder()
//                 if #available(macOS 10.13, *) {
//                     decoder.dateDecodingStrategy = .iso8601
//                 }
//                 let reviews = try! decoder.decode([Review].self, from: data)
//                     .filter(condition)
//                 return .just(reviews)
//             }
//     }
// }
//
// let api = API()

do {
    try Ghaw().run()
    dispatchMain()
} catch {
    print(error)
    exit(1)
}

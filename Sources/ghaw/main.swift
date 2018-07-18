import Foundation
import RxCocoa
import RxSwift
import ShellOut

let env = ProcessInfo.processInfo.environment
guard let authToken = env["GITHUB_ACCESS_TOKEN"] else {
    print("GITHUB_ACCESS_TOKEN is not set")
    exit(1)
}
let userRepo = try! shellOut(to: "git remote -v | head -1 | sed -n \'s/.*github.com.\\(.*\\)\\.git.*/\\1/p\'")
guard userRepo.split(separator: "/").count == 2 else {
    print("Failed to parse owner/repoName")
    exit(1)
}

let args = ProcessInfo.processInfo.arguments
let me: String = {

    for (i, arg) in args.enumerated() {
        if i + 1 == args.count {
            break
        }

        if arg == "-u" {
            return args[i + 1]
        }
    }
    return try! shellOut(to: "git config --get user.name")
}()

enum Mode {
    case jobDone, readyForReview
}

let mode: Mode = {
    if args.contains("job-done") {
        return .jobDone
    } else {
        return .readyForReview
}
}()

let session = URLSession.shared
session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

private func urlString(for number: Int) -> String {
    return "https://github.com/\(userRepo)/pull/\(number)"
}

struct ReviewCount: CustomStringConvertible {
    let number: Int
    let count: Int

    var description: String {
        return "https://github.com/\(userRepo)/pull/\(number) : \(count)"
    }
}

struct ReadyForReview: CustomStringConvertible {
    let number: Int
    let milestone: String

    var description: String {
        return "\(urlString(for: number)) \(milestone)"
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

switch mode {
case .jobDone:
    let recentPulls: Observable<Pull> = {
        let req = PullsRequest(authToken: authToken, userRepo: userRepo, state: .all, sort: .updated, direction: .desc)
        return session.rx
            .data(request: req.urlRequest)
            .flatMap { data -> Observable<Pull> in
                let decoder = JSONDecoder()
                return .from(try! decoder.decode([Pull].self, from: data))
        }
    }()

    _ = recentPulls
        .filter { $0.user.login != me }
        .flatMap { pull -> Observable<ReviewCount> in

            let req = ReviewsRequest(number: pull.number, userRepo: userRepo, authToken: authToken)

            // TODO: pagination https://developer.github.com/v3/guides/traversing-with-pagination/
            return session.rx
                .data(request: req.urlRequest)
                .flatMap { data -> Observable<[Review]> in
                    let decoder = JSONDecoder()
                    if #available(macOS 10.13, *) {
                        decoder.dateDecodingStrategy = .iso8601
                    }
                    let reviews = try! decoder.decode([Review].self, from: data)
                        .filter { $0.user.login == me && isToday($0.submitted_at) }
                    return .just(reviews)
                }
                .map { $0.count }
                .filter { $0 > 0 }
                .map { ReviewCount(number: pull.number, count: $0) }
        }
        .subscribe(onNext: {
            print($0.description)
        }, onCompleted: {
            exit(0)
        })

case .readyForReview:
    let openPulls: Observable<Pull> = {
        let req = PullsRequest(authToken: authToken, userRepo: userRepo, state: .open, sort: .created, direction: .asc)
        return session.rx
            .data(request: req.urlRequest)
            .flatMap { data -> Observable<Pull> in
                let decoder = JSONDecoder()
                return .from(try! decoder.decode([Pull].self, from: data))
        }
    }()

    _ = openPulls
        .filter { pull in !pull.labels.contains(where: { $0.name == "WIP" }) }
        .flatMap { pull -> Observable<ReadyForReview> in
            let req = ReviewsRequest(number: pull.number, userRepo: userRepo, authToken: authToken)

            // TODO: pagination https://developer.github.com/v3/guides/traversing-with-pagination/
            return session.rx
                .data(request: req.urlRequest)
                .flatMap { data -> Observable<[Review]> in
                    let decoder = JSONDecoder()
                    if #available(macOS 10.13, *) {
                        decoder.dateDecodingStrategy = .iso8601
                    }
                    // reviews which pull-request should be ignored
                    let reviews = try! decoder.decode([Review].self, from: data)
                        .filter { $0.user.login == me && $0.state == .approved }
                    return .just(reviews)
                }
                .filter { $0.isEmpty }
                .map { _ in ReadyForReview(number: pull.number, milestone: pull.milestone?.title ?? "") }
        }
        .subscribe(onNext: {
            print($0.description)
        }, onCompleted: {
            exit(0)
        })
}

dispatchMain()
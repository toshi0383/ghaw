//
//  ReadyForReview.swift
//  ghaw
//
//  Created by Toshihiro Suzuki on 2018/07/29.
//

import CoreCLI
import Foundation
import ShellOut
import RxSwift

struct ReadyForReview: CommandType {
    let argument: Argument

    struct Argument: AutoArgumentsDecodable {
        let json: Bool

        let user: String?
        static var shortHandOptions: [PartialKeyPath<Argument>: Character] {
            return [\Argument.user: "u"]
        }
    }

    func run() throws {

        // shared variables
        let env = try Environment.shared()
        let authToken = env.authToken
        let userRepo = env.userRepo
        let session = env.session

        let me: String
        if let user = argument.user {
            me = user
        } else {
            me = try shellOut(to: "git config --get user.name")
        }

        struct Result: CustomStringConvertible {
            let number: Int
            let title: String
            let milestone: String
            let approveCount: Int
            let commentCountByMe: Int
            let userRepo: String

            private func urlString(for number: Int) -> String {
                return "https://github.com/\(userRepo)/pull/\(number)"
            }

            var description: String {
                return "\(urlString(for: number)) 🔖\(milestone) ✅\(approveCount) \(commentCountByMe == 0 ? "" : "🤔")"
            }

            var json: [String: Any] {
                return [
                    "number": number,
                    "title": title,
                    "url": urlString(for: number),
                    "milestone": milestone,
                    "commentCountByMe": commentCountByMe,
                    "approveCount": approveCount
                ]
            }
        }

        let openPulls: Observable<Pull> = {
            let req = PullsRequest(authToken: authToken, userRepo: userRepo, state: .open, sort: .created, direction: .asc)
            return session.rx
                .data(request: req.urlRequest)
                .flatMap { data -> Observable<Pull> in
                    let decoder = JSONDecoder()
                    return .from(try! decoder.decode([Pull].self, from: data))
                }
                .filter { $0.user.login != me }
        }()

        let readyForReview: Observable<Result> = openPulls
            .filter { pull in !pull.labels.contains(where: { $0.name == "WIP" }) }
            .flatMap { pull -> Observable<Result> in
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
                        let shouldSkip = reviews.contains { $0.user.login == me && $0.state == .approved }
                        return shouldSkip ? .empty() : .just(reviews)
                    }
                    .map { reviews in
                        Result(number: pull.number,
                               title: pull.title,
                               milestone: pull.milestone?.title ?? "",
                               approveCount: Set(reviews.filter { $0.state == .approved }.map { $0.user.login }).count,
                               commentCountByMe: reviews.filter { $0.user.login  == me }.count,
                               userRepo: userRepo)
                    }
            }


        if argument.json {
            _ = readyForReview
                .scan([]) { $0 + [$1] }
                .takeLast(1)
                .map { reviews in
                    let jsons = reviews.map { $0.json }
                    let data = try! JSONSerialization.data(withJSONObject: jsons, options: [])
                    return String(data: data, encoding: .utf8)!
                }
                .subscribe(onNext: {
                    print($0)
                }, onCompleted: {
                    exit(0)
                })
        } else {
            _ = readyForReview
                .subscribe(onNext: {
                    print($0.description)
                }, onCompleted: {
                    exit(0)
                })
        }    }
}

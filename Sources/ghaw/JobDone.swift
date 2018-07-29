//
//  JobDone.swift
//  ghaw
//
//  Created by Toshihiro Suzuki on 2018/07/29.
//
import CoreCLI
import Foundation
import ShellOut
import RxSwift

struct JobDone: CommandType {
    let argument: Argument

    struct Argument: AutoArgumentsDecodable {
        let json: Bool

        let user: String?
        static var shortHandOptions: [PartialKeyPath<Argument>: Character] {
            return [\Argument.user: "u"]
        }
    }

    private struct ReviewCount: CustomStringConvertible {
        let number: Int
        let count: Int
        let userRepo: String

        var description: String {
            return "https://github.com/\(userRepo)/pull/\(number) : \(count)"
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
                    .map { ReviewCount(number: pull.number, count: $0, userRepo: userRepo) }
            }
            .subscribe(onNext: {
                print($0.description)
            }, onCompleted: {
                exit(0)
            })
    }
}

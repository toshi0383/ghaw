//
//  FindPullRequests.swift
//  ghaw
//
//  Created by Toshihiro Suzuki on 2018/07/29.
//
import CoreCLI
import Foundation
import RxSwift
import ShellOut

struct FindPullRequests: CommandType {
    private let match: String

    init(parser: ArgumentParserType) throws {
        guard let match = parser.shift() else {
            throw CommandError("Missing filename parameter.")
        }
        self.match = match
    }

    func run() throws {
        let result = try shellOut(to: pathForShellScript(named: "find-pull-requests.sh"),
                                  arguments: [match])
        print(result)
        exit(0)
    }
}

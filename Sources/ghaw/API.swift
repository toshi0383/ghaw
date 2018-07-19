//
//  API.swift
//  ghaw
//
//  Created by 鈴木 俊裕 on 2018/07/17.
//

import Foundation

// MARK: - Pulls

struct PullsRequest {
    let authToken: String
    let userRepo: String

    let state: State
    enum State: String {
        case all, closed, open
    }

    let sort: Sort
    enum Sort: String {
        case created
        case updated
        case popularity // comment count
        case longRunning = "long-running"
    }

    let direction: Direction
    enum Direction: String {
        case asc, desc
    }

    var urlRequest: URLRequest {
        let url = URL(string: "https://api.github.com/repos/\(userRepo)/pulls?state=\(state.rawValue)&sort=\(sort.rawValue)&direction=\(direction.rawValue)&per_page=100")!
        var req = URLRequest(url: url)
        req.addValue("token \(authToken)", forHTTPHeaderField: "Authorization")
        return req
    }
}

struct User: Decodable {
    let login: String
}

struct Pull: Decodable {
    let number: Int
    let title: String
    let user: User

    let milestone: Milestone?
    struct Milestone: Decodable {
        let title: String
    }

    let state: State
    enum State: String, Decodable {
        case closed = "closed"
        case open = "open"
    }

    let labels: [Label]
    struct Label: Decodable {
        let name: String
    }
}

// MARK: - Reviews

struct ReviewsRequest {
    let number: Int
    let userRepo: String
    let authToken: String

    var urlRequest: URLRequest {
        let url = URL(string: "https://api.github.com/repos/\(userRepo)/pulls/\(number)/reviews?per_page=100")!
        var req = URLRequest(url: url)
        req.addValue("token \(authToken)", forHTTPHeaderField: "Authorization")
        return req
    }
}

struct Review: Decodable {
    let user: User
    let state: State
    enum State: String, Decodable {
        case approved = "APPROVED"
        case commented = "COMMENTED"
        case changesRequested = "CHANGES_REQUESTED"
    }

    let submitted_at: Date
}

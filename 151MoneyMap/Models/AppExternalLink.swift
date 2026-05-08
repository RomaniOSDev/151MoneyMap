//
//  AppExternalLink.swift
//  151MoneyMap
//

import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://www.termsfeed.com/live/057ee94b-dcb4-4f3b-a76b-81288e6cda14"
    case termsOfUse = "https://www.termsfeed.com/live/a138ea0d-79b8-424c-9bf4-c43354762ccf"

    var url: URL? {
        URL(string: rawValue)
    }
}

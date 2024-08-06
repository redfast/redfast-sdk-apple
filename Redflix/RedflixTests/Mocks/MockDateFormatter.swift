//
//  MockDateFormatter.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 20.05.2024.
//

import Foundation
@testable import Redflix

final class MockDateFormatter: DateFormatting {
    var formattedMovieReleaseDate = ""
    var dateFromResponseString: Date? = nil
    
    func formatMovieReleaseDate(from date: Date?) -> String? {
        formattedMovieReleaseDate
    }
    
    func getDateFromResponseString(string: String) -> Date? {
        dateFromResponseString
    }
}

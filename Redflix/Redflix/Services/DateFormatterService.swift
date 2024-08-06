//
//  DateFormatterService.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 20.05.2024.
//

import Foundation

protocol DateFormatting: AnyObject {
    func formatMovieReleaseDate(from date: Date?) -> String?
    func getDateFromResponseString(string: String) -> Date?
}

final class DateFormatterService: DateFormatting {
    func formatMovieReleaseDate(from date: Date?) -> String? {
        guard let date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getDateFromResponseString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: string)
    }
}

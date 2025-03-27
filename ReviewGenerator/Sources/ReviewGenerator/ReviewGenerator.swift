// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public class ReviewGenerator {
    private let reviews: [String] = [
        "An amazing read! Highly recommended.",
        "Quite an insightful book, with a few slow parts.",
        "A must-read for enthusiasts. Engaging and informative.",
        "Not my favorite, but it had some good points.",
        "Well-written and thought-provoking."
    ]
    
    public init() {}
    
    public func getRandomReview() -> String {
        return reviews.randomElement() ?? "No review available"
    }
}

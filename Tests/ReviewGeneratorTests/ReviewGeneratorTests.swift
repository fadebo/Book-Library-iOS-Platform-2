import XCTest
@testable import ReviewGenerator

final class ReviewGeneratorTests: XCTestCase {
    func testGetRandomReview() {
        let generator = ReviewGenerator()
        let review = generator.getRandomReview()
        XCTAssertFalse(review.isEmpty, "Review should not be empty")
    }
}

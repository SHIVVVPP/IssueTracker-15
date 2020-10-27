//
//  ColorConvertTests.swift
//  IssueTrackerTests
//
//  Created by sihyung you on 2020/10/27.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import XCTest
@testable import IssueTracker

class ColorConvertTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringToColor() {
        let colorCode = "#FF5D5D" // 255, 93, 93
        let color: UIColor = colorCode.color
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, 1)
        XCTAssertEqual(green, 93/255.0)
        XCTAssertEqual(Int(blue * 255), 93)
    }
}

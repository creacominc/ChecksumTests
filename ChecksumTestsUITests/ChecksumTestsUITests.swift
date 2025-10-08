//
//  ChecksumTestsUITests.swift
//  ChecksumTestsUITests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import XCTest

final class ChecksumTestsUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    // MARK: - Initial State Tests
    
    @MainActor
    func testInitialUIState() throws {
        // Test that all main UI elements are present on launch
        XCTAssertTrue(app.buttons["Source"].exists, "Source button should exist")
        XCTAssertTrue(app.staticTexts["Select Source Folder"].exists, "Select Source Folder text should exist")
        XCTAssertTrue(app.staticTexts["Total Files: 0"].exists, "Total Files label should exist with 0 files")
        XCTAssertTrue(app.buttons["Process"].exists, "Process button should exist")
        XCTAssertTrue(app.staticTexts["Select a source directory"].exists, "Initial status text should exist")
    }
    
    @MainActor
    func testSourceButtonInitiallyEnabled() throws {
        // Test that Source button is enabled initially
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.exists, "Source button should exist")
        XCTAssertTrue(sourceButton.isEnabled, "Source button should be enabled initially")
    }
    
    @MainActor
    func testProcessButtonInitiallyDisabled() throws {
        // Test that Process button is disabled initially
        let processButton = app.buttons["Process"]
        XCTAssertTrue(processButton.exists, "Process button should exist")
        XCTAssertFalse(processButton.isEnabled, "Process button should be disabled initially")
    }
    
    // MARK: - Component Tests
    
    @MainActor
    func testFolderPickerViewElements() throws {
        // Test FolderPickerView components
        XCTAssertTrue(app.buttons["Source"].exists, "Source button should exist")
        
        // Verify the button is tappable (enabled)
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.isHittable, "Source button should be hittable")
    }
    
    @MainActor
    func testFolderStatsViewElements() throws {
        // Test FolderStatsView components
        XCTAssertTrue(app.staticTexts["Total Files: 0"].exists, "Total Files label should exist")
        
        // Initially, no file type breakdown should be visible
        XCTAssertFalse(app.staticTexts["Photo:"].exists, "Photo label should not exist initially")
        XCTAssertFalse(app.staticTexts["Audio:"].exists, "Audio label should not exist initially")
        XCTAssertFalse(app.staticTexts["Video:"].exists, "Video label should not exist initially")
        XCTAssertFalse(app.staticTexts["Other:"].exists, "Other label should not exist initially")
    }
    
    @MainActor
    func testProcessControlViewElements() throws {
        // Test ProcessControlView components
        let processButton = app.buttons["Process"]
        XCTAssertTrue(processButton.exists, "Process button should exist")
        XCTAssertFalse(processButton.isEnabled, "Process button should be disabled without source")
    }
    
    @MainActor
    func testProgressBarViewExists() throws {
        // Test that progress bar is present
        // Progress bars in SwiftUI are implemented as progress indicators
        let progressIndicators = app.progressIndicators
        XCTAssertGreaterThan(progressIndicators.count, 0, "At least one progress indicator should exist")
    }
    
    @MainActor
    func testResultsChartsViewInitialState() throws {
        // Test that the "no results" message is shown initially
        XCTAssertTrue(app.staticTexts["No results yet - click Process to analyze files"].exists, 
                     "No results message should be shown initially")
    }
    
    @MainActor
    func testStatusTextVisible() throws {
        // Test that status text is visible
        XCTAssertTrue(app.staticTexts["Select a source directory"].exists, 
                     "Status text should be visible")
    }
    
    // MARK: - Threshold Selector Tests
    
    @MainActor
    func testThresholdSelectorExists() throws {
        // Test that threshold values are displayed
        // The threshold selector should show formatted byte values
        let staticTexts = app.staticTexts
        
        // Check if any text contains "KB", "MB", or "GB" which would indicate threshold values
        var foundThresholdText = false
        for i in 0..<staticTexts.count {
            let text = staticTexts.element(boundBy: i).label
            if text.contains("KB") || text.contains("MB") || text.contains("GB") {
                foundThresholdText = true
                break
            }
        }
        
        XCTAssertTrue(foundThresholdText, "Threshold values should be displayed")
    }
    
    // MARK: - Overlay Tests
    
    @MainActor
    func testBusyOverlayNotVisibleInitially() throws {
        // Test that busy overlay is not shown initially
        XCTAssertFalse(app.staticTexts["Processing..."].exists, 
                      "Processing overlay should not be visible initially")
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testMainButtonsAccessibility() throws {
        // Test that main buttons are accessible
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.exists, "Source button should be accessible")
        
        let processButton = app.buttons["Process"]
        XCTAssertTrue(processButton.exists, "Process button should be accessible")
    }
    
    @MainActor
    func testStaticTextAccessibility() throws {
        // Test that important static text is accessible
        let texts = [
            "Select Source Folder",
            "Total Files: 0",
            "Select a source directory"
        ]
        
        for text in texts {
            XCTAssertTrue(app.staticTexts[text].exists, "\(text) should be accessible")
        }
    }
}

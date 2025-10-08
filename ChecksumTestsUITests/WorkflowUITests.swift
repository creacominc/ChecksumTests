//
//  WorkflowUITests.swift
//  ChecksumTestsUITests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import XCTest

final class WorkflowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Initial State Workflow
    
    @MainActor
    func testInitialStateWorkflow() throws {
        // Verify the complete initial state
        XCTAssertTrue(app.buttons["Source"].isEnabled, "Source button should be enabled initially")
        XCTAssertFalse(app.buttons["Process"].isEnabled, "Process button should be disabled initially")
        XCTAssertTrue(app.staticTexts["Select a source directory"].exists, "Initial status should be shown")
        XCTAssertFalse(app.staticTexts["Processing..."].exists, "Should not be processing initially")
    }
    
    // MARK: - Button State Tests
    
    @MainActor
    func testSourceButtonInteraction() throws {
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.exists, "Source button should exist")
        XCTAssertTrue(sourceButton.isHittable, "Source button should be clickable")
        
        // Note: We can't fully test the file picker dialog in UI tests
        // as it's a system dialog, but we can verify the button is functional
    }
    
    @MainActor
    func testProcessButtonStateBeforeSourceSelection() throws {
        let processButton = app.buttons["Process"]
        XCTAssertFalse(processButton.isEnabled, 
                      "Process button should remain disabled until a source is selected")
    }
    
    // MARK: - UI Consistency Tests
    
    @MainActor
    func testUIElementsConsistency() throws {
        // Verify all expected UI elements are present and consistent
        let sourceButton = app.buttons["Source"]
        let processButton = app.buttons["Process"]
        let statusText = app.staticTexts["Select a source directory"]
        let totalFilesText = app.staticTexts["Total Files: 0"]
        
        XCTAssertTrue(sourceButton.exists)
        XCTAssertTrue(processButton.exists)
        XCTAssertTrue(statusText.exists)
        XCTAssertTrue(totalFilesText.exists)
    }
    
    // MARK: - Empty State Tests
    
    @MainActor
    func testEmptyStateMessage() throws {
        // Verify empty state message for results
        let emptyMessage = app.staticTexts["No results yet - click Process to analyze files"]
        XCTAssertTrue(emptyMessage.exists, "Empty state message should be displayed")
    }
    
    @MainActor
    func testEmptyStateNoFileTypeBreakdown() throws {
        // When no files are loaded, file type information should not be shown
        XCTAssertFalse(app.staticTexts["Photo:"].exists)
        XCTAssertFalse(app.staticTexts["Audio:"].exists)
        XCTAssertFalse(app.staticTexts["Video:"].exists)
        XCTAssertFalse(app.staticTexts["Other:"].exists)
    }
    
    // MARK: - Status Text Tests
    
    @MainActor
    func testStatusTextVisibility() throws {
        // Status text should always be visible
        let statusTextExists = app.staticTexts.allElementsBoundByIndex.contains { element in
            element.label == "Select a source directory"
        }
        XCTAssertTrue(statusTextExists, "Status text should be visible at all times")
    }
    
    // MARK: - Layout Tests
    
    @MainActor
    func testMainLayoutStructure() throws {
        // Verify the main layout structure is correct
        let sourceButton = app.buttons["Source"]
        let processButton = app.buttons["Process"]
        let progressIndicators = app.progressIndicators
        
        XCTAssertTrue(sourceButton.exists, "Source section should exist")
        XCTAssertTrue(processButton.exists, "Process section should exist")
        XCTAssertGreaterThan(progressIndicators.count, 0, "Progress section should exist")
    }
    
    @MainActor
    func testVerticalLayoutOrder() throws {
        // Verify components are laid out vertically in the correct order
        let sourceButton = app.buttons["Source"]
        let processButton = app.buttons["Process"]
        
        XCTAssertLessThan(sourceButton.frame.midY, processButton.frame.midY,
                         "Source button should appear before Process button")
    }
    
    // MARK: - Threshold Display Tests
    
    @MainActor
    func testThresholdValuesDisplayed() throws {
        // Verify that threshold values are displayed somewhere in the UI
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        let hasThresholdValues = allStaticTexts.contains { element in
            let label = element.label
            return label.contains("KB") || label.contains("MB") || label.contains("GB")
        }
        
        XCTAssertTrue(hasThresholdValues, "Threshold values should be displayed in the UI")
    }
    
    // MARK: - Progress Indicator Tests
    
    @MainActor
    func testProgressIndicatorExists() throws {
        // Verify progress indicator is present
        XCTAssertGreaterThan(app.progressIndicators.count, 0, 
                           "Progress indicator should be present in the UI")
    }
    
    @MainActor
    func testProgressIndicatorVisible() throws {
        // Progress indicator should be visible (though at 0% initially)
        let progressIndicator = app.progressIndicators.firstMatch
        XCTAssertTrue(progressIndicator.exists, "Progress indicator should exist")
    }
}

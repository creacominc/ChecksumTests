//
//  ComponentUITests.swift
//  ChecksumTestsUITests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import XCTest

final class ComponentUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - FolderPickerView Tests
    
    @MainActor
    func testFolderPickerViewButtonExists() throws {
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.exists, "Source button from FolderPickerView should exist")
    }
    
    @MainActor
    func testFolderPickerViewDisplaysCorrectInitialText() throws {
        let selectFolderText = app.staticTexts["Select Source Folder"]
        XCTAssertTrue(selectFolderText.exists, "Select Source Folder text should be displayed initially")
    }
    
    // MARK: - FolderStatsView Tests
    
    @MainActor
    func testFolderStatsViewShowsTotalFiles() throws {
        let totalFilesLabel = app.staticTexts["Total Files: 0"]
        XCTAssertTrue(totalFilesLabel.exists, "Total Files label should be visible")
    }
    
    @MainActor
    func testFolderStatsViewFileTypesHiddenWhenEmpty() throws {
        // When no files are loaded, file type breakdowns should not be visible
        XCTAssertFalse(app.staticTexts["Photo:"].exists, "Photo count should not be visible when no files loaded")
        XCTAssertFalse(app.staticTexts["Audio:"].exists, "Audio count should not be visible when no files loaded")
        XCTAssertFalse(app.staticTexts["Video:"].exists, "Video count should not be visible when no files loaded")
    }
    
    // MARK: - ProcessControlView Tests
    
    @MainActor
    func testProcessControlViewButtonExists() throws {
        let processButton = app.buttons["Process"]
        XCTAssertTrue(processButton.exists, "Process button should exist in ProcessControlView")
    }
    
    @MainActor
    func testProcessControlViewButtonDisabledInitially() throws {
        let processButton = app.buttons["Process"]
        XCTAssertFalse(processButton.isEnabled, "Process button should be disabled when no source is selected")
    }
    
    // MARK: - ProgressBarView Tests
    
    @MainActor
    func testProgressBarViewExists() throws {
        let progressIndicators = app.progressIndicators
        XCTAssertGreaterThan(progressIndicators.count, 0, "Progress bar should be present")
    }
    
    // MARK: - ResultsChartsView Tests
    
    @MainActor
    func testResultsChartsViewShowsEmptyMessage() throws {
        let emptyMessage = app.staticTexts["No results yet - click Process to analyze files"]
        XCTAssertTrue(emptyMessage.exists, "Empty message should be shown when no results")
    }
    
    // MARK: - ThresholdSelectorView Tests
    
    @MainActor
    func testThresholdSelectorViewDisplaysValues() throws {
        // Check that threshold values are displayed in some format
        let allText = app.staticTexts.allElementsBoundByIndex.map { $0.label }.joined(separator: " ")
        
        // Should contain formatted byte values
        let hasValidThresholdFormat = allText.contains("KB") || allText.contains("MB") || allText.contains("GB")
        XCTAssertTrue(hasValidThresholdFormat, "Threshold selector should display formatted byte values")
    }
    
    // MARK: - BusyOverlayView Tests
    
    @MainActor
    func testBusyOverlayViewNotShownInitially() throws {
        // Busy overlay should not be visible on app launch
        let processingText = app.staticTexts["Processing..."]
        XCTAssertFalse(processingText.exists, "Processing overlay should not be visible initially")
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    func testAllComponentsRenderedTogether() throws {
        // Verify that all major components are rendered together
        XCTAssertTrue(app.buttons["Source"].exists, "FolderPickerView should be rendered")
        XCTAssertTrue(app.staticTexts["Total Files: 0"].exists, "FolderStatsView should be rendered")
        XCTAssertTrue(app.buttons["Process"].exists, "ProcessControlView should be rendered")
        XCTAssertTrue(app.progressIndicators.count > 0, "ProgressBarView should be rendered")
        XCTAssertTrue(app.staticTexts["No results yet - click Process to analyze files"].exists, 
                     "ResultsChartsView should be rendered")
    }
    
    @MainActor
    func testComponentsLayoutOrder() throws {
        // Test that components appear in the correct order from top to bottom
        let sourceButton = app.buttons["Source"]
        let totalFilesLabel = app.staticTexts["Total Files: 0"]
        let processButton = app.buttons["Process"]
        
        XCTAssertTrue(sourceButton.exists)
        XCTAssertTrue(totalFilesLabel.exists)
        XCTAssertTrue(processButton.exists)
        
        // Source should be above Total Files
        XCTAssertLessThan(sourceButton.frame.minY, totalFilesLabel.frame.minY, 
                         "Source button should be above Total Files label")
        
        // Total Files should be above Process button
        XCTAssertLessThan(totalFilesLabel.frame.minY, processButton.frame.minY, 
                         "Total Files should be above Process button")
    }
}

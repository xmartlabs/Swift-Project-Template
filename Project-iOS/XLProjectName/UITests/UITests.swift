//
//  UITests.swift
//  UITests
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import XCTest
import Nimble

class UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRespositoryView() {
        // Use recording to get started writing UI tests.
        // Optionally use Nimble expect and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        
        // fill organization and repository text fiels
        let organizationTextField = app.textFields["organization"]
        organizationTextField.tap()
        organizationTextField.typeText("xmartlabs")
        
        let repositoryTextField = app.textFields["repository"]
        repositoryTextField.tap()
        repositoryTextField.typeText("eureka")
        
        // tap show repo button
        let seerepobuttonButton = app.buttons["seeRepoButton"]
        seerepobuttonButton.tap()
        let repositoryTitleElement = app.staticTexts["RepositoryTitle"]
        
        // validate that detail repository view label shows Eureka
        expect(repositoryTitleElement.label) == "Eureka"
        
        // tap back button
        let backButton = app.navigationBars["XLProjectName.Repository"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0)
        backButton.tap()
        
        // delete repository text field text
        repositoryTextField.tap()
        let deleteKey = app.keyboards.keys["delete"]
        for _ in 1...6 { deleteKey.tap() }
        
        // set xlform to respository text field
        repositoryTextField.tap()
        repositoryTextField.typeText("xlform")
        
        // tap show button
        seerepobuttonButton.tap()
        
        // validate that detail repository view label shows XLForm
        expect(repositoryTitleElement.label) == "XLForm"
        
    }
}

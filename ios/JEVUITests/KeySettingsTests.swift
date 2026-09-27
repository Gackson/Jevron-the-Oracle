import XCTest

final class KeySettingsTests: XCTestCase {
    func testChineseAnswerModePersistsAndDisplaysWrappedReplies() throws {
        continueAfterFailure=false
        let app=XCUIApplication()
        app.launchArguments=["--uitesting"]
        app.launch()
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout:12))
        expectation(for:NSPredicate(format:"enabled == true"),evaluatedWith:app.buttons["settingsButton"])
        waitForExpectations(timeout:8)
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["简体中文"].waitForExistence(timeout:5))
        app.buttons["简体中文"].tap()
        app.buttons["Done"].tap()
        let input=app.textFields["questionInput"].exists ? app.textFields["questionInput"] : app.textViews["questionInput"]
        input.tap();input.typeText("Should I begin?")
        app.buttons["sendButton"].tap()
        let answer=app.descendants(matching:.any).matching(identifier:"answer").firstMatch
        expectation(for:NSPredicate(format:"label == %@","留意一下，你正在盼望哪一种答案。"),evaluatedWith:answer)
        waitForExpectations(timeout:12)
        let oracleShot=XCTAttachment(screenshot:app.screenshot());oracleShot.name="chinese-oracle";oracleShot.lifetime = .keepAlways;add(oracleShot)
        app.buttons["characterMenu"].tap();app.buttons["character_stone"].tap()
        XCTAssertTrue(input.waitForExistence(timeout:5))
        input.tap();input.typeText("What remains?");app.buttons["sendButton"].tap()
        expectation(for:NSPredicate(format:"label == %@","石静而水行。"),evaluatedWith:answer)
        waitForExpectations(timeout:10)
        let stoneShot=XCTAttachment(screenshot:app.screenshot());stoneShot.name="chinese-stela";stoneShot.lifetime = .keepAlways;add(stoneShot)
        app.terminate()
        app.launchArguments=["--uitesting","--uitesting-keep-language"]
        app.launch();app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout:12))
        expectation(for:NSPredicate(format:"enabled == true"),evaluatedWith:app.buttons["settingsButton"])
        waitForExpectations(timeout:8)
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["简体中文"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["简体中文"].isSelected)
        app.buttons["English"].tap()
    }

    func testUserCanSaveReplaceAndDeleteAPIKey() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout:5))
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout:12))
        app.buttons["settingsButton"].tap()
        let input = app.secureTextFields["jevAPIKeyInput"]
        XCTAssertTrue(input.waitForExistence(timeout:5))
        if app.buttons["deleteJEVAPIKey"].exists { throw XCTSkip("Preserve an existing user key; run in a clean test simulator") }
        let save = app.buttons["saveJEVAPIKey"]
        XCTAssertFalse(save.isEnabled)
        input.tap(); input.typeText("not-a-real-key-one")
        save.tap()
        let delete = app.buttons["deleteJEVAPIKey"]
        XCTAssertTrue(delete.waitForExistence(timeout:3))
        XCTAssertEqual(app.staticTexts["jevAPIKeyStatus"].label,"API key saved on this device")
        // The plaintext editor is cleared after saving; the key is never displayed back to the user.
        XCTAssertEqual(input.value as? String,"Replace API key")
        input.tap(); input.typeText("not-a-real-key-two")
        save.tap()
        XCTAssertTrue(delete.exists)
        delete.tap()
        XCTAssertEqual(app.staticTexts["jevAPIKeyStatus"].label,"Add your API key to begin")
        XCTAssertFalse(delete.exists)
        app.buttons["Done"].tap()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(input.waitForExistence(timeout:3))
        XCTAssertEqual(app.staticTexts["jevAPIKeyStatus"].label,"Add your API key to begin")
    }
}

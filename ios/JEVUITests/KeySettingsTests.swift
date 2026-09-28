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
        XCTAssertTrue(app.navigationBars["设置"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.switches["景深与梦幻效果"].exists)
        XCTAssertEqual(app.buttons["settingsDone"].label, "完成")
        let settingsShot = XCTAttachment(screenshot: app.screenshot())
        settingsShot.name = "chinese-settings"; settingsShot.lifetime = .keepAlways; add(settingsShot)
        app.buttons["spatialPreview"].tap()
        XCTAssertTrue(app.navigationBars["空间效果预览"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["toggleSpatialControls"].label, "隐藏控制项")
        XCTAssertEqual(app.sliders["horizontalTilt"].label, "水平倾斜")
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["settingsDone"].tap()
        let input=app.textFields["questionInput"].exists ? app.textFields["questionInput"] : app.textViews["questionInput"]
        XCTAssertTrue(app.staticTexts["你早已做出了选择。"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["characterMenu"].label, "选择先知，当前为 The Oracle")
        XCTAssertEqual(app.buttons["speechButton"].label, "说出你的问题")
        XCTAssertEqual(app.buttons["sendButton"].label, "发送问题")
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
        app.launch()
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["enterButton"].label, "进来吧。")
        XCTAssertEqual(app.staticTexts["welcomeTitle"].label, "认识你自己。")
        let homeShot = XCTAttachment(screenshot: app.screenshot())
        homeShot.name = "chinese-home"; homeShot.lifetime = .keepAlways; add(homeShot)
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout:12))
        expectation(for:NSPredicate(format:"enabled == true"),evaluatedWith:app.buttons["settingsButton"])
        waitForExpectations(timeout:8)
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["简体中文"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["简体中文"].isSelected)
        app.buttons["English"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["settingsDone"].label, "Done")
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
        app.buttons["settingsDone"].tap()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(input.waitForExistence(timeout:3))
        XCTAssertEqual(app.staticTexts["jevAPIKeyStatus"].label,"Add your API key to begin")
    }
}

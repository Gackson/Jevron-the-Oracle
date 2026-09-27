import XCTest

final class FlowTests: XCTestCase {
    private var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    private func enter() {
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout: 5))
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["characterMenu"].waitForExistence(timeout: 12))
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.buttons["skipEntrance"])
        waitForExpectations(timeout: 3)
    }
    private func selectCharacter(_ character: String) {
        app.buttons["characterMenu"].tap()
        let option = app.buttons["character_\(character)"]
        XCTAssertTrue(option.waitForExistence(timeout: 3))
        option.tap()
    }
    private func assertComposerAlignment(_ input: XCUIElement) {
        let microphone = app.buttons["speechButton"]
        let send = app.buttons["sendButton"]
        XCTAssertTrue(microphone.isHittable)
        XCTAssertTrue(send.isHittable)
        XCTAssertEqual(microphone.frame.midY, input.frame.midY, accuracy: 4)
        XCTAssertEqual(send.frame.midY, input.frame.midY, accuracy: 4)
        if app.keyboards.firstMatch.exists {
            XCTAssertLessThanOrEqual(input.frame.maxY, app.keyboards.firstMatch.frame.minY)
        }
    }
    private func dismissKeyboardByTappingScene() {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
        let dismissed = NSPredicate(format: "exists == false")
        expectation(for: dismissed, evaluatedWith: app.keyboards.firstMatch)
        waitForExpectations(timeout: 3)
    }
    private func send(_ question: String) {
        let input = app.textFields["questionInput"].exists ? app.textFields["questionInput"] : app.textViews["questionInput"]
        XCTAssertTrue(input.waitForExistence(timeout: 3))
        input.tap()
        input.typeText(question)
        XCTAssertTrue(app.buttons["sendButton"].isHittable)
        app.buttons["sendButton"].tap()
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testEntranceConversationHistoryAndCharacterSwitching() {
        capture("01-entrance-preview")
        enter()
        capture("02-empty-oracle")
        send("What am I waiting for?")
        let first = app.descendants(matching: .any).matching(identifier: "answer").firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 6))
        capture("03-first-reply")
        let composerY = app.buttons["speechButton"].frame.midY
        send("What if I begin today?")
        XCTAssertTrue(app.buttons["earlierReply"].waitForExistence(timeout: 6))
        app.scrollViews["historyScroll"].swipeDown()
        XCTAssertTrue(app.buttons["backToLatest"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["speechButton"].frame.midY, composerY, accuracy: 1)
        XCTAssertFalse(app.staticTexts["Your next question continues the latest conversation."].exists)
        capture("04-history")
        app.buttons["backToLatest"].tap()
        selectCharacter("stone")
        XCTAssertTrue(app.staticTexts["Leave a question in the quiet."].waitForExistence(timeout: 3))
        send("What should I leave behind?")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "answer").firstMatch.waitForExistence(timeout: 6))
        capture("05-stone-reply")
    }

    func testStreamingReplyHasNoSpinnerOrCancelAndKeepsComposerFixed() {
        app.terminate()
        app.launchArguments = ["--uitesting", "--uitesting-slow-reply"]
        app.launch()
        enter()
        let composerY = app.buttons["speechButton"].frame.midY
        send("What am I waiting for?")
        XCTAssertTrue(app.staticTexts["waitingEcho"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.activityIndicators.firstMatch.exists)
        XCTAssertFalse(app.buttons["Cancel"].exists)
        XCTAssertEqual(app.buttons["speechButton"].frame.midY, composerY, accuracy: 1)
        capture("stream-waiting-text")
        let answer = app.descendants(matching: .any).matching(identifier: "answer").firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 5))
        XCTAssertFalse(answer.label.isEmpty)
        XCTAssertNotEqual(answer.label, "Notice which answer you were hoping for.")
        XCTAssertEqual(app.buttons["speechButton"].frame.midY, composerY, accuracy: 1)
        capture("stream-partial-answer")
        expectation(for: NSPredicate(format: "label == %@", "Notice which answer you were hoping for."), evaluatedWith: answer)
        waitForExpectations(timeout: 12)
        XCTAssertEqual(app.buttons["speechButton"].frame.midY, composerY, accuracy: 1)
        XCTAssertFalse(app.staticTexts["waitingEcho"].exists)
        capture("stream-complete-answer")
    }

    func testHoldComposerReleasesAndSendsVoiceWhileTapStillEdits() {
        app.terminate()
        app.launchArguments = ["--uitesting", "--uitesting-speech"]
        app.launch()
        enter()
        let input = app.textFields["questionInput"]
        let composerY = app.buttons["speechButton"].frame.midY
        input.press(forDuration: 1.0)
        let answer = app.descendants(matching: .any).matching(identifier: "answer").firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["What if I begin today?"].exists)
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        XCTAssertEqual(app.buttons["speechButton"].frame.midY, composerY, accuracy: 1)
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: input)
        waitForExpectations(timeout: 5)
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
        input.typeText("Still editable")
        XCTAssertEqual(input.value as? String, "Still editable")
    }

    func testMicrophoneButtonStillLetsYouReviewBeforeSending() {
        app.terminate()
        app.launchArguments = ["--uitesting", "--uitesting-speech"]
        app.launch()
        enter()
        app.buttons["speechButton"].tap()
        expectation(for: NSPredicate(format: "label == 'Stop listening'"), evaluatedWith: app.buttons["speechButton"])
        waitForExpectations(timeout: 3)
        app.buttons["speechButton"].tap()
        let input = app.textFields["questionInput"]
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: input)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(input.value as? String, "What if I begin today?")
        XCTAssertFalse(app.scrollViews["historyScroll"].exists)
        XCTAssertTrue(app.buttons["sendButton"].isEnabled)
    }

    func testLargeTypeAndSceneEffects() {
        app.terminate()
        app.launchArguments = ["--uitesting", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout: 5))
        capture("07-large-welcome")
        if !app.buttons["enterButton"].isHittable { app.swipeUp() }
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["characterMenu"].waitForExistence(timeout: 12))
        send("What if I begin?")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "answer").firstMatch.waitForExistence(timeout: 6))
        capture("08-large-response")
        app.buttons["settingsButton"].tap()
        let effectSwitch = app.switches["Depth & dream effects"]
        XCTAssertTrue(effectSwitch.waitForExistence(timeout: 3))
        effectSwitch.tap()
        app.buttons["Done"].tap()
        capture("09-effects-enabled")
    }

    func testKeyboardAndLongInputRemainUsable() {
        enter()
        let input = app.textFields["questionInput"].exists ? app.textFields["questionInput"] : app.textViews["questionInput"]
        assertComposerAlignment(input)
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
        input.typeText("Why am I waiting for the perfect moment when I could take one small step today? What changes if I start now and let the next step follow?")
        assertComposerAlignment(input)
        capture("keyboard-multiline-alignment")
        // Tapping the editor must preserve focus; only the surrounding scene dismisses it.
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.exists)
        dismissKeyboardByTappingScene()
        assertComposerAlignment(input)
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
        assertComposerAlignment(input)
        XCTAssertTrue(app.buttons["sendButton"].isHittable)
        capture("06-keyboard")
        app.buttons["sendButton"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "answer").firstMatch.waitForExistence(timeout: 6))
        // The first streamed word does not mean the request has finished.
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: input)
        waitForExpectations(timeout: 5)
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
        dismissKeyboardByTappingScene()
        assertComposerAlignment(input)
        capture("keyboard-dismissed-with-history")
    }

    func testColdLaunchAlwaysShowsHomeAndEntryOpensOracle() {
        enter()
        selectCharacter("jester")
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["characterMenu"].exists)
        enter()
        XCTAssertTrue(app.staticTexts["What weighs on your mind?"].waitForExistence(timeout: 5))
    }


    func testSkippingEntranceRemovesPlayerAndReleasesControls() {
        app.buttons["enterButton"].tap()
        let skip = app.buttons["skipEntrance"]
        XCTAssertTrue(skip.waitForExistence(timeout: 2))
        skip.tap()
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.otherElements["entranceVideo"])
        waitForExpectations(timeout: 3)
        let menu = app.buttons["characterMenu"]
        expectation(for: NSPredicate { _, _ in menu.exists && menu.isEnabled && menu.isHittable }, evaluatedWith: menu)
        waitForExpectations(timeout: 3)
        menu.tap()
        XCTAssertTrue(app.buttons["character_jester"].waitForExistence(timeout: 3))
    }

    func testHomeBackgroundAndHeadlineBothStartEntrance() {
        XCTAssertTrue(app.buttons["enterButton"].waitForExistence(timeout: 5))
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.35)).tap()
        XCTAssertTrue(app.buttons["skipEntrance"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["characterMenu"].waitForExistence(timeout: 8))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["welcomeTitle"].waitForExistence(timeout: 5))
        app.staticTexts["welcomeTitle"].tap()
        XCTAssertTrue(app.buttons["skipEntrance"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["characterMenu"].waitForExistence(timeout: 8))
    }

    func testVideoFinishesAndHorizontalSwipesWrapBothWays() {
        app.buttons["enterButton"].tap()
        XCTAssertTrue(app.buttons["skipEntrance"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["characterMenu"].exists)
        XCTAssertTrue(app.buttons["characterMenu"].waitForExistence(timeout: 12))
        let menu = app.buttons["characterMenu"]
        // Accessibility can discover the incoming scene while the player still fades above it.
        expectation(for: NSPredicate { _, _ in menu.isHittable && menu.isEnabled }, evaluatedWith: menu)
        waitForExpectations(timeout: 3)
        func swipe(_ left: Bool, expected: String) {
            let from = app.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.8 : 0.2, dy: 0.42))
            let to = app.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.2 : 0.8, dy: 0.42))
            from.press(forDuration: 0.05, thenDragTo: to)
            let changed = NSPredicate(format: "label == %@ AND enabled == true", "Choose character. The \(expected) selected")
            expectation(for: changed, evaluatedWith: menu)
            waitForExpectations(timeout: 4)
        }
        XCTAssertEqual(menu.label, "Choose character. The Oracle selected")
        // Discover the displayed roster so this flow covers newly added characters too.
        menu.tap()
        let roleIDs = ["oracle", "stone", "jester", "fool"].filter { app.buttons["character_" + $0].exists }
        let names = roleIDs.map { app.buttons["character_" + $0].label.replacingOccurrences(of: "The ", with: "") }
        app.buttons["character_oracle"].tap()
        XCTAssertGreaterThanOrEqual(names.count, 3)
        swipe(false, expected: names.last!)
        swipe(true, expected: "Oracle")
        for name in names.dropFirst() { swipe(true, expected: name) }
        swipe(true, expected: "Oracle")
        capture("circular-characters")
    }

    func testCharacterSwitchKeepsNonzeroSharedCameraPose() {
        app.terminate()
        app.launchArguments = ["--uitesting", "--uitesting-fixed-tilt"]
        app.launch()
        enter()
        let menu = app.buttons["characterMenu"]
        XCTAssertEqual(menu.value as? String, "tilt:0.750000,-0.500000")
        capture("shared-tilt-before-switch")
        for character in ["stone", "jester", "oracle"] {
            selectCharacter(character)
            expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: menu)
            waitForExpectations(timeout: 4)
            XCTAssertEqual(menu.value as? String, "tilt:0.750000,-0.500000", "Switch must not reset the shared camera")
            capture("shared-tilt-" + character)
        }
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.42))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.42)))
        expectation(for: NSPredicate(format: "label == %@ AND enabled == true", "Choose character. The Stela selected"), evaluatedWith: menu)
        waitForExpectations(timeout: 4)
        XCTAssertEqual(menu.value as? String, "tilt:0.750000,-0.500000")
    }

    func testContinuousDepthAtContactPointsAndOppositeTiltExtremes() {
        enter()
        app.buttons["settingsButton"].tap()
        app.buttons["spatialPreview"].tap()
        let layered = app.staticTexts["Continuous scene depth"]
        XCTAssertTrue(layered.waitForExistence(timeout: 20))
        func sceneCapture(_ name: String) {
            app.buttons["toggleSpatialControls"].tap()
            capture(name)
            app.buttons["toggleSpatialControls"].tap()
        }
        for character in ["Oracle", "Stone", "Jester"] {
            app.segmentedControls.buttons[character == "Stone" ? (app.segmentedControls.buttons["The Stela"].exists ? "The Stela" : "The Stone") : "The " + character].tap()
            XCTAssertTrue(layered.waitForExistence(timeout: 20))
            app.sliders["horizontalTilt"].adjust(toNormalizedSliderPosition: 0)
            app.sliders["verticalTilt"].adjust(toNormalizedSliderPosition: 1)
            sceneCapture("spatial-\(character)-left-top")
            app.sliders["horizontalTilt"].adjust(toNormalizedSliderPosition: 1)
            app.sliders["verticalTilt"].adjust(toNormalizedSliderPosition: 0)
            sceneCapture("spatial-\(character)-right-bottom")
            app.buttons["Center"].tap()
            sceneCapture("spatial-\(character)-center")
        }
    }
}

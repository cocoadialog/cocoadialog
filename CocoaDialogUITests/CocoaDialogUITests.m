

#import <XCTest/XCTest.h>

@interface CocoaDialogUITests : XCTestCase
{
  XCUIApplication *app;
}
@end

@implementation CocoaDialogUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = YES;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = XCUIApplication.new;
    [app setLaunchArguments:@[@"yesno-msgbox", @"--title", @"Hello", @"--button1", @"test"]];
//    [app launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
  
//  [app terminate];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

  
  XCUIElementQuery *helloDialog = app.dialogs[@"Hello"];

  XCTAssertNotNil(helloDialog);

  XCTAssert(app.windows, @"must have a window, %@", app.windows);
  XCUIElementQuery *q = [app.dialogs[@"Hello"] descendantsMatchingType:XCUIElementTypeButton];

  XCTAssertGreaterThan(q.count,0, @"musrt have buttons");
  XCTAssertNotNil(app.windows[@"Hello"]);
  XCTAssertNotNil(helloDialog.buttons[@"No"]);
  XCTAssertEqual(helloDialog.buttons.count, 3);
//
//
//  XCUIElement *noButton = app.dialogs[@"Hello"].buttons[@"No"];
//  XCUIElement *yesButton = app.dialogs[@"Hello"].buttons[@"Yes"];
//	XCUIElement *cancelButton = app.dialogs[@"Hello"].buttons[@"Cancel"];
//
//  XCTAssertNotNil(noButton);
//  XCTAssertNotNil(yesButton);
//  XCTAssertNotNil(cancelButton);
//
//  [yesButton click];

//  [yesButton typeText:@"\t"];
//  [cancelButton typeText:@"\t"];
//  [noButton typeText:@"\t"];
//  [yesButton typeText:@" "];

  
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end

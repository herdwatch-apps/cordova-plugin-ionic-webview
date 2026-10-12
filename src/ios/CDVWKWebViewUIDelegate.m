/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVWKWebViewUIDelegate.h"

@implementation CDVWKWebViewUIDelegate

- (instancetype)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }

    return self;
}

// The application delegate's window is nil in a cordova-ios 8 app on scenes (the scene owns the window), so the dialogs are
// presented from the web view's own window: its root view controller, or whatever is presented on top of it.
- (UIViewController*)presenterForWebView:(WKWebView*)webView
{
    UIViewController* presenter = webView.window.rootViewController;

    while (presenter.presentedViewController != nil && ![presenter.presentedViewController isBeingDismissed]) {
        presenter = presenter.presentedViewController;
    }

    return presenter;
}

- (void)     webView:(WKWebView*)webView runJavaScriptAlertPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler();
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIViewController* presenter = [self presenterForWebView:webView];

    if (presenter == nil) {
        // Nothing to present from: WebKit requires the completion handler to be called, or the page stays blocked
        completionHandler();
        return;
    }

    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)     webView:(WKWebView*)webView runJavaScriptConfirmPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler(YES);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
        {
            completionHandler(NO);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
    [alert addAction:cancel];

    UIViewController* presenter = [self presenterForWebView:webView];

    if (presenter == nil) {
        // Nothing to present from: WebKit requires the completion handler to be called, or the page stays blocked
        completionHandler(NO);
        return;
    }

    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)      webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:prompt
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler(((UITextField*)alert.textFields[0]).text);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
        {
            completionHandler(nil);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.text = defaultText;
    }];

    UIViewController* presenter = [self presenterForWebView:webView];

    if (presenter == nil) {
        // Nothing to present from: WebKit requires the completion handler to be called, or the page stays blocked
        completionHandler(nil);
        return;
    }

    [presenter presentViewController:alert animated:YES completion:nil];
}

@end

//
//  BaseController.m
//  Dolphin
//
//  Created by Alex Trofimov on 23/01/13.
//
//

#import "BaseController.h"

@interface BaseController ()

@end

@implementation BaseController

// iOS 6
- (NSInteger)supportedInterfaceOrientations {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

// iOS 6
- (BOOL)shouldAutorotate {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
}

// iOS 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return UIDeviceOrientationPortrait == interfaceOrientation ? YES : NO;
}

/**********************************************************************************************************************
 CUSTOM FUNCTION
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setupBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back button title") style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    [backButton release];
}

- (void)showErrorAlert:(NSString*)stringError {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:stringError delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
    [al show];
    [al release];
}

@end

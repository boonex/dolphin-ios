//
//  TesterController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BxUser;

@interface TesterController : UIViewController {
	NSString *sUser;
	NSString *sPwd;
	NSString *sSite;
	
	NSString *sErrors;
	
	IBOutlet UILabel *status;
	IBOutlet UIWebView *errors;
	IBOutlet UIProgressView *progress;
	
	BxUser *user;
	NSArray *runQueue;
	NSInteger currentIndex;	
}

- (void)runQueue;

- (void)testBegin:(NSString*)s;
- (void)testEnd:(BOOL)isSuccess ret:(id)resp method:(NSString*)sMethod;
- (void)customSituationForMethod:(NSString*)sMethod ret:(id)resp;

@end

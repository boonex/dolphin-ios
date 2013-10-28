//
//  LoginController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/19/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@class BxUser;

@interface LoginController : BaseUserController <UITextFieldDelegate> {
	
	IBOutlet UITextField *textDomain;
	IBOutlet UITextField *textUsername;
	IBOutlet UITextField *textPassword;
    IBOutlet UIButton *buttonLogin;
    IBOutlet UIWebView *htmlTerms;
	
    IBOutlet UIView *viewContainerFacebook;
	IBOutlet UIView *viewContainer;
	IBOutlet UIScrollView *viewScroll;
    
    FBLoginView *viewFacebookLogin;
}

- (IBAction)actionLogin:(id)sender;

- (NSString*)md5:(NSString*)str;
- (void)callbackLogin:(id)idData;

- (id)initWithUserObject:(BxUser*)anUser;

@end

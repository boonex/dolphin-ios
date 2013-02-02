//
//  WebPageController.h
//  Dolphin6
//
//  Created by Alex Trofimov on 5/07/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserController.h"

@interface WebPageController : BaseUserController<UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    NSString *strURL;
    NSString *strTitle;
    UINavigationController *navController;
}

- (id)initWithUrl:(NSString *)anUrl title:(NSString*)aTitle user:(BxUser*)anUser nav:(UINavigationController *)aNav;

@end

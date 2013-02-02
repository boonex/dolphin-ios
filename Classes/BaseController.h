//
//  BaseController.h
//  Dolphin
//
//  Created by Alex Trofimov on 23/01/13.
//
//

#import <UIKit/UIKit.h>

@interface BaseController : UIViewController

- (void)setupBackButton;
- (void)showErrorAlert:(NSString*)stringError;

@end

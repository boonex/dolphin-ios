//
//  SiteAddController.h
//  Dolphin
//
//  Created by Alex Trofimov on 21/01/13.
//
//

#import "BaseUserController.h"

@interface SiteAddController : BaseUserController {
    IBOutlet UITextField *textDomain;
    IBOutlet UIButton *btnSave;
    IBOutlet UIView *viewContainer;
    IBOutlet UIScrollView *viewScroll;
}

- (IBAction)actionCheckDomain:(id)sender;

@end

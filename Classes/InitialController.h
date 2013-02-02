//
//  InitialController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/4/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface InitialController : BaseController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIImageView *logo;
	IBOutlet UITableView *table;	
}

@end

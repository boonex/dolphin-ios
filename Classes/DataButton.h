//
//  DataButton.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/10/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataButton : UIButton {
	id data;
}

- (id)initWithFrame:(CGRect)aRect;

- (void)setButtonData:(id)aData;
- (id)getButtonData;

@end

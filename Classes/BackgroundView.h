//
//  BackgroundView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 24/02/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BackgroundView : UIView {
	Boolean selected;
	Boolean withSpaces;
}

- (id)initWithFrame:(CGRect)frame selected:(Boolean)isSelected withSpaces:(Boolean)isWithSpaces;

@end

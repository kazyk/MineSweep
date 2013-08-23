//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>
#import "Board.h"

@class Square;


@interface SquareView : UIView

@property (nonatomic) BoardPoint point;
@property (nonatomic) Square *square;

@property (nonatomic) UIColor *color;

@end
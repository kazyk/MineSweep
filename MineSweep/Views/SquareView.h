//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>

@class Square;


@interface SquareView : UIView

- (instancetype)initWithFrame:(CGRect)frame square:(Square *)square;

@property (nonatomic, readonly) Square *square;

@property (nonatomic) UIColor *color;

@end
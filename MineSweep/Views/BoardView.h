//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>
#import "Board.h"

@class Board;


@interface BoardView : UIView

@property (nonatomic) Board *board;

- (CGRect)frameForSquareAtPoint:(BoardPoint)point;

@end
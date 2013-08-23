//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "Square.h"


@implementation Square


- (NSString *)description
{
    if (!self.isOpened) {
        return @"o";
    }
    if (self.hasMine) {
        return @"x";
    }
    if (self.countOfNeighborMines == 0) {
        return @" ";
    }
    return [@(self.countOfNeighborMines) stringValue];
}


@end
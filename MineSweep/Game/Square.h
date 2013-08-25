//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>
#import "Board.h"

typedef NS_ENUM(NSInteger, MineState) {
    kMineStateUndifinite = 0,   //地雷未確定
    kMineStateNoMine,
    kMineStateHasMine,
};


@interface Square : NSObject

@property (nonatomic) BoardPoint point;

@property (nonatomic, getter=isOpened) BOOL opened;

@property (nonatomic) MineState mineState;

@property (nonatomic) NSInteger countOfNeighborMines;

@property (nonatomic) NSInteger turn;

@property (nonatomic) BOOL mineDetected;

@end
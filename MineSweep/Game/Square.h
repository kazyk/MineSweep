//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>


@interface Square : NSObject

@property (nonatomic, getter=isOpened) BOOL opened;

@property (nonatomic) BOOL hasMine;

@property (nonatomic) NSInteger countOfNeighborMines;

@end
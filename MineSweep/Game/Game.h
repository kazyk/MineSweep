//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>

@class Board;


@interface Game : NSObject

- (instancetype)init;

@property (nonatomic, readonly) Board *board;

@end

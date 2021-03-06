#import "MJRefreshComponent.h"
@interface MJRefreshHeader : MJRefreshComponent
+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;
+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;
@property (copy, nonatomic) NSString *lastUpdatedTimeKey;
@property (strong, nonatomic, readonly) NSDate *lastUpdatedTime;
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetTop;
@end

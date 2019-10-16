#import <UIKit/UIKit.h>
@class RACDelegateProxy;
@class RACSignal;
@interface UIAlertView (RACSignalSupport)
@property (nonatomic, strong, readonly) RACDelegateProxy *rac_delegateProxy;
- (RACSignal *)rac_buttonClickedSignal;
@end

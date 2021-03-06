#import "UIRefreshControl+RACCommandSupport.h"
#import "RACEXTKeyPathCoding.h"
#import "RACCommand.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACSignal.h"
#import "RACSignal+Operations.h"
#import "UIControl+RACSignalSupport.h"
#import <objc/runtime.h>
static void *UIRefreshControlRACCommandKey = &UIRefreshControlRACCommandKey;
static void *UIRefreshControlDisposableKey = &UIRefreshControlDisposableKey;
@implementation UIRefreshControl (RACCommandSupport)
- (RACCommand *)rac_command {
	return objc_getAssociatedObject(self, UIRefreshControlRACCommandKey);
}
- (void)setRac_command:(RACCommand *)command {
	objc_setAssociatedObject(self, UIRefreshControlRACCommandKey, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[objc_getAssociatedObject(self, UIRefreshControlDisposableKey) dispose];
	if (command == nil) return;
	RACDisposable *enabledDisposable = [command.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	RACDisposable *executionDisposable = [[[[self
		rac_signalForControlEvents:UIControlEventValueChanged]
		map:^(UIRefreshControl *x) {
			return [[[command
				execute:x]
				catchTo:[RACSignal empty]]
				then:^{
					return [RACSignal return:x];
				}];
		}]
		concat]
		subscribeNext:^(UIRefreshControl *x) {
			[x endRefreshing];
		}];
	RACDisposable *commandDisposable = [RACCompoundDisposable compoundDisposableWithDisposables:@[ enabledDisposable, executionDisposable ]];
	objc_setAssociatedObject(self, UIRefreshControlDisposableKey, commandDisposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

#import "RACTestScheduler.h"
#import "RACEXTScope.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACScheduler+Private.h"
@interface RACTestSchedulerAction : NSObject
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) void (^block)(void);
@property (nonatomic, strong, readonly) RACDisposable *disposable;
- (id)initWithDate:(NSDate *)date block:(void (^)(void))block;
@end
static CFComparisonResult RACCompareScheduledActions(const void *ptr1, const void *ptr2, void *info) {
	RACTestSchedulerAction *action1 = (__bridge id)ptr1;
	RACTestSchedulerAction *action2 = (__bridge id)ptr2;
	return CFDateCompare((__bridge CFDateRef)action1.date, (__bridge CFDateRef)action2.date, NULL);
}
static const void *RACRetainScheduledAction(CFAllocatorRef allocator, const void *ptr) {
	return CFRetain(ptr);
}
static void RACReleaseScheduledAction(CFAllocatorRef allocator, const void *ptr) {
	CFRelease(ptr);
}
@interface RACTestScheduler ()
@property (nonatomic, assign, readonly) CFBinaryHeapRef scheduledActions;
@property (nonatomic, assign) NSUInteger numberOfDirectlyScheduledBlocks;
@end
@implementation RACTestScheduler
#pragma mark Lifecycle
- (instancetype)init {
	self = [super initWithName:@"com.github.ReactiveCocoa.RACTestScheduler"];
	if (self == nil) return nil;
	CFBinaryHeapCallBacks callbacks = (CFBinaryHeapCallBacks){
		.version = 0,
		.retain = &RACRetainScheduledAction,
		.release = &RACReleaseScheduledAction,
		.copyDescription = &CFCopyDescription,
		.compare = &RACCompareScheduledActions
	};
	_scheduledActions = CFBinaryHeapCreate(NULL, 0, &callbacks, NULL);
	return self;
}
- (void)dealloc {
	[self stepAll];
	if (_scheduledActions != NULL) {
		CFRelease(_scheduledActions);
		_scheduledActions = NULL;
	}
}
#pragma mark Execution
- (void)step {
	[self step:1];
}
- (void)step:(NSUInteger)ticks {
	@synchronized (self) {
		for (NSUInteger i = 0; i < ticks; i++) {
			const void *actionPtr = NULL;
			if (!CFBinaryHeapGetMinimumIfPresent(self.scheduledActions, &actionPtr)) break;
			RACTestSchedulerAction *action = (__bridge id)actionPtr;
			CFBinaryHeapRemoveMinimumValue(self.scheduledActions);
			if (action.disposable.disposed) continue;
			RACScheduler *previousScheduler = RACScheduler.currentScheduler;
			NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey] = self;
			action.block();
			if (previousScheduler != nil) {
				NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey] = previousScheduler;
			} else {
				[NSThread.currentThread.threadDictionary removeObjectForKey:RACSchedulerCurrentSchedulerKey];
			}
		}
	}
}
- (void)stepAll {
	[self step:NSUIntegerMax];
}
#pragma mark RACScheduler
- (RACDisposable *)schedule:(void (^)(void))block {
	NSCParameterAssert(block != nil);
	@synchronized (self) {
		NSDate *uniqueDate = [NSDate dateWithTimeIntervalSinceReferenceDate:self.numberOfDirectlyScheduledBlocks];
		self.numberOfDirectlyScheduledBlocks++;
		RACTestSchedulerAction *action = [[RACTestSchedulerAction alloc] initWithDate:uniqueDate block:block];
		CFBinaryHeapAddValue(self.scheduledActions, (__bridge void *)action);
		return action.disposable;
	}
}
- (RACDisposable *)after:(NSDate *)date schedule:(void (^)(void))block {
	NSCParameterAssert(date != nil);
	NSCParameterAssert(block != nil);
	@synchronized (self) {
		RACTestSchedulerAction *action = [[RACTestSchedulerAction alloc] initWithDate:date block:block];
		CFBinaryHeapAddValue(self.scheduledActions, (__bridge void *)action);
		return action.disposable;
	}
}
- (RACDisposable *)after:(NSDate *)date repeatingEvery:(NSTimeInterval)interval withLeeway:(NSTimeInterval)leeway schedule:(void (^)(void))block {
	NSCParameterAssert(date != nil);
	NSCParameterAssert(block != nil);
	NSCParameterAssert(interval >= 0);
	NSCParameterAssert(leeway >= 0);
	RACCompoundDisposable *compoundDisposable = [RACCompoundDisposable compoundDisposable];
	@weakify(self);
	@synchronized (self) {
		__block RACDisposable *thisDisposable = nil;
		void (^reschedulingBlock)(void) = ^{
			@strongify(self);
			[compoundDisposable removeDisposable:thisDisposable];
			RACDisposable *schedulingDisposable = [self after:[date dateByAddingTimeInterval:interval] repeatingEvery:interval withLeeway:leeway schedule:block];
			[compoundDisposable addDisposable:schedulingDisposable];
			block();
		};
		RACTestSchedulerAction *action = [[RACTestSchedulerAction alloc] initWithDate:date block:reschedulingBlock];
		CFBinaryHeapAddValue(self.scheduledActions, (__bridge void *)action);
		thisDisposable = action.disposable;
		[compoundDisposable addDisposable:thisDisposable];
	}
	return compoundDisposable;
}
@end
@implementation RACTestSchedulerAction
#pragma mark Lifecycle
- (id)initWithDate:(NSDate *)date block:(void (^)(void))block {
	NSCParameterAssert(date != nil);
	NSCParameterAssert(block != nil);
	self = [super init];
	if (self == nil) return nil;
	_date = [date copy];
	_block = [block copy];
	_disposable = [[RACDisposable alloc] init];
	return self;
}
#pragma mark NSObject
- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p>{ date: %@ }", self.class, self, self.date];
}
@end

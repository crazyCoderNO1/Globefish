#ifdef DEBUG
extern void rac_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
extern void rac_dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
extern void rac_dispatch_after(dispatch_time_t time, dispatch_queue_t queue, dispatch_block_t block);
extern void rac_dispatch_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
extern void rac_dispatch_barrier_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
extern void rac_dispatch_after_f(dispatch_time_t time, dispatch_queue_t queue, void *context, dispatch_function_t function);
#define dispatch_async rac_dispatch_async
#define dispatch_barrier_async rac_dispatch_barrier_async
#define dispatch_after rac_dispatch_after
#define dispatch_async_f rac_dispatch_async_f
#define dispatch_barrier_async_f rac_dispatch_barrier_async_f
#define dispatch_after_f rac_dispatch_after_f
@interface RACBacktrace : NSObject
@property (nonatomic, strong, readonly) RACBacktrace *previousThreadBacktrace;
@property (nonatomic, copy, readonly) NSArray *callStackSymbols;
+ (instancetype)backtrace;
+ (instancetype)backtraceIgnoringFrames:(NSUInteger)ignoreCount;
@end
#else
#define rac_dispatch_async dispatch_async
#define rac_dispatch_barrier_async dispatch_barrier_async
#define rac_dispatch_after dispatch_after
#define rac_dispatch_async_f dispatch_async_f
#define rac_dispatch_barrier_async_f dispatch_barrier_async_f
#define rac_dispatch_after_f dispatch_after_f
#endif

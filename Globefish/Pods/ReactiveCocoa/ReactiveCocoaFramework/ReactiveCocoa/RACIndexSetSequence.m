#import "RACIndexSetSequence.h"
@interface RACIndexSetSequence ()
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) const NSUInteger *indexes;
@property (nonatomic, readonly) NSUInteger count;
@end
@implementation RACIndexSetSequence
#pragma mark Lifecycle
+ (instancetype)sequenceWithIndexSet:(NSIndexSet *)indexSet {
	NSUInteger count = indexSet.count;
	if (count == 0) return self.empty;
	NSUInteger sizeInBytes = sizeof(NSUInteger) * count;
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:sizeInBytes];
	[indexSet getIndexes:data.mutableBytes maxCount:count inIndexRange:NULL];
	RACIndexSetSequence *seq = [[self alloc] init];
	seq->_data = data;
	seq->_indexes = data.bytes;
	seq->_count = count;
	return seq;
}
+ (instancetype)sequenceWithIndexSetSequence:(RACIndexSetSequence *)indexSetSequence offset:(NSUInteger)offset {
	NSCParameterAssert(offset < indexSetSequence.count);
	RACIndexSetSequence *seq = [[self alloc] init];
	seq->_data = indexSetSequence.data;
	seq->_indexes = indexSetSequence.indexes + offset;
	seq->_count = indexSetSequence.count - offset;
	return seq;
}
#pragma mark RACSequence
- (id)head {
	return @(self.indexes[0]);
}
- (RACSequence *)tail {
	if (self.count <= 1) return [RACSequence empty];
	return [self.class sequenceWithIndexSetSequence:self offset:1];
}
#pragma mark NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id[])stackbuf count:(NSUInteger)len {
	NSCParameterAssert(len > 0);
	if (state->state >= self.count) {
		return 0;
	}
	if (state->state == 0) {
		state->mutationsPtr = state->extra;
	}
	state->itemsPtr = stackbuf;
	unsigned long index = 0;
	while (index < MIN(self.count - state->state, len)) {
		stackbuf[index] = @(self.indexes[index + state->state]);
		++index;
	}
	state->state += index;
	return index;
}
#pragma mark NSObject
- (NSString *)description {
	NSMutableString *indexesStr = [NSMutableString string];
	for (unsigned int i = 0; i < self.count; ++i) {
		if (i > 0) [indexesStr appendString:@", "];
		[indexesStr appendFormat:@"%lu", (unsigned long)self.indexes[i]];
	}
	return [NSString stringWithFormat:@"<%@: %p>{ name = %@, indexes = %@ }", self.class, self, self.name, indexesStr];
}
@end

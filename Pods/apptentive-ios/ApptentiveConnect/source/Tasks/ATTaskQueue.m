//
//  ATTaskQueue.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 3/21/11.
//  Copyright 2011 Apptentive, Inc.. All rights reserved.
//

#import "ATTaskQueue.h"
#import "ATBackend.h"
#import "ATTask.h"
#import "ATLegacyRecord.h"

#define kATTaskQueueCodingVersion 1
// Retry period in seconds.
#define kATTaskQueueRetryPeriod 180.0

#define kMaxFailureCount 30

static ATTaskQueue *sharedTaskQueue = nil;


@interface ATTaskQueue (Private)
- (void)setup;
- (void)teardown;
- (void)archive;
- (void)unsetActiveTask;
@end


@implementation ATTaskQueue {
	ATTask *activeTask;
	NSMutableArray *tasks;
}

+ (NSString *)taskQueuePath {
	return [[[ATBackend sharedBackend] supportDirectoryPath] stringByAppendingPathComponent:@"tasks.objects"];
}

+ (BOOL)serializedQueueExists {
	NSFileManager *fm = [NSFileManager defaultManager];
	return [fm fileExistsAtPath:[ATTaskQueue taskQueuePath]];
}


+ (ATTaskQueue *)sharedTaskQueue {
	@synchronized(self) {
		if (sharedTaskQueue == nil) {
			if ([ATTaskQueue serializedQueueExists]) {
				NSError *error = nil;
				NSData *data = [NSData dataWithContentsOfFile:[ATTaskQueue taskQueuePath] options:NSDataReadingMapped error:&error];
				if (!data) {
					ATLogError(@"Unable to unarchive task queue: %@", error);
				} else {
					@try {
						NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
						[unarchiver setClass:[ATLegacyRecord class] forClassName:@"ATRecord"];
						sharedTaskQueue = [unarchiver decodeObjectForKey:@"root"];
						unarchiver = nil;
					} @catch (NSException *exception) {
						ATLogError(@"Unable to unarchive task queue: %@", exception);
					}
				}
			}
			if (!sharedTaskQueue) {
				sharedTaskQueue = [[ATTaskQueue alloc] init];
			}
		}
	}
	return sharedTaskQueue;
}

+ (void)releaseSharedTaskQueue {
	@synchronized(self) {
		if (sharedTaskQueue != nil) {
			[sharedTaskQueue archive];
			sharedTaskQueue = nil;
		}
	}
}

- (id)init {
	if ((self = [super init])) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		int version = [coder decodeIntForKey:@"version"];
		if (version == kATTaskQueueCodingVersion) {
			tasks = [coder decodeObjectForKey:@"tasks"];
		} else {
			return nil;
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kATTaskQueueCodingVersion forKey:@"version"];
	@synchronized(self) {
		NSMutableArray *archivableTasks = [[NSMutableArray alloc] init];
		for (ATTask *task in tasks) {
			if ([task shouldArchive]) {
				[archivableTasks addObject:task];
			}
		}
		[coder encodeObject:archivableTasks forKey:@"tasks"];
		archivableTasks = nil;
	}
}

- (void)dealloc {
	[self teardown];
}


- (void)addTask:(ATTask *)task {
	@synchronized(self) {
		[tasks addObject:task];
		[self archive];
	}
	[self start];
}

- (BOOL)hasTaskOfClass:(Class)c {
	BOOL result = NO;
	@synchronized(self) {
		for (ATTask *task in tasks) {
			if ([task isKindOfClass:c]) {
				result = YES;
				break;
			}
		}
	}
	return result;
}

- (NSUInteger)count {
	NSUInteger count = 0;
	@synchronized(self) {
		count = [tasks count];
	}
	return count;
}

- (ATTask *)taskAtIndex:(NSUInteger)index {
	@synchronized(self) {
		return [tasks objectAtIndex:index];
	}
}

- (NSUInteger)countOfTasksWithTaskNamesInSet:(NSSet *)taskNames {
	NSUInteger count = 0;
	@synchronized(self) {
		for (ATTask *task in tasks) {
			if ([taskNames containsObject:[task taskName]]) {
				count++;
			}
		}
	}
	return count;
}

- (ATTask *)taskAtIndex:(NSUInteger)index withTaskNameInSet:(NSSet *)taskNames {
	NSMutableArray *accum = [NSMutableArray array];
	@synchronized(self) {
		for (ATTask *task in tasks) {
			if ([taskNames containsObject:[task taskName]]) {
				[accum addObject:task];
			}
		}
	}
	if (index < [accum count]) {
		return [accum objectAtIndex:index];
	}
	return nil;
}

- (void)start {
	// We can no longer do this in the background because of CoreData objects.
	if (![[NSThread currentThread] isMainThread]) {
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	@autoreleasepool {
		@synchronized(self) {
			if (activeTask) {
				return;
			}

			if ([tasks count]) {
				for (ATTask *task in tasks) {
					if ([task canStart]) {
						activeTask = task;
						[activeTask addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:NULL];
						[activeTask addObserver:self forKeyPath:@"failed" options:NSKeyValueObservingOptionNew context:NULL];
						[activeTask start];
						break;
					}
				}
			}
		}
	}
}

- (void)stop {
	@synchronized(self) {
		[activeTask stop];
		[self unsetActiveTask];
	}
}

- (NSString *)queueDescription {
	NSMutableString *result = [[NSMutableString alloc] init];
	@synchronized(self) {
		[result appendString:[NSString stringWithFormat:@"<ATTaskQueue: %lu task(s) [", (unsigned long)[tasks count]]];
		NSMutableArray *parts = [[NSMutableArray alloc] init];
		for (ATTask *task in tasks) {
			[parts addObject:[task taskDescription]];
		}
		if ([parts count]) {
			[result appendString:@"\n"];
			[result appendString:[parts componentsJoinedByString:@",\n"]];
			[result appendString:@"\n"];
		}
		parts = nil;
		[result appendString:@"]>"];
	}
	return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	@synchronized(self) {
		if (object != activeTask) return;
		ATTask *task = (ATTask *)object;

		if (![task isKindOfClass:[ATTask class]]) {
			ATLogError(@"Object was not subclass of ATTask");
			return;
		}

		if ([keyPath isEqualToString:@"finished"] && [task finished]) {
			[self unsetActiveTask];
			[task cleanup];
			[tasks removeObject:object];
			[self archive];
			[self startOnNextRunLoopIteration];
		} else if ([keyPath isEqualToString:@"failed"] && [task failed]) {
			if (task.isFailureOkay) {
				task.failureCount = task.failureCount + 1;
				[self unsetActiveTask];
				[tasks removeObject:task];
				[self startOnNextRunLoopIteration];
			} else {
				[self stop];
				task.failureCount = task.failureCount + 1;
				if (task.failureCount > kMaxFailureCount) {
					ATLogError(@"Task %@ failed too many times, removing from queue.", task);
					[self unsetActiveTask];
					[task cleanup];
					[tasks removeObject:task];
					[self startOnNextRunLoopIteration];
				} else {
					// Put task on back of queue.
					[tasks removeObject:task];
					[tasks addObject:task];
					[self archive];

					[self performSelector:@selector(start) withObject:nil afterDelay:kATTaskQueueRetryPeriod];
				}
			}
		}
	}
}

- (void)startOnNextRunLoopIteration {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self start];
	});
}

@end


@implementation ATTaskQueue (Private)
- (void)setup {
	@synchronized(self) {
		tasks = [[NSMutableArray alloc] init];
	}
}

- (void)teardown {
	@synchronized(self) {
		[self stop];
		tasks = nil;
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
}

- (void)unsetActiveTask {
	@synchronized(self) {
		if (activeTask) {
			[activeTask removeObserver:self forKeyPath:@"finished"];
			[activeTask removeObserver:self forKeyPath:@"failed"];
			activeTask = nil;
		}
	}
}

- (void)archive {
	@synchronized(self) {
		if ([ATTaskQueue taskQueuePath]) {
			if (![NSKeyedArchiver archiveRootObject:sharedTaskQueue toFile:[ATTaskQueue taskQueuePath]]) {
				ATLogError(@"Unable to archive task queue to: %@", [ATTaskQueue taskQueuePath]);
			}
		}
	}
}
@end

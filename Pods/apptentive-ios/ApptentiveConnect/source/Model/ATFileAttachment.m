//
//  ATFileAttachment.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 2/20/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATFileAttachment.h"
#import "ATBackend.h"
#import "ATCompoundMessage.h"
#import "ATUtilities.h"
#import "ATData.h"
#import "NSDictionary+ATAdditions.h"
#import "ATConnect_Private.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>


@interface ATFileAttachment ()
+ (NSString *)fullLocalPathForFilename:(NSString *)filename;
- (NSString *)filenameForThumbnailOfSize:(CGSize)size;
- (void)deleteSidecarIfNecessary;
@end


@implementation ATFileAttachment
@dynamic localPath;
@dynamic mimeType;
@dynamic name;
@dynamic message;
@dynamic remoteURL;
@dynamic remoteThumbnailURL;

+ (BOOL)canCreateThumbnailForMIMEType:(NSString *)MIMEType {
	static NSMutableSet *thumbnailableMIMETypes;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CFArrayRef thumbnailableUTIs = CGImageSourceCopyTypeIdentifiers();
		thumbnailableMIMETypes = [NSMutableSet set];

		for (CFIndex i = 0; i < CFArrayGetCount(thumbnailableUTIs); i ++) {
			CFStringRef UTI = CFArrayGetValueAtIndex(thumbnailableUTIs, i);
			CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
			if (MIMEType) {
				[thumbnailableMIMETypes addObject:(__bridge id _Nonnull)(MIMEType)];
				CFRelease(MIMEType);
			}
		}

		CFRelease(thumbnailableUTIs);
	});

	return [thumbnailableMIMETypes containsObject:MIMEType];
}

+ (instancetype)newInstanceWithFileData:(NSData *)fileData MIMEType:(NSString *)MIMEType name:(NSString *)name {
	ATFileAttachment *attachment = (ATFileAttachment *)[ATData newEntityNamed:NSStringFromClass(self)];
	[attachment setFileData:fileData MIMEType:MIMEType name:name];
	return attachment;
}

+ (instancetype)newInstanceWithJSON:(NSDictionary *)JSON {
	ATFileAttachment *attachment = (ATFileAttachment *)[ATData newEntityNamed:NSStringFromClass(self)];
	[attachment updateWithJSON:JSON];

	return attachment;
}

+ (void)addMissingExtensions {
	NSArray *allAttachments = [ATData findEntityNamed:NSStringFromClass(self) withPredicate:[NSPredicate predicateWithValue:YES]];

	for (ATFileAttachment *attachment in allAttachments) {
		if (attachment.localPath.length && attachment.localPath.pathExtension.length == 0 && attachment.mimeType.length > 0) {
			NSString *newPath = [attachment.localPath stringByAppendingPathExtension:attachment.extension];
			NSError *error;
			if ([[NSFileManager defaultManager] moveItemAtPath:[self fullLocalPathForFilename:attachment.localPath] toPath:[self fullLocalPathForFilename:newPath] error:&error]) {
				attachment.localPath = newPath;
			} else {
				ATLogError(@"Unable to append extension to file %@ (error: %@)", newPath, error);
			}
		}
	}
}

- (void)updateWithJSON:(NSDictionary *)JSON {
	NSString *remoteURLString = [JSON at_safeObjectForKey:@"url"];
	if (remoteURLString && [remoteURLString isKindOfClass:[NSString class]] && [NSURL URLWithString:remoteURLString]) {
		[self willChangeValueForKey:@"remoteURL"];
		[self setPrimitiveValue:remoteURLString forKey:@"remoteURL"];
		[self didChangeValueForKey:@"remoteURL"];
	}

	NSString *remoteThumbnailURL = [JSON at_safeObjectForKey:@"thumbnail_url"];
	if (remoteThumbnailURL && [remoteThumbnailURL isKindOfClass:[NSString class]] && [NSURL URLWithString:remoteThumbnailURL]) {
		[self willChangeValueForKey:@"remoteThumbnailURL"];
		[self setPrimitiveValue:remoteThumbnailURL forKey:@"remoteThumbnailURL"];
		[self didChangeValueForKey:@"remoteThumbnailURL"];
	}

	NSString *MIMEType = [JSON at_safeObjectForKey:@"content_type"];
	if (MIMEType && [MIMEType isKindOfClass:[NSString class]]) {
		self.mimeType = MIMEType;
	}

	NSString *name = [JSON at_safeObjectForKey:@"original_name"];
	if (name && [name isKindOfClass:[NSString class]]) {
		self.name = name;
	}
}

- (void)prepareForDeletion {
	[self setFileData:nil MIMEType:nil name:nil];
}

- (void)setFileData:(NSData *)data MIMEType:(NSString *)MIMEType name:(NSString *)name {
	[self deleteSidecarIfNecessary];
	self.localPath = nil;
	self.mimeType = MIMEType;
	if (data) {
		self.localPath = [[ATUtilities randomStringOfLength:20] stringByAppendingPathExtension:self.extension];
		if (![data writeToFile:[self fullLocalPath] atomically:YES]) {
			ATLogError(@"Unable to save file data to path: %@", [self fullLocalPath]);
			self.localPath = nil;
		}
		self.name = name ?: [NSString stringWithString:self.localPath];
	}
}

- (NSData *)fileData {
	NSString *path = [self fullLocalPath];
	NSData *fileData = nil;
	if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSError *error = nil;
		fileData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
		if (!fileData) {
			ATLogError(@"Unable to get contents of file path for uploading: %@", error);
		} else {
			return fileData;
		}
	}

	ATLogError(@"Missing sidecar file for %@", self);
	return nil;
}

- (NSURL *)remoteURL {
	NSString *remoteURLString = [self primitiveValueForKey:@"remoteURL"];

	if (remoteURLString) {
		return [NSURL URLWithString:remoteURLString];
	} else {
		return nil;
	}
}

- (NSURL *)remoteThumbnailURL {
	NSString *remoteThumbnailURLString = [self primitiveValueForKey:@"remoteThumbnailURL"];

	if (remoteThumbnailURLString) {
		return [NSURL URLWithString:remoteThumbnailURLString];
	} else {
		return nil;
	}
}

- (NSURL *)beginMoveToStorageFrom:(NSURL *)temporaryLocation {
	if (temporaryLocation && temporaryLocation.isFileURL) {
		NSString *name = [[ATUtilities randomStringOfLength:20] stringByAppendingPathExtension:self.extension];
		NSURL *newLocation = [NSURL fileURLWithPath:[[self class] fullLocalPathForFilename:name]];
		NSError *error = nil;
		if ([[NSFileManager defaultManager] moveItemAtURL:temporaryLocation toURL:newLocation error:&error]) {
			return newLocation;
		} else {
			ATLogError(@"Unable to write attachment to URL: %@, %@", newLocation, error);
			return nil;
		}
	} else {
		ATLogError(@"Temporary file location (%@) is nil or not file URL", temporaryLocation);
		return nil;
	}
}

- (void)completeMoveToStorageFor:(NSURL *)storageLocation {
	[self deleteSidecarIfNecessary];
	self.localPath = storageLocation.lastPathComponent;
}

- (NSString *)fullLocalPath {
	return [[self class] fullLocalPathForFilename:self.localPath];
}

- (NSString *)extension {
	NSString *_extension = nil;

	if (self.mimeType) {
		CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(self.mimeType), NULL);
		CFStringRef cf_extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
		CFRelease(uti);
		if (cf_extension) {
			_extension = [(__bridge NSString *)cf_extension copy];
			CFRelease(cf_extension);
		}
	}

	if (_extension.length == 0 && self.name) {
		_extension = self.name.pathExtension;
	}

	if (_extension.length == 0 && self.remoteURL) {
		_extension = self.remoteURL.pathExtension;
	}

	if (_extension.length == 0) {
		_extension = @"file";
	}

	return _extension;
}

- (BOOL)canCreateThumbnail {
	return [[self class] canCreateThumbnailForMIMEType:self.mimeType];
}

+ (NSString *)fullLocalPathForFilename:(NSString *)filename {
	if (!filename) {
		return nil;
	}
	return [[[ATBackend sharedBackend] attachmentDirectoryPath] stringByAppendingPathComponent:filename];
}

- (NSString *)filenameForThumbnailOfSize:(CGSize)size {
	if (self.localPath == nil) {
		return nil;
	}
	return [NSString stringWithFormat:@"%@_%dx%d_fit.jpeg", self.localPath, (int)floor(size.width), (int)floor(size.height)];
}

- (void)deleteSidecarIfNecessary {
	if (self.localPath) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *fullPath = [self fullLocalPath];
		NSError *error = nil;
		BOOL isDir = NO;
		if (![fm fileExistsAtPath:fullPath isDirectory:&isDir] || isDir) {
			ATLogError(@"File attachment sidecar doesn't exist at path or is directory: %@, %d", fullPath, isDir);
			return;
		}
		if (![fm removeItemAtPath:fullPath error:&error]) {
			ATLogError(@"Error removing attachment at path: %@. %@", fullPath, error);
			return;
		}
		// Delete any thumbnails.
		NSArray *filenames = [fm contentsOfDirectoryAtPath:[[ATBackend sharedBackend] attachmentDirectoryPath] error:&error];
		if (!filenames) {
			ATLogError(@"Error listing attachments directory: %@", error);
		} else {
			for (NSString *filename in filenames) {
				if ([filename rangeOfString:self.localPath].location == 0) {
					NSString *thumbnailPath = [[self class] fullLocalPathForFilename:filename];

					if (![fm removeItemAtPath:thumbnailPath error:&error]) {
						ATLogError(@"Error removing attachment thumbnail at path: %@. %@", thumbnailPath, error);
						continue;
					}
				}
			}
		}
		self.localPath = nil;
	}
}

- (UIImage *)thumbnailOfSize:(CGSize)size {
	NSString *filename = [self filenameForThumbnailOfSize:size];
	if (!filename) {
		return nil;
	}
	NSString *path = [[self class] fullLocalPathForFilename:filename];
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	if (image == nil) {
		image = [self createThumbnailOfSize:size];
	}
	return image;
}

- (UIImage *)createThumbnailOfSize:(CGSize)size {
	CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.fullLocalPath], NULL);
	CFDictionaryRef options = (__bridge CFDictionaryRef) @{
		(id)kCGImageSourceCreateThumbnailWithTransform: @YES,
		(id)
		kCGImageSourceCreateThumbnailFromImageAlways: @YES,
		(id)
		kCGImageSourceThumbnailMaxPixelSize: @(fmax(size.width, size.height))
	};
	CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
	CFRelease(src);

	UIImage *thumbnailImage = nil;

	if (thumbnail) {
		thumbnailImage = [UIImage imageWithCGImage:thumbnail];
		CGImageRelease(thumbnail);

		NSString *filename = [self filenameForThumbnailOfSize:size];
		NSString *fullThumbnailPath = [[self class] fullLocalPathForFilename:filename];
		[UIImagePNGRepresentation(thumbnailImage) writeToFile:fullThumbnailPath atomically:YES];
	}

	return thumbnailImage;
}

@end


@implementation ATFileAttachment (QuickLook)

- (NSString *)previewItemTitle {
	return self.name;
}

- (NSURL *)previewItemURL {
	if (self.localPath) {
		return [NSURL fileURLWithPath:self.fullLocalPath];
	} else {
		// Use fake path
		NSString *name = self.name ?: [[ATUtilities randomStringOfLength:20] stringByAppendingPathExtension:self.extension];
		return [NSURL fileURLWithPath:[[self class] fullLocalPathForFilename:name]];
	}
}

@end

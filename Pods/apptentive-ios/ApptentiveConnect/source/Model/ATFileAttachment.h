//
//  ATFileAttachment.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 2/20/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <QuickLook/QuickLook.h>

@class ATCompoundMessage;


@interface ATFileAttachment : NSManagedObject
@property (strong, nonatomic) NSString *localPath;
@property (strong, nonatomic) NSString *mimeType; // starts w/ lowercase b/c Core Data is stupid
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *remoteURL;
@property (strong, nonatomic) NSURL *remoteThumbnailURL;
@property (strong, nonatomic) ATCompoundMessage *message;

@property (readonly, nonatomic) NSString *fullLocalPath;
@property (readonly, nonatomic) NSString *extension;
@property (readonly, nonatomic) NSData *fileData;
@property (readonly, nonatomic) BOOL canCreateThumbnail;

+ (instancetype)newInstanceWithFileData:(NSData *)fileData MIMEType:(NSString *)MIMEType name:(NSString *)name;
+ (instancetype)newInstanceWithJSON:(NSDictionary *)JSON;
+ (void)addMissingExtensions;
- (void)updateWithJSON:(NSDictionary *)JSON;

- (void)setFileData:(NSData *)data MIMEType:(NSString *)MIMEType name:(NSString *)name;

/** Can be called from background thread. */
- (NSURL *)beginMoveToStorageFrom:(NSURL *)temporaryLocation;

/** Must be called from main thread. */
- (void)completeMoveToStorageFor:(NSURL *)storageLocation;

- (UIImage *)thumbnailOfSize:(CGSize)size;

@end


@interface ATFileAttachment (QuickLook) <QLPreviewItem>
@end

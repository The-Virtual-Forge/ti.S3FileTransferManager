/**
 * S3FileTransferManagerAWSS3TransferManagerUploadRequestProxy
 *
 * Created by Terry Morgan
 * Copyright (c) 2015 The Virtual Forge. All rights reserved.
 */
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy.h"
#import "TiUtils.h"

@implementation ComThevirtualforgeS3filetransfermanagerAWSS3TransferManagerUploadRequestProxy

#pragma mark Internal

-(void)_initWithProperties:(NSDictionary *)properties
{
    AWSS3TransferManagerUploadRequest *ur =[AWSS3TransferManagerUploadRequest new];
    
    ur.bucket = [properties objectForKey:@"bucket"];
    ur.key = [properties objectForKey:@"key"];
    
    id _metadata = [properties objectForKey:@"metadata"];
    if (_metadata) {
        ur.metadata = _metadata;
    }
    
    ur.body = [NSURL URLWithString:[properties objectForKey:@"body"]];
    
    KrollCallback* progressCallback = [properties objectForKey:@"progressCallback"];
    
    ur.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Calling progress callback");
            if (progressCallback) {
                NSDictionary *eventData = @{
                                           @"bytesSent": [NSNumber numberWithLongLong:bytesSent],
                                           @"totalBytesSent": [NSNumber numberWithLongLong:totalBytesSent],
                                           @"totalBytesExpectedToSend": [NSNumber numberWithLongLong:totalBytesExpectedToSend],
                                           @"bucket": bucket,
                                           @"key": key
                                           };
                NSArray* arrayOfValues = [NSArray arrayWithObjects: eventData, nil];
                [progressCallback call:arrayOfValues thisObject:nil];
            }
        });
    };
    
    [self setUploadRequest:ur];
    [super _initWithProperties:properties];
}

-(void)_destroy
{
    [super _destroy];
}

#pragma mark Cleanup

-(void)dealloc
{
    // release any resources that have been retained by the module
    [uploadRequest release];
    [key release];
    [bucket release];
    [body release];
    [metadata release];

    [super dealloc];
}

#pragma Public APIs

- (AWSS3TransferManagerUploadRequest *)uploadRequest;
{
    return uploadRequest;
}

-(NSString *)state
{
    NSString *uploadState;
    
    if (uploadRequest) {
        switch (uploadRequest.state) {
            case AWSS3TransferManagerRequestStateNotStarted:
                uploadState = @"Not started";
                break;
                
            case AWSS3TransferManagerRequestStateRunning:
                uploadState = @"Running";
                break;
                
            case AWSS3TransferManagerRequestStatePaused:
                uploadState = @"Paused";
                break;

            case AWSS3TransferManagerRequestStateCanceling:
                uploadState = @"Canceling";
                break;
                
            case AWSS3TransferManagerRequestStateCompleted:
                uploadState = @"Completed";
                break;
                
            default:
                uploadState = @"Unknown";
                break;
        }
    } else {
        uploadState = @"Invalid";
    }

    return uploadState;
}

-(NSString *)key
{
    return key;
}

-(NSURL *)body
{
    return body;
}

-(NSString *)bucket
{
    return bucket;
}

-(NSDictionary *)metadata
{
    return metadata;
}

- (void)setUploadRequest:(AWSS3TransferManagerUploadRequest *)ur
{
    [uploadRequest autorelease];
    uploadRequest = [ur retain];
}

-(void)setKey:(id)_key
{
    [key autorelease];
    key = [TiUtils stringValue:_key];
}

-(void)setBody:(id)_body
{
    [body autorelease];
    body = [NSURL URLWithString:[TiUtils stringValue:_body]];
}

-(void)setBucket:(id)_bucket
{
    [bucket autorelease];
    bucket = [TiUtils stringValue:_bucket];
}

-(void)setMetadata:(id)_metadata
{
    [metadata autorelease];
    metadata = _metadata;
}

-(void)pauseUpload:(id)args
{
    [[uploadRequest pause] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"The pause request failed: [%@]", task.error);
        }
        return nil;
    }];
}

-(void)cancel:(id)args

{
    [[uploadRequest cancel] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"The cancel request failed: [%@]", task.error);
        }
        return nil;
    }];
}

-(void)onPaused
{
    NSLog(@"onPaused");
    if ([self _hasListeners:@"paused"]) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @false,
                                       @"paused": @true,
                                       @"bucket": bucket,
                                       @"key": key
                                       };
        [self fireEvent:@"paused" withObject:eventPayload];
    }
}

-(void)onCancelled
{
    NSLog(@"onCancelled");
    if ([self _hasListeners:@"cancelled"]) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @true,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key
                                       };
        [self fireEvent:@"cancelled" withObject:eventPayload];
    }
}

-(void)onSuccess:(AWSS3TransferManagerUploadOutput *)result
{
    NSLog(@"onSuccess");
    if ([self _hasListeners:@"success"]) {
        NSDictionary *eventPayload = @{
                                       @"success": @true,
                                       @"cancelled": @false,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key,
                                       @"result": @{
                                               @"ETAG": result.ETag
                                               }
                                       };
        [self fireEvent:@"success" withObject:eventPayload];
    }
}

-(void)onError:(NSError *)error
{
    NSLog(@"onError");
    if ([self _hasListeners:@"error"]) {
        NSDictionary *eventPayload = @{
                                       @"success": @false,
                                       @"cancelled": @false,
                                       @"paused": @false,
                                       @"bucket": bucket,
                                       @"key": key,
                                       @"error": @{
                                               @"code": NUMLONG(error.code),
                                               @"domain": error.domain,
                                               @"userInfo": error.userInfo
                                               }
                                       };
        [self fireEvent:@"error" withObject:eventPayload];
    }
}


@end
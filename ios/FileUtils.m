#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <math.h>

#import "FileUtils.h"

@implementation FileUtils

RCT_EXPORT_MODULE()

/**
 * Gets the duration of a video in seconds.
 * @param path - The video file path to get the duration of.
 * @returns The duration in seconds of the video file.
 */
RCT_EXPORT_METHOD(
                  getDuration:(NSString *)path
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    NSURL *referenceUrl = [NSURL URLWithString:path];
    
    if(referenceUrl != nil) {
        AVAsset *asset = [AVAsset assetWithURL:referenceUrl];
        Float64 duration = CMTimeGetSeconds(asset.duration);
        
        if (isnan(duration)) {
            reject(
                   @"QSRNFU-01",
                   @"The duration of the video file is either invalid or indefinite.",
                   nil
                   );
            return;
        }
        
        NSNumber *result = [NSNumber numberWithFloat:duration];
        resolve(result);
    } else {
        reject(
               @"QSRNFU-02",
               @"The path provided is malformed. Unable to obtain a reference URL from the path.",
               nil
               );
        return;
    }
}

/**
 * Gets the MIME type of the file from the passed in URL. The file passed in can be a video or image file format.
 * @param path - The video or image file path to get the MIME type of.
 * @returns The MIME type string of the file from the passed URL.
 */
RCT_EXPORT_METHOD(
                  getMimeType:(NSString *)path
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    NSURL *referenceUrl = [NSURL URLWithString:path];
    CFStringRef fileExtension = (__bridge CFStringRef)[referenceUrl pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    
    if (UTI != nil) {
        CFRelease(UTI);
        resolve((NSString *)CFBridgingRelease(MIMEType));
    } else {
        reject(
               @"QSRNFU-10",
               @"The path provided is malformed. Unable to obtain a reference URL from the path.",
               nil
               );
    }
}

/**
 * Gets the timestamp of the video or image file based on the file path passed in. The  timestamp is retrieved from the Exif data on the
 * image or video file.
 * @param path - The video or image file path to get the timestamp of.
 * @returns The datetime of the image or video file from the file's Exif data.
 */
RCT_EXPORT_METHOD(
                  getTimestamp:(NSString *)path
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSData* imageData =  UIImageJPEGRepresentation(image, 1.0);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    
    NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(sourceRef,0,NULL);
    NSDictionary *exif = [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    NSDictionary *datetime = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
    
    resolve(datetime);
}

@end

/**
 * Gets the pixel dimensions, height and width (x,y), of the video or image file based on the file path passed in.
 * @param path - The video or image file path to get the dimensions of.
 * @param type - Either 'video' or 'image' so the method knows how to process the media file.
 * @returns The height and width (x,y), of the video or image in pixels.
 */
RCT_EXPORT_METHOD(
                  getDimensions:(NSString *)path (NSString *)type
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    if (type == "image") {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        if (image == nil) {
            reject(
                   @"QSRNFU-20",
                   @"The method could not initialize the image from the specified file",
                   nil
                   );
            return;
        }
        
        resolve(image.size.width, image.size.height)
        return;
    } else if (type == "video"){
        let url = AVURLAsset(url: path, options: nil)
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        
        if ([tracks count] > 0) {
            AVAssetTrack *track = [tracks objectAtIndex:0];
            return track.naturalSize;
        }

        resolve(CGSizeMake(0, 0));
        return;
    }
}

@end

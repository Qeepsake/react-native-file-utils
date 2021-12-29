#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <math.h>
#import "FileUtils.h"

@import Photos;

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
                   @"INVALID_DURATION_ERROR",
                   @"The duration of the video file is either invalid or indefinite.",
                   nil
                   );
            return;
        }
        
        NSNumber *result = [NSNumber numberWithFloat:duration];
        resolve(result);
    } else {
        reject(
               @"GET_DURATION_MALFORMED_PATH_ERROR",
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
    if([path hasPrefix:@"ph://"]){
        NSString *localIdentifier = [path stringByReplacingOccurrencesOfString:@"ph://" withString:@""];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc]init];
        [fetchResult.firstObject requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            NSURL *referenceUrl = contentEditingInput.fullSizeImageURL;
            [self getMimeTypeFromReferenceUrl:referenceUrl resolver:resolve rejecter:reject];
        }];
    } else if([path hasPrefix:@"file://"]) {
        NSURL *referenceUrl = [NSURL URLWithString:path];
        [self getMimeTypeFromReferenceUrl:referenceUrl resolver:resolve rejecter:reject];
    } else {
        reject(
               @"GET_MIME_TYPE_NOT_SUPPORTED",
               @"The path provided is not supported. Please provide either a file:// or ph:// (PHAsset)",
               nil
               );
    }
}

- (void) getMimeTypeFromReferenceUrl:(NSURL *)url
    resolver: (RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *ListOfMimeTypes = [self createListOfMIMETypes];
    CFStringRef fileExtension = (__bridge CFStringRef)[url pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    
    if (UTI != nil) {
        CFRelease(UTI);
        resolve((NSString *)CFBridgingRelease(MIMEType));
    } else if(fileExtension != nil) { // Use a fallback lookup array to determine MIME type
        NSString *lookupKey = (__bridge NSString *)fileExtension;
        NSString *lookupResult = [ListOfMimeTypes objectForKey:[lookupKey lowercaseString]];
        resolve(lookupResult);
    } else {
        reject(
               @"GET_MIME_TYPE_MALFORMED_PATH_ERROR",
               @"The path provided is malformed. Unable to obtain a reference URL from the path.",
               nil
               );
    }
}


/**
 * Gets the original date time of the video or image file based on the path passed in. The timestamp is retrieved from the Exif data on the
 * image or video file. Note: Either asset-libarary path or full file path may be passed in.
 * @param path - The video or image file path to get the timestamp of.
 * @param type - Either 'video' or 'image' so the method knows how to process the media file.
 * @returns The string timestamp of the image or video file.
 */
RCT_EXPORT_METHOD(
                  getTimestamp:(NSString *)path
                  fileType:(NSString *)type
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    // Path for getting exif from asset id if image or creation date for video
    if(![path hasPrefix:@"file:///"]) {
        PHAsset* asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[path] options:nil].firstObject;
        PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
        editOptions.networkAccessAllowed = YES;
        
        // If image, use exif data
        if ([type isEqualToString:@"image"]) {
            [asset requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                CIImage *image = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
                NSDictionary *properties = image.properties;
                NSDictionary *exif = [properties objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                NSDictionary *datetime = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
                resolve(datetime);
                return;
            }];
        
        // If not an image, get last modified date
        } else {
            resolve(asset.creationDate);
            return;
        }

    // Path for getting exif from file path if image or creation date for video
    } else {
        NSString *prefixToRemove = @"file:///";
        NSString *pathWithoutFilePrefix = [path copy];
        if ([path hasPrefix:prefixToRemove])
            pathWithoutFilePrefix = [path substringFromIndex:[prefixToRemove length]];
        
        // If image, use exif data
        if ([type isEqualToString:@"image"]) {
            NSData* fileData = [NSData dataWithContentsOfFile:pathWithoutFilePrefix];
            CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((CFDataRef)fileData, NULL);
            if (mySourceRef != NULL)
            {               
                NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
                NSDictionary *exif = [properties objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                NSDictionary *datetime = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
                resolve(datetime);
                return;
            }
            
        // If not an image, get last modified date
        } else {
            NSError *error = nil;
            NSURL *referenceUrl = [NSURL URLWithString:path];
            NSDate *fileDate;
            [referenceUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            
            if (!error)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                NSString *dateString = [dateFormatter stringFromDate:fileDate];
                
                resolve(dateString);
                return;
            }
            
            reject(
                   @"GET_TIMESTAMP_CONTENT_MODIFICATION_DATE_ERROR",
                   @"Error getting file data for file.",
                   error
                   );
        }
    }
}

/**
 * Gets the pixel dimensions, height and width (x,y), of the video file based on the file path passed in.
 * @param path - The video file path to get the dimensions of.
 * @returns The height and width (x,y), of the video or image in pixels.
 */
RCT_EXPORT_METHOD(
                  getVideoDimensions:(NSString *)path
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
    NSURL *referenceUrl = [NSURL URLWithString:path];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:referenceUrl options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if ([tracks count] > 0) {
        AVAssetTrack *track = [tracks objectAtIndex:0];
        
        NSDictionary *dimensions = @{
              @"height":@(track.naturalSize.height),
              @"width":@(track.naturalSize.width),
              };
        
        resolve(dimensions);
        return;
    }

    NSDictionary *dimensions = @{
          @"height":@0,
          @"width":@0,
          };
    
    resolve(dimensions);
    return;
}

- (NSMutableDictionary* ) createListOfMIMETypes {
    NSMutableDictionary *ListOfMimeTypes = [[NSMutableDictionary alloc] init];
      [ListOfMimeTypes setObject:@"image/jpeg" forKey:@"jpg"];
      [ListOfMimeTypes setObject:@"text/html" forKey:@"html"];
      [ListOfMimeTypes setObject:@"text/htm" forKey:@"html"];
      [ListOfMimeTypes setObject:@"text/html" forKey:@"shtml"];
      [ListOfMimeTypes setObject:@"text/css" forKey:@"css"];
      [ListOfMimeTypes setObject:@"text/xml" forKey:@"xml"];
      [ListOfMimeTypes setObject:@"image/gif" forKey:@"gif"];
      [ListOfMimeTypes setObject:@"image/jpeg" forKey:@"jpeg"];
      [ListOfMimeTypes setObject:@"image/jpeg" forKey:@"jpg"];
      [ListOfMimeTypes setObject:@"image/heic" forKey:@"heic"];
      [ListOfMimeTypes setObject:@"image/heif" forKey:@"heif"];
      [ListOfMimeTypes setObject:@"application/javascript" forKey:@"js"];
      [ListOfMimeTypes setObject:@"application/atom+xml" forKey:@"atom"];
      [ListOfMimeTypes setObject:@"application/rss+xml" forKey:@"rss"];
      [ListOfMimeTypes setObject:@"text/mathml" forKey:@"mml"];
      [ListOfMimeTypes setObject:@"text/plain" forKey:@"txt"];
      [ListOfMimeTypes setObject:@"text/vnd.sun.j2me.app-descriptor" forKey:@"jad"];
      [ListOfMimeTypes setObject:@"text/vnd.wap.wml" forKey:@"wml"];
      [ListOfMimeTypes setObject:@"text/x-component" forKey:@"htc"];
      [ListOfMimeTypes setObject:@"image/png" forKey:@"png"];
      [ListOfMimeTypes setObject:@"image/tiff" forKey:@"tif"];
      [ListOfMimeTypes setObject:@"image/tiff" forKey:@"tiff"];
      [ListOfMimeTypes setObject:@"image/vnd.wap.wbmp" forKey:@"wbmp"];
      [ListOfMimeTypes setObject:@"image/x-icon" forKey:@"ico"];
      [ListOfMimeTypes setObject:@"image/x-jng" forKey:@"jng"];
      [ListOfMimeTypes setObject:@"image/x-ms-bmp" forKey:@"bmp"];
      [ListOfMimeTypes setObject:@"image/svg+xml" forKey:@"svg"];
      [ListOfMimeTypes setObject:@"image/svg+xml" forKey:@"svgz"];
      [ListOfMimeTypes setObject:@"image/webp" forKey:@"webp"];
      [ListOfMimeTypes setObject:@"application/font-woff" forKey:@"woff"];
      [ListOfMimeTypes setObject:@"application/java-archive" forKey:@"jar"];
      [ListOfMimeTypes setObject:@"application/java-archive" forKey:@"war"];
      [ListOfMimeTypes setObject:@"application/java-archive" forKey:@"ear"];
      [ListOfMimeTypes setObject:@"application/json" forKey:@"json"];
      [ListOfMimeTypes setObject:@"application/mac-binhex40" forKey:@"hqx"];
      [ListOfMimeTypes setObject:@"application/msword" forKey:@"doc"];
      [ListOfMimeTypes setObject:@"application/pdf" forKey:@"pdf"];
      [ListOfMimeTypes setObject:@"application/postscript" forKey:@"ps"];
      [ListOfMimeTypes setObject:@"application/postscript" forKey:@"eps"];
      [ListOfMimeTypes setObject:@"application/postscript" forKey:@"ai"];
      [ListOfMimeTypes setObject:@"application/rtf" forKey:@"rtf"];
      [ListOfMimeTypes setObject:@"application/vnd.apple.mpegurl" forKey:@"m3u8"];
      [ListOfMimeTypes setObject:@"application/vnd.ms-excel" forKey:@"xls"];
      [ListOfMimeTypes setObject:@"application/vnd.ms-fontobject" forKey:@"eot"];
      [ListOfMimeTypes setObject:@"application/vnd.ms-powerpoint" forKey:@"ppt"];
      [ListOfMimeTypes setObject:@"application/vnd.wap.wmlc" forKey:@"wmlc"];
      [ListOfMimeTypes setObject:@"application/vnd.google-earth.kml+xml" forKey:@"kml"];
      [ListOfMimeTypes setObject:@"application/vnd.google-earth.kmz" forKey:@"kmz"];
      [ListOfMimeTypes setObject:@"application/x-7z-compressed" forKey:@"7z"];
      [ListOfMimeTypes setObject:@"application/x-cocoa" forKey:@"cco"];
      [ListOfMimeTypes setObject:@"application/x-java-archive-diff" forKey:@"jardiff"];
      [ListOfMimeTypes setObject:@"application/x-java-jnlp-file" forKey:@"jnlp"];
      [ListOfMimeTypes setObject:@"application/x-makeself" forKey:@"run"];
      [ListOfMimeTypes setObject:@"application/x-perl" forKey:@"pl"];
      [ListOfMimeTypes setObject:@"application/x-perl" forKey:@"pm"];
      [ListOfMimeTypes setObject:@"application/x-pilot" forKey:@"prc"];
      [ListOfMimeTypes setObject:@"application/x-pilot" forKey:@"pdb"];
      [ListOfMimeTypes setObject:@"application/x-rar-compressed" forKey:@"rar"];
      [ListOfMimeTypes setObject:@"application/x-redhat-package-manager" forKey:@"rpm"];
      [ListOfMimeTypes setObject:@"application/x-sea" forKey:@"sea"];
      [ListOfMimeTypes setObject:@"application/x-shockwave-flash" forKey:@"swf"];
      [ListOfMimeTypes setObject:@"application/x-stuffit" forKey:@"sit"];
      [ListOfMimeTypes setObject:@"application/x-tcl" forKey:@"tcl"];
      [ListOfMimeTypes setObject:@"application/x-tcl" forKey:@"tk"];
      [ListOfMimeTypes setObject:@"application/x-x509-ca-cert" forKey:@"der"];
      [ListOfMimeTypes setObject:@"application/x-x509-ca-cert" forKey:@"pem"];
      [ListOfMimeTypes setObject:@"application/x-x509-ca-cert" forKey:@"crt"];
      [ListOfMimeTypes setObject:@"application/x-xpinstall" forKey:@"xpi"];
      [ListOfMimeTypes setObject:@"application/xhtml+xml" forKey:@"xhtml"];
      [ListOfMimeTypes setObject:@"application/xspf+xml" forKey:@"xspf"];
      [ListOfMimeTypes setObject:@"application/zip" forKey:@"zip"];
      [ListOfMimeTypes setObject:@"application/epub+zip" forKey:@"epub"];
      [ListOfMimeTypes setObject:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document" forKey:@"docx"];
      [ListOfMimeTypes setObject:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" forKey:@"xlsx"];
      [ListOfMimeTypes setObject:@"application/vnd.openxmlformats-officedocument.presentationml.presentation" forKey:@"pptx"];
      [ListOfMimeTypes setObject:@"audio/midi" forKey:@"mid"];
      [ListOfMimeTypes setObject:@"audio/midi" forKey:@"midi"];
      [ListOfMimeTypes setObject:@"audio/midi" forKey:@"kar"];
      [ListOfMimeTypes setObject:@"audio/mpeg" forKey:@"mp3"];
      [ListOfMimeTypes setObject:@"audio/ogg" forKey:@"ogg"];
      [ListOfMimeTypes setObject:@"audio/x-m4a" forKey:@"m4a"];
      [ListOfMimeTypes setObject:@"audio/x-realaudio" forKey:@"ra"];
      [ListOfMimeTypes setObject:@"video/3gpp" forKey:@"3gpp"];
      [ListOfMimeTypes setObject:@"video/3gpp" forKey:@"3gp"];
      [ListOfMimeTypes setObject:@"video/mp2t" forKey:@"ts"];
      [ListOfMimeTypes setObject:@"video/mp4" forKey:@"mp4"];
      [ListOfMimeTypes setObject:@"video/mpeg" forKey:@"mpeg"];
      [ListOfMimeTypes setObject:@"video/mpeg" forKey:@"mpg"];
      [ListOfMimeTypes setObject:@"video/quicktime" forKey:@"mov"];
      [ListOfMimeTypes setObject:@"video/webm" forKey:@"webm"];
      [ListOfMimeTypes setObject:@"video/x-flv" forKey:@"flv"];
      [ListOfMimeTypes setObject:@"video/x-m4v" forKey:@"m4v"];
      [ListOfMimeTypes setObject:@"video/x-mng" forKey:@"mng"];
      [ListOfMimeTypes setObject:@"video/x-ms-asf" forKey:@"asx"];
      [ListOfMimeTypes setObject:@"video/x-ms-asf" forKey:@"asf"];
      [ListOfMimeTypes setObject:@"video/x-ms-wmv" forKey:@"wmv"];
      [ListOfMimeTypes setObject:@"video/x-msvideo" forKey:@"avi"];
    
    return ListOfMimeTypes;
}

@end

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
    NSMutableDictionary *ListOfMimeTypes = [[NSMutableDictionary alloc] init];
    [ListOfMimeTypes setObject:@"image/jpeg" forKey:@"jpg"];
      [ListOfMimeTypes setObject:@"html" forKey:@"text/html"];
      [ListOfMimeTypes setObject:@"htm" forKey:@"text/html"];
      [ListOfMimeTypes setObject:@"shtml" forKey:@"text/html"];
      [ListOfMimeTypes setObject:@"css" forKey:@"text/css"];
      [ListOfMimeTypes setObject:@"xml" forKey:@"text/xml"];
      [ListOfMimeTypes setObject:@"gif" forKey:@"image/gif"];
      [ListOfMimeTypes setObject:@"jpeg" forKey:@"image/jpeg"];
      [ListOfMimeTypes setObject:@"jpg" forKey:@"image/jpeg"];
      [ListOfMimeTypes setObject:@"js" forKey:@"application/javascript"];
      [ListOfMimeTypes setObject:@"atom" forKey:@"application/atom+xml"];
      [ListOfMimeTypes setObject:@"rss" forKey:@"application/rss+xml"];
      [ListOfMimeTypes setObject:@"mml" forKey:@"text/mathml"];
      [ListOfMimeTypes setObject:@"txt" forKey:@"text/plain"];
      [ListOfMimeTypes setObject:@"jad" forKey:@"text/vnd.sun.j2me.app-descriptor"];
      [ListOfMimeTypes setObject:@"wml" forKey:@"text/vnd.wap.wml"];
      [ListOfMimeTypes setObject:@"htc" forKey:@"text/x-component"];
      [ListOfMimeTypes setObject:@"png" forKey:@"image/png"];
      [ListOfMimeTypes setObject:@"tif" forKey:@"image/tiff"];
      [ListOfMimeTypes setObject:@"tiff" forKey:@"image/tiff"];
      [ListOfMimeTypes setObject:@"wbmp" forKey:@"image/vnd.wap.wbmp"];
      [ListOfMimeTypes setObject:@"ico" forKey:@"image/x-icon"];
      [ListOfMimeTypes setObject:@"jng" forKey:@"image/x-jng"];
      [ListOfMimeTypes setObject:@"bmp" forKey:@"image/x-ms-bmp"];
      [ListOfMimeTypes setObject:@"svg" forKey:@"image/svg+xml"];
      [ListOfMimeTypes setObject:@"svgz" forKey:@"image/svg+xml"];
      [ListOfMimeTypes setObject:@"webp" forKey:@"image/webp"];
      [ListOfMimeTypes setObject:@"woff" forKey:@"application/font-woff"];
      [ListOfMimeTypes setObject:@"jar" forKey:@"application/java-archive"];
      [ListOfMimeTypes setObject:@"war" forKey:@"application/java-archive"];
      [ListOfMimeTypes setObject:@"ear" forKey:@"application/java-archive"];
      [ListOfMimeTypes setObject:@"json" forKey:@"application/json"];
      [ListOfMimeTypes setObject:@"hqx" forKey:@"application/mac-binhex40"];
      [ListOfMimeTypes setObject:@"doc" forKey:@"application/msword"];
      [ListOfMimeTypes setObject:@"pdf" forKey:@"application/pdf"];
      [ListOfMimeTypes setObject:@"ps" forKey:@"application/postscript"];
      [ListOfMimeTypes setObject:@"eps" forKey:@"application/postscript"];
      [ListOfMimeTypes setObject:@"ai" forKey:@"application/postscript"];
      [ListOfMimeTypes setObject:@"rtf" forKey:@"application/rtf"];
      [ListOfMimeTypes setObject:@"m3u8" forKey:@"application/vnd.apple.mpegurl"];
      [ListOfMimeTypes setObject:@"xls" forKey:@"application/vnd.ms-excel"];
      [ListOfMimeTypes setObject:@"eot" forKey:@"application/vnd.ms-fontobject"];
      [ListOfMimeTypes setObject:@"ppt" forKey:@"application/vnd.ms-powerpoint"];
      [ListOfMimeTypes setObject:@"wmlc" forKey:@"application/vnd.wap.wmlc"];
      [ListOfMimeTypes setObject:@"kml" forKey:@"application/vnd.google-earth.kml+xml"];
      [ListOfMimeTypes setObject:@"kmz" forKey:@"application/vnd.google-earth.kmz"];
      [ListOfMimeTypes setObject:@"7z" forKey:@"application/x-7z-compressed"];
      [ListOfMimeTypes setObject:@"cco" forKey:@"application/x-cocoa"];
      [ListOfMimeTypes setObject:@"jardiff" forKey:@"application/x-java-archive-diff"];
      [ListOfMimeTypes setObject:@"jnlp" forKey:@"application/x-java-jnlp-file"];
      [ListOfMimeTypes setObject:@"run" forKey:@"application/x-makeself"];
      [ListOfMimeTypes setObject:@"pl" forKey:@"application/x-perl"];
      [ListOfMimeTypes setObject:@"pm" forKey:@"application/x-perl"];
      [ListOfMimeTypes setObject:@"prc" forKey:@"application/x-pilot"];
      [ListOfMimeTypes setObject:@"pdb" forKey:@"application/x-pilot"];
      [ListOfMimeTypes setObject:@"rar" forKey:@"application/x-rar-compressed"];
      [ListOfMimeTypes setObject:@"rpm" forKey:@"application/x-redhat-package-manager"];
      [ListOfMimeTypes setObject:@"sea" forKey:@"application/x-sea"];
      [ListOfMimeTypes setObject:@"swf" forKey:@"application/x-shockwave-flash"];
      [ListOfMimeTypes setObject:@"sit" forKey:@"application/x-stuffit"];
      [ListOfMimeTypes setObject:@"tcl" forKey:@"application/x-tcl"];
      [ListOfMimeTypes setObject:@"tk" forKey:@"application/x-tcl"];
      [ListOfMimeTypes setObject:@"der" forKey:@"application/x-x509-ca-cert"];
      [ListOfMimeTypes setObject:@"pem" forKey:@"application/x-x509-ca-cert"];
      [ListOfMimeTypes setObject:@"crt" forKey:@"application/x-x509-ca-cert"];
      [ListOfMimeTypes setObject:@"xpi" forKey:@"application/x-xpinstall"];
      [ListOfMimeTypes setObject:@"xhtml" forKey:@"application/xhtml+xml"];
      [ListOfMimeTypes setObject:@"xspf" forKey:@"application/xspf+xml"];
      [ListOfMimeTypes setObject:@"zip" forKey:@"application/zip"];
      [ListOfMimeTypes setObject:@"epub" forKey:@"application/epub+zip"];
      [ListOfMimeTypes setObject:@"docx" forKey:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"];
      [ListOfMimeTypes setObject:@"xlsx" forKey:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"];
      [ListOfMimeTypes setObject:@"pptx" forKey:@"application/vnd.openxmlformats-officedocument.presentationml.presentation"];
      [ListOfMimeTypes setObject:@"mid" forKey:@"audio/midi"];
      [ListOfMimeTypes setObject:@"midi" forKey:@"audio/midi"];
      [ListOfMimeTypes setObject:@"kar" forKey:@"audio/midi"];
      [ListOfMimeTypes setObject:@"mp3" forKey:@"audio/mpeg"];
      [ListOfMimeTypes setObject:@"ogg" forKey:@"audio/ogg"];
      [ListOfMimeTypes setObject:@"m4a" forKey:@"audio/x-m4a"];
      [ListOfMimeTypes setObject:@"ra" forKey:@"audio/x-realaudio"];
      [ListOfMimeTypes setObject:@"3gpp" forKey:@"video/3gpp"];
      [ListOfMimeTypes setObject:@"3gp" forKey:@"video/3gpp"];
      [ListOfMimeTypes setObject:@"ts" forKey:@"video/mp2t"];
      [ListOfMimeTypes setObject:@"mp4" forKey:@"video/mp4"];
      [ListOfMimeTypes setObject:@"mpeg" forKey:@"video/mpeg"];
      [ListOfMimeTypes setObject:@"mpg" forKey:@"video/mpeg"];
      [ListOfMimeTypes setObject:@"mov" forKey:@"video/quicktime"];
      [ListOfMimeTypes setObject:@"webm" forKey:@"video/webm"];
      [ListOfMimeTypes setObject:@"flv" forKey:@"video/x-flv"];
      [ListOfMimeTypes setObject:@"m4v" forKey:@"video/x-m4v"];
      [ListOfMimeTypes setObject:@"mng" forKey:@"video/x-mng"];
      [ListOfMimeTypes setObject:@"asx" forKey:@"video/x-ms-asf"];
      [ListOfMimeTypes setObject:@"asf" forKey:@"video/x-ms-asf"];
      [ListOfMimeTypes setObject:@"wmv" forKey:@"video/x-ms-wmv"];
      [ListOfMimeTypes setObject:@"avi" forKey:@"video/x-msvideo"];

    NSURL *referenceUrl = [NSURL URLWithString:path];
    CFStringRef fileExtension = (__bridge CFStringRef)[referenceUrl pathExtension];
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

@end

package com.reactnativefileutils;

import android.content.ContentResolver;
import android.media.ExifInterface;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;
import android.webkit.URLUtil;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

@ReactModule(name = FileUtilsModule.NAME)
public class FileUtilsModule extends ReactContextBaseJavaModule {
  public static final String NAME = "FileUtils";
  public ReactApplicationContext mContext;

  public FileUtilsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mContext = reactContext;
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  /**
   * Gets the duration of a video in seconds.
   *
   * @param uri - The video file path to get the duration of.
   * @returns The duration in seconds of the video file.
   */
  @ReactMethod
  public void getDuration(String uri, Promise promise) {
    try {
      Uri fileUri = Uri.parse(uri);
      MediaMetadataRetriever retriever = GetMediaMetadataRetriever(fileUri);
      String time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
      float durationInSeconds = Float.parseFloat(time) / 1000;
      retriever.release();

      promise.resolve(String.valueOf(durationInSeconds));
    } catch (Exception e) {
      promise.reject("Error getting duration of video", e);
    }
  }

  /**
   * Gets the pixel dimensions, height and width (x,y), of the video file based on the
   * file path passed in.
   *
   * @param uri - The video file path to get the dimensions of.
   * @returns The height and width (x,y), of the video in pixels.
   */
  @ReactMethod
  public void getVideoDimensions(String uri, Promise promise) {
    Uri fileUri = Uri.parse(uri);
    try {
      MediaMetadataRetriever retriever = GetMediaMetadataRetriever(fileUri);
      String height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
      String width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
      retriever.release();

      WritableMap map = Arguments.createMap();
      map.putString("height", height);
      map.putString("width", width);
      promise.resolve(map);
    } catch (Exception e) {
      promise.reject("Error getting dimensions", e);
    }
  }

  /**
   * Gets the MIME type of the file from the passed in URL. The file passed in can be a video or image file format.
   *
   * @param uri - The video or image file path to get the MIME type of.
   * @returns The MIME type string of the file from the passed URL.
   */
  @ReactMethod
  public void getMimeType(String uri, Promise promise) {
    if(URLUtil.isContentUrl(uri)) {
      Uri contentUri = Uri.parse(uri);
      ContentResolver contentResolver = mContext.getContentResolver();
      String mimeType = contentResolver.getType(contentUri);
      promise.resolve(mimeType);
    } else if(URLUtil.isFileUrl(uri)) {
      String type = null;
      String extension = MimeTypeMap.getFileExtensionFromUrl(uri);

      // Typically images do have an extension at this point while videos on Android from the picker
      // do not have an extension. If there's no extension, try to get the extension from the
      // contents as the file is likely a video.
      if (extension != null && !extension.isEmpty()) {
        type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        promise.resolve(type);
        return;
      }

      try {
        Uri fileUri = Uri.parse(uri);
        MediaMetadataRetriever retriever = GetMediaMetadataRetriever(fileUri);
        String mimeType = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE);
        retriever.release();

        promise.resolve(mimeType);
        return;
      } catch (Exception e) {
        promise.reject("Error getting mime type", e);
      }
    }
  }

  /**
   * Gets the original date time of the video or image file based on the path passed in. The
   * ISO datetime is retrieved from the Exif data on the image or video file.
   *
   * @param uri       - The video or image file path to get the timestamp of.
   * @param mediaType - Either 'video' or 'image' so the method knows how to process the media file.
   * @returns String ISO datetime of the image or video file from the file's Exif data.
   */
  @ReactMethod
  public void getTimestamp(String uri, String mediaType, Promise promise) {
    try {
      Uri fileUri = Uri.parse(uri);

      // Handle getting mime type for images
      if (mediaType.equalsIgnoreCase("image")) {
        InputStream inputStream = null;

        if(URLUtil.isContentUrl(uri)) {
          inputStream = mContext.getContentResolver().openInputStream(fileUri);
        } else if(URLUtil.isFileUrl(uri)) {
          inputStream = new FileInputStream(uri);
        }

        if(inputStream != null) {
          if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            ExifInterface exif = new ExifInterface(inputStream);
            String timestamp = exif.getAttribute(ExifInterface.TAG_DATETIME);

            Date date = new SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.US).parse(timestamp);
            String formattedDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.US).format(date);

            promise.resolve(formattedDate);
          } else {
            promise.reject("Android version must be above: " + android.os.Build.VERSION_CODES.N);
          }
        } else {
          promise.reject("File path not supported: " + uri);
        }
        // Handle getting mime type for videos
      } else {
        MediaMetadataRetriever retriever = GetMediaMetadataRetriever(fileUri);
        String timestamp = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
        Date date = new SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.US).parse(timestamp);
        String formattedDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.US).format(date);
        retriever.release();

        promise.resolve(formattedDate);
      }
    } catch (Exception e) {
      promise.reject("Error getting timestamp of media file", e);
    }
  }

  private MediaMetadataRetriever GetMediaMetadataRetriever(Uri fileUri) throws FileNotFoundException {
    try {
      FileDescriptor fileDescriptor = getReactApplicationContext().getContentResolver().openAssetFileDescriptor(fileUri, "r").getFileDescriptor();
      MediaMetadataRetriever retriever = new MediaMetadataRetriever();
      retriever.setDataSource(fileDescriptor);
      return retriever;
    } catch (FileNotFoundException e) {
      throw e;
    }
  }
}

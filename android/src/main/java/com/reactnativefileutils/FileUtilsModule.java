package com.reactnativefileutils;

import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.io.File;
import java.io.FileDescriptor;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

@ReactModule(name = FileUtilsModule.NAME)
public class FileUtilsModule extends ReactContextBaseJavaModule {
  public static final String NAME = "FileUtils";

  public FileUtilsModule(ReactApplicationContext reactContext) {
    super(reactContext);
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
      FileDescriptor fileDescriptor = getReactApplicationContext().getContentResolver().openAssetFileDescriptor(fileUri, "r").getFileDescriptor();
      MediaMetadataRetriever retriever = new MediaMetadataRetriever();

      retriever.setDataSource(fileDescriptor);
      String time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
      float durationInSeconds = Float.parseFloat(time) / 1000;
      retriever.release();

      promise.resolve(String.valueOf(durationInSeconds));
    } catch (Exception e) {
      promise.reject("Error getting duration of video", e);
    }
  }

  /**
   * Gets the pixel dimensions, height and width (x,y), of the video or image file based on the
   * file path passed in.
   *
   * @param uri       - The video or image file path to get the dimensions of.
   * @param mediaType - Either 'video' or 'image' so the method knows how to process the media file.
   * @returns The height and width (x,y), of the video or image in pixels.
   */
  @ReactMethod
  public void getDimensions(String uri, String mediaType, Promise promise) {
    Uri fileUri = Uri.parse(uri);
    try {

      // Handle getting image dimensions
      if (mediaType.equalsIgnoreCase("image")) {
        InputStream inputStream = getReactApplicationContext().getContentResolver().openInputStream(fileUri);
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(inputStream, null, options);
        String width = String.valueOf(options.outWidth);
        String height = String.valueOf(options.outHeight);

        WritableMap map = Arguments.createMap();
        map.putString("height", height);
        map.putString("width", width);
        promise.resolve(map);

        // Handle getting video dimensions
      } else {

        FileDescriptor fileDescriptor = getReactApplicationContext().getContentResolver().openAssetFileDescriptor(fileUri, "r").getFileDescriptor();
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();

        retriever.setDataSource(fileDescriptor);
        String height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
        String width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
        retriever.release();

        WritableMap map = Arguments.createMap();
        map.putString("height", height);
        map.putString("width", width);
        promise.resolve(map);
      }
    } catch (Exception e) {
      promise.reject("Error getting dimensions", e);
    }
  }

  /**
   * Gets the MIME type of the file from the passed in URL. The file passed in can be a video or image file format.
   *
   * @param uri       - The video or image file path to get the MIME type of.
   * @param mediaType - Either 'video' or 'image' so the method knows how to process the media file.
   * @returns The MIME type string of the file from the passed URL.
   */
  @ReactMethod
  public void getMimeType(String uri, String mediaType, Promise promise) {
    // Handle getting mime type for images
    if (mediaType.equalsIgnoreCase("image")) {
      String type = null;
      String extension = MimeTypeMap.getFileExtensionFromUrl(uri);
      if (extension != null) {
        type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
      }
      promise.resolve(type);

      // Handle getting mime type for videos
    } else {
      try {
        Uri fileUri = Uri.parse(uri);
        FileDescriptor fileDescriptor = getReactApplicationContext().getContentResolver().openAssetFileDescriptor(fileUri, "r").getFileDescriptor();
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();

        retriever.setDataSource(fileDescriptor);
        String mimeType = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE);
        retriever.release();

        promise.resolve(mimeType);
      } catch (Exception e) {
        promise.reject("Error getting mime type of video", e);
      }
    }
  }

  /**
   * Gets the original date time of the video or image file based on the path passed in. The
   * ISO datetime is retrieved from the Exif data on the image or video file.
   *
   * @param uri       - The video or image file path to get the timestamp of.
   * @param mediaType - Either 'video' or 'image' so the method knows how to process the media file.
   * @returns ISO datetime of the image or video file from the file's Exif data.
   */
  @ReactMethod
  public void getTimestamp(String uri, String mediaType, Promise promise) {
    try {
      Uri fileUri = Uri.parse(uri);

      // Handle getting mime type for images
      if (mediaType.equalsIgnoreCase("image")) {
        InputStream inputStream = getReactApplicationContext().getContentResolver().openInputStream(fileUri);
        ExifInterface exif = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
          exif = new ExifInterface(inputStream);
        }

        String timestamp = exif.getAttribute(ExifInterface.TAG_DATETIME);
        Date date = new SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.US).parse(timestamp);
        String formattedDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'", Locale.US).format(date);

        promise.resolve(formattedDate);

        // Handle getting mime type for videos
      } else {
        FileDescriptor fileDescriptor = getReactApplicationContext().getContentResolver().openAssetFileDescriptor(fileUri, "r").getFileDescriptor();
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();

        retriever.setDataSource(fileDescriptor);
        String timestamp = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
        Date date = new SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.US).parse(timestamp);
        String formattedDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'", Locale.US).format(date);
        retriever.release();

        promise.resolve(formattedDate);
      }
    } catch (Exception e) {
      promise.reject("Error getting timestamp of media file", e);
    }
  }

  public static native int nativeGetDuration(String uri);
}

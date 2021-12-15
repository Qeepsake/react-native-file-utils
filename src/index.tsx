import { NativeModules, Platform } from 'react-native';
import type { MediaSize } from './types/MediaSize';

const LINKING_ERROR =
  `The package '@qeepsake/react-native-file-utils' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const FileUtils = NativeModules.FileUtils
  ? NativeModules.FileUtils
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * Gets the duration of the video in seconds.
 * @param uri The full on device uri for the media item.
 * @returns Duration of the video in number of seconds.
 */
export function getDuration(uri: string): Promise<number> {
  return FileUtils.getDuration(uri);
}

/**
 * Gets the horizontal (x) and vertical (y) pixels of the media item, either image or video.
 * @param uri The full on device uri for the media item.
 * @param mediaType - Either 'image' or 'video. If passing an image, 0 will always be returned.
 * @returns MediaSize with height and width of the media item in pixels.
 */
export function getDimensions(
  uri: string,
  mediaType: 'video' | 'image'
): Promise<MediaSize> {
  return FileUtils.getDimensions(uri, mediaType);
}

/**
 * Gets the Mime type of the media file at the passed Uri.
 * @param uri The full on device uri for the media item.
 * @returns The Mime type of the media file.
 */
export function getMimeType(uri: string): Promise<string> {
  return FileUtils.getMimeType(uri);
}

/**
 * Gets the timestamp of the media file at the passed Uri.
 * @param uri The full on device uri for the media item.
 * @returns The timestamp of the media file.
 */
export function getTimestamp(uri: string): Promise<Date> {
  return FileUtils.getTimestamp(uri);
}

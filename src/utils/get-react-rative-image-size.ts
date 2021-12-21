import { Image } from 'react-native';
import type { MediaSize } from 'src/types/MediaSize';

/**
 * Wraps the native react native image size util to return a promise with the MediaSize.
 * @param uri The file Uri path to the image.
 * @returns Promise with MediaSize
 */
export function getReactNativeMediaSize(uri: string): Promise<MediaSize> {
  return new Promise((res, rej) => {
    Image.getSize(
      uri,
      (width, height) => res({ height, width } as MediaSize),
      (err) => rej(err)
    );
  });
}

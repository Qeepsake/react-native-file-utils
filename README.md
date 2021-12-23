# Qeepsake React Native File Utils

Extracts information from image and video files including MIME type, duration (video), dimensions, and timestamp. The library work on iOS and Android and uses Java and Obj-C native library (not Node).

## Installation

```sh
npm install @qeepsake/react-native-file-utils
```

## Usage

### Get the duration of video file

Gets the duration of the video in seconds.

```js
import { getDuration } from '@qeepsake/react-native-file-utils';

const durationMs = await getDuration('file://<media-path>');
```

### Get the media file dimensions in pixels

Gets the horizontal (x) and vertical (y) pixels of the media item, either image or video. The returned media dimensions includes an object with both the horizontal (x) length in pixels and vertical (y) length in pixels.

```js
import { getDimensions } from '@qeepsake/react-native-file-utils';

const mediaDimensions = await getDimensions('file://<media-path>', 'video');
```

### Get the MIME type of a media item file

Gets the MIME type of the media file at the passed Uri.

```js
import { getMimeType } from '@qeepsake/react-native-file-utils';

const mimeType = await getMimeType('file://<media-path>');
```

### Get the timestamp of a media item file

Gets the string timestamp of the media file from the passed Uri. The timestamp is usually a date retrieved
from either the Exif date if the original datetime of the media is available or by the creation/last modified
timestamp from the file itself.

```js
import { getTimestamp } from '@qeepsake/react-native-file-utils';

const timestamp = await getTimestamp('file://<media-path>', 'video');
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

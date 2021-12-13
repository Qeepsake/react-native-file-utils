# Qeepsake react-native-file-utils

## NOTE: Currently a work in progress. Not production ready.

Extract the MIME type of a file with React Native on iOS and Android (uses Java and Obj-C, not Node).

## Installation

```sh
npm install @qeepsake/react-native-file-utils
```

## Usage

### Get video file duration

Gets the duration in milliseconds of the video at the file path on the device that's passed.

```js
import { getDuration } from '@qeepsake/react-native-file-utils';

const durationMs = await getDuration('file://<media-path>', 'video');
```

### Get media file's dimensions in pixels

Gets the horizontal (x) and vertical (y) pixels of the media item, either image or video. The returned media dimensions includes both the horizontal (x) length in pixels and vertical (y) length in pixels.

```js
import { getDimensions } from '@qeepsake/react-native-file-utils';

const mediaDimensions = await getDimensions('file://<media-path>', 'video');
```

### Get media file mime type

Gets the Mime type of the media file at the passed Uri.

```js
import { getMimeType } from '@qeepsake/react-native-file-utils';

const mimeType = await getMimeType('file://<media-path>');
```

### Get timestamp on the media item

Gets the timestamp (js Date) of the media file at the passed Uri.

```js
import { getTimestamp } from '@qeepsake/react-native-file-utils';

const timestamp = await getTimestamp('file://<media-path>');
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

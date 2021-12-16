import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import {
  getDuration,
  getDimensions,
  getMimeType,
  getTimestamp,
} from '@qeepsake/react-native-file-utils';
import { launchImageLibrary } from 'react-native-image-picker';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    // getDuration('file://test').then(setResult);
  }, []);

  const launchPicker = async (pickUsing: 'id' | 'file path') => {
    const pickerResult = await launchImageLibrary({
      includeExtra: true,
      mediaType: 'mixed',
    });

    setResult(0);
    console.dir(pickerResult);

    const asset = pickerResult.assets;
    if (!asset) return;

    const firstAsset = asset[0];
    const uri = firstAsset.uri;
    if (!uri) return;

    const mediaType = firstAsset.type?.includes('image') ? 'image' : 'video';

    console.log(uri);

    console.log('Results from @qeepsake/react-native-file-utils:');
    console.log('-------------');

    const duration = await getDuration(uri);
    console.log('duration:');
    console.log(duration);

    const dimensions = await getDimensions(uri, mediaType);
    console.log('dimensions:');
    console.dir(dimensions);

    const mimeType = await getMimeType(uri);
    console.log('mimeType:');
    console.dir(mimeType);

    if (pickUsing === 'file path') {
      const timestamp = await getTimestamp(uri, mediaType);
      console.log('timestamp:');
      console.dir(timestamp);
    } else {
      const timestamp = await getTimestamp(firstAsset.id!, mediaType);
      console.log('timestamp:');
      console.dir(timestamp);
    }
  };

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
      <Button onPress={() => launchPicker('id')} title="Pick using asset id" />
      <Button
        onPress={() => launchPicker('file path')}
        title="Pick using file path"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});

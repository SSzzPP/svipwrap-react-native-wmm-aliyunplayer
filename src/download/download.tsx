import {
  NativeModules,
  NativeEventEmitter,
  Platform,
  EmitterSubscription,
} from 'react-native';
import RNFS from 'react-native-fs';
import type { IAssumeRole, ICompletion, IProgress } from './types';

const { RNAliMediaDownloader } = NativeModules;
const RNAliMediaEmitter = new NativeEventEmitter(RNAliMediaDownloader);
const defaultFilePath =
  (Platform.OS === 'ios'
    ? RNFS.DocumentDirectoryPath
    : RNFS.ExternalDirectoryPath) + '/media';

export enum EEvent {
  ON_PREPARED = RNAliMediaDownloader.onPrepared,
  ON_ERROR = RNAliMediaDownloader.onError,
  ON_PROCESSING_PROGRESS = RNAliMediaDownloader.onProcessingProgress,
  ON_DOWNLOADING_PROGRESS = RNAliMediaDownloader.onDownloadingProgress,
  ON_COMPLETION = RNAliMediaDownloader.onCompletion,
}

let subscriptions = new Map<string, EmitterSubscription>();

//  下载进度回调事件
export const onDownloadingProgress = (callBack: (data: IProgress) => void) => {
  if (
    subscriptions &&
    subscriptions.has(String(EEvent.ON_DOWNLOADING_PROGRESS))
  ) {
    console.log('你已经订阅过 onDownloadingProgress');
    return;
  }
  const downloadProcesssSubs = RNAliMediaEmitter.addListener(
    String(EEvent.ON_DOWNLOADING_PROGRESS),
    (res: IProgress) => {
      callBack(res);
    }
  );
  subscriptions.set(
    String(EEvent.ON_DOWNLOADING_PROGRESS),
    downloadProcesssSubs
  );
};

/**
 * @description 下载完成回调
 */
export const onDownloaderCompletion = (
  callback: (data: ICompletion) => void
) => {
  if (subscriptions && subscriptions.has(String(EEvent.ON_COMPLETION))) {
    console.log('你已经订阅过 onDownloaderCompletion');
    return;
  }
  const completionSubs = RNAliMediaEmitter.addListener(
    String(EEvent.ON_COMPLETION),
    (res: ICompletion) => {
      callback(res);
    }
  );
  subscriptions.set(String(EEvent.ON_COMPLETION), completionSubs);
};

/**
 * @description 下载准备回调
 */
export const onDownloaderPrepared = (callback: (data: any) => void) => {
  if (subscriptions && subscriptions.has(String(EEvent.ON_PREPARED))) {
    console.log('你已经订阅过 onDownloaderPrepared');
    return;
  }
  const preparedSubs = RNAliMediaEmitter.addListener(
    String(EEvent.ON_PREPARED),
    (res: any) => {
      callback(res);
    }
  );
  subscriptions.set(String(EEvent.ON_PREPARED), preparedSubs);
};

/**
 * @description 下载异常回调
 */
export const onDownloaderError = (callback: (data: any) => void) => {
  if (subscriptions && subscriptions.has(String(EEvent.ON_PREPARED))) {
    console.log('你已经订阅过 onDownloaderError');
    return;
  }
  const errorSubs = RNAliMediaEmitter.addListener(
    String(EEvent.ON_ERROR),
    (res: any) => {
      callback(res);
    }
  );
  subscriptions.set(String(EEvent.ON_ERROR), errorSubs);
};

//  取消监听事件
export const unsubscription = () => {
  if (subscriptions && subscriptions.size > 0) {
    for (let value of subscriptions.values()) {
      value.remove();
    }
    subscriptions.clear();
  }
};

// 设置下载路径
export const setSaveDirectory = (
  vid: string,
  trackIndex = 0,
  filePath?: string
) => {
  if (!filePath) filePath = defaultFilePath;
  RNAliMediaDownloader.setSaveDirectory(filePath, vid, trackIndex);
};

// 准备下载
export const prepareWithVid = async (vid: string, role: IAssumeRole) => {
  RNAliMediaDownloader.prepareWithVid(
    vid,
    role.AccessKeyId,
    role.AccessKeySecret,
    role.SecurityToken,
    role.Region
  );
};

// 开始下载
export const startDownload = async (vid: string, trackIndex = 0) => {
  RNAliMediaDownloader.startWithVid(vid, trackIndex);
};

// 暂停下载
export const pauseDownload = (vid: string, trackIndex = 0) => {
  RNAliMediaDownloader.stopWithVid(vid, trackIndex);
};

// 删除文件
export const deleteDownload = async (
  saveDir: string,
  vid: string,
  format: string,
  index: number
) => {
  const influenceRows = await RNAliMediaDownloader.deleteFile(
    saveDir,
    vid,
    format,
    index
  );
  return new Promise((resolve) => {
    resolve({ res: influenceRows });
  });
};

// 设置分辨率
export const selectTrack = (vid: string, trackIndex = 0) => {
  RNAliMediaDownloader.selectTrack(trackIndex, vid);
};

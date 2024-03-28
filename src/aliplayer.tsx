/**
 * @brief this lib based on react-native-aliyunplayer
 * @description the installation u can check this url https://github.com/LewinJun/react-native-aliyunplayer
 */
//  just ignore the 'React' refers to a UMD global, but the current file is a module
import React, { useEffect } from 'react';
import type { FC } from 'react';
import { forwardRef, useImperativeHandle, useRef } from 'react';
import type { IAliPlayerProps } from './const';
import {
  findNodeHandle,
  requireNativeComponent,
  UIManager,
} from 'react-native';

const Aliplayer = requireNativeComponent('RNAliplayer');

const Components: FC<IAliPlayerProps> = forwardRef((props, ref) => {
  let playerRef = useRef(null);

  useEffect(() => {
    return () => {
      pausePlay();
      destroyPlay();
    };
  }, []);
  const _dispatchCommand = (commandName: string, params?: Array<any>) => {
    UIManager.dispatchViewManagerCommand(
      _findNode(),
      _getCommandId('RNAliplayer', commandName),
      params
    );
  };

  const _getCommandId = (moduleName: string, nativeMethodName: string) => {
    let commandId =
      UIManager.getViewManagerConfig(moduleName).Commands[nativeMethodName];
    return commandId ?? 0;
  };
  const _findNode = () => {
    return findNodeHandle(playerRef.current);
  };
  /************************************************public method start********************************************************/
  // 开始播放。
  const startPlay = () => {
    _dispatchCommand('startPlay');
  };

  // 暂停播放
  const pausePlay = () => {
    _dispatchCommand('pausePlay');
  };

  // 停止播放
  const stopPlay = () => {
    _dispatchCommand('stopPlay');
  };

  // 重载播放
  const reloadPlay = () => {
    _dispatchCommand('reloadPlay');
  };

  // 重新播放
  const restartPlay = () => {
    _dispatchCommand('restartPlay');
  };

  // 释放。释放后播放器将不可再被使用
  const destroyPlay = () => {
    _dispatchCommand('destroyPlay');
  };

  // 跳转到指定位置,传入单位为秒
  const seekTo = (position = 0) => {
    _dispatchCommand('seekTo', [position]);
  };

  const playVidSts = (
    vid: string,
    accessKeyId: string,
    accessKeySecret: string,
    securityToken: string,
    region: string
  ) => {
    if (vid) {
      _dispatchCommand('playVidSts', [
        vid,
        accessKeyId,
        accessKeySecret,
        securityToken,
        region,
      ]);
    }
  };

  const playLocalPath = (path: string) => {
    if (path) {
      _dispatchCommand('playLocalPath', [path]);
    }
  };

  /************************************************public method end********************************************************/

  useImperativeHandle(ref, () => ({
    startPlay,
    pausePlay,
    stopPlay,
    reloadPlay,
    restartPlay,
    destroyPlay,
    seekTo,
    playVidSts,
    playLocalPath,
  }));
  // @ts-ignore
  return <Aliplayer {...props} ref={playerRef} />;
});

export default Components;

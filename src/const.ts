import type { ViewProps } from 'react-native';

export enum EScaleMode {
  SCALEASPECTFIT = 0,
  SCALEASPECTFILL = 1,
  SCALETOFILL = 2,
}

export interface IAliPlayerProps extends ViewProps {
  ref: any;
  /**
   * 播放路径，此处默认URL播放方式
   */
  source: string;

  /**
   * 是否自动播放
   */
  setAutoPlay?: boolean;

  /**
   * 是否循环播放
   */
  setLoop?: boolean;

  /**
   * 是否静音
   */
  setMute?: boolean;

  /**
   * 是否开启硬件解码
   */
  enableHardwareDecoder?: boolean;

  /**
   * 设置播放器音量,范围0~1.
   */
  setVolume?: number;

  /**
   * 播放速率，0.5-2.0之间，1为正常播放
   */
  setSpeed?: number;

  /**
   * 设置请求referer
   */
  setReferer?: string;

  /**
   * 设置UserAgent
   */
  setUserAgent?: string;

  /**
   * 0:无镜像;1:横向;2:竖向
   */
  setMirrorMode?: number;

  /**
   * 设置旋转 0:0度;1:90度;2:180度;3:270度;
   */
  setRotateMode?: number;

  /**
   * 设置画面缩放模式 0:宽高比适应;1:宽高比填充;2:拉伸填充;
   */
  setScaleMode?: EScaleMode;

  /**
   * 配置自定义header
   */
  configHeader?: Array<any>;

  /**
   * 切换清晰度  选择清晰度的index，-1代表自适应码率
   */
  selectBitrateIndex?: number;

  /**
   * 播放完成回调
   * @param e {code}
   * @returns void
   */
  onAliCompletion?: (
    e: AliPlayerFuncParams<{ code: 'onAliCompletion' }>
  ) => void;

  /**
   *  播放异常回调事件
   */
  onAliError?: (
    e: AliPlayerFuncParams<{ code: string; message: string }>
  ) => void;

  /**
   * 开始缓冲回调事件
   */
  onAliLoadingBegin?: (
    e: AliPlayerFuncParams<{
      code: 'onAliLoadingBegin';
      duration: number;
      width: number;
      height: number;
    }>
  ) => void;

  /**
   * 缓冲进度 回调
   */
  onAliLoadingProgress?: (e: AliPlayerFuncParams<{ percent: number }>) => void;
  /**
   * 缓冲结束事件回调
   */
  onAliLoadingEnd?: (
    e: AliPlayerFuncParams<{
      code: 'onAliLoadingEnd';
      duration: number;
      width: number;
      height: number;
    }>
  ) => void;

  /**
   * 准备播放事件回调
   */
  onAliPrepared?: (
    e: AliPlayerFuncParams<{ duration: number; width: number; height: number }>
  ) => void;

  /**
   * 首帧渲染显示事件回调
   */
  onAliRenderingStart?: (
    e: AliPlayerFuncParams<{
      code: 'onRenderingStart';
      duration: number;
      width: number;
      height: number;
    }>
  ) => void;
  /**
   * 进度拖动结束事件回调
   */
  onAliSeekComplete?: (
    e: AliPlayerFuncParams<{ code: 'onAliSeekComplete' }>
  ) => void;
  /**
   * 播放进度位置更新回调
   */
  onAliCurrentPositionUpdate?: (
    e: AliPlayerFuncParams<{ position: number }>
  ) => void;

  /**
   * 缓冲进度事件回调
   */
  onAliBufferedPositionUpdate?: (
    e: AliPlayerFuncParams<{ position: number }>
  ) => void;

  /**
   * 自动播放开始事件 回调
   */
  onAliAutoPlayStart?: (
    e: AliPlayerFuncParams<{
      code: 'onAliAutoPlayStart';
      duration: number;
      width: number;
      height: number;
    }>
  ) => void;

  /**
   * 循环播放事件回调
   */
  onAliLoopingStart?: (
    e: AliPlayerFuncParams<{ code: 'onAliLoopingStart' }>
  ) => void;
  /**
   * 切换清晰度事件回调
   */
  onAliBitrateChange?: (
    e: AliPlayerFuncParams<{ index: number; width: number; height: number }>
  ) => void;

  /**
   * 获取清晰度事件回调
   */
  onAliBitrateReady?: (
    e: AliPlayerFuncParams<{
      index: number;
      width: number;
      height: number;
      bitrate: number;
    }>
  ) => void;
}

export interface AliPlayerFuncParams<T> {
  nativeEvent: T;
}

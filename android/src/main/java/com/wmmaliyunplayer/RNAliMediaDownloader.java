package com.wmmaliyunplayer;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.downloader.AliDownloaderFactory;
import com.aliyun.downloader.AliMediaDownloader;
import com.aliyun.downloader.DownloaderConfig;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.nativeclass.MediaInfo;
import com.aliyun.player.nativeclass.TrackInfo;
import com.aliyun.player.source.VidSts;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 第二版，简易版
 * */
public class RNAliMediaDownloader extends ReactContextBaseJavaModule {

    private Context mContext;

    /**
     * AliyunDownloadMediaInfo和AliMediaDownloader 一一 对应
     */
    private LinkedHashMap<AliyunDownloadMediaInfo, AliMediaDownloader> downloadInfos = new LinkedHashMap<>();

    private String downloadDir;
    private DownloaderConfig config;

    @NonNull
    @Override
    public String getName() {
        return "RNAliMediaDownloader";
    }

    public RNAliMediaDownloader(@NonNull ReactApplicationContext reactContext){
        super(reactContext);
        mContext = reactContext;
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("onPrepared", DownloadEvents.downloaderOnPrepared.toString());
        constants.put("onDownloadingProgress", DownloadEvents.downloaderOnDownloadingProgress.toString());
        constants.put("onError", DownloadEvents.downloaderOnError.toString());
        constants.put("onCompletion", DownloadEvents.downloaderOnCompletion.toString());
        constants.put("onProcessingProgress", DownloadEvents.downloaderOnProcessingProgress.toString());
        return constants;
    }

    /**
     * 准备下载
     * @param vid 视频播放的vid标识
     * @param accessKeyId 用户sts的accessKey ID
     * @param accessKeySecret 用户sts的accessKey secret
     * @param securityToken 用户sts的token信息
     * @param region 用户sts的region信息
     * */
    @ReactMethod
    public void prepareWithVid(final String vid, final String accessKeyId, final String accessKeySecret, final String securityToken, final String region){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        final VidSts vidSts = getVidSts(vid, accessKeyId, accessKeySecret, securityToken, region);
        final AliMediaDownloader jniDownloader = AliDownloaderFactory.create(mContext);
        jniDownloader.setOnPreparedListener(new AliMediaDownloader.OnPreparedListener() {
            @Override
            public void onPrepared(MediaInfo mediaInfo) {
                final WritableMap event = Arguments.createMap();
                event.putString("vid",mediaInfo.getVideoId());
                WritableArray array = Arguments.createArray();
                List<TrackInfo> trackInfos = mediaInfo.getTrackInfos();
                if (trackInfos != null){
                    for (TrackInfo trackInfo : trackInfos) {
                        TrackInfo.Type type = trackInfo.getType();
                        if (type == TrackInfo.Type.TYPE_VOD) {
                            WritableMap map = Arguments.createMap();
                            map.putInt("trackIndex",trackInfo.getIndex());
                            map.putString("trackDefinition",trackInfo.getVodDefinition());
                            map.putString("vodFormat",trackInfo.getVodFormat());
                            map.putInt("vodFileSize", (int) trackInfo.getVodFileSize());
                            array.pushMap(map);

                            final AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo();
                            downloadMediaInfo.setmVid(mediaInfo.getVideoId());
                            downloadMediaInfo.setTrackIndex(trackInfo.getIndex());
                            downloadMediaInfo.setVidSts(vidSts);
                            AliMediaDownloader aliMediaDownloader = downloadInfos.get(downloadMediaInfo);
                            if (aliMediaDownloader == null) {
                                aliMediaDownloader = AliDownloaderFactory.create(mContext);
                            }
                            aliMediaDownloader.updateSource(vidSts);
                            if (!TextUtils.isEmpty(downloadDir)){
                                aliMediaDownloader.setSaveDir(downloadDir);
                            }
                            downloadInfos.put(downloadMediaInfo, aliMediaDownloader);
                        }
                    }
                }
                event.putArray("tracks",array);
                sendEventToRn(DownloadEvents.downloaderOnPrepared.toString(),event);
            }
        });

        AliyunDownloadMediaInfo mediaInfo = new AliyunDownloadMediaInfo();
        mediaInfo.setmVid(vid);
        mediaInfo.setVidSts(vidSts);
        setErrorListener(jniDownloader,mediaInfo);
        if (config != null){
            jniDownloader.setDownloaderConfig(config);
        }
        jniDownloader.prepare(vidSts);

    }

    @ReactMethod
    public void startWithVid(String vid, int trackIndex){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            jniDownloader = AliDownloaderFactory.create(mContext);
            downloadInfos.put(downloadMediaInfo,jniDownloader);
        }
        jniDownloader.start();
    }

    @ReactMethod
    public void stopWithVid(String vid, int trackIndex){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            return;
        }
        jniDownloader.stop();
    }

    @ReactMethod
    public void setSaveDirectory(String dir, String vid, int trackIndex){
        if (TextUtils.isEmpty(dir) || TextUtils.isEmpty(vid)){
            return;
        }
        this.downloadDir = dir;
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            jniDownloader = AliDownloaderFactory.create(mContext);
            jniDownloader.setSaveDir(dir);
            downloadInfos.put(downloadMediaInfo,jniDownloader);
        }else {
            jniDownloader.setSaveDir(dir);
        }

    }

    /**
     * 设置下载的trackIndex
     * @param trackIndex 从prepare回调中可以获取所有index
     * */
    @ReactMethod
    public void selectTrack(int trackIndex, String vid){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            jniDownloader = AliDownloaderFactory.create(mContext);
            downloadInfos.put(downloadMediaInfo,jniDownloader);
        }
        jniDownloader.selectItem(trackIndex);
        setListener(downloadMediaInfo, jniDownloader);
    }

    /**
     * 释放资源
     * */
    @ReactMethod
    public void destroyWithVid(String vid, int trackIndex){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        AliyunDownloadMediaInfo info = new AliyunDownloadMediaInfo(vid,trackIndex);
        if(downloadInfos != null && downloadInfos.containsKey(info)){
            AliMediaDownloader aliMediaDownloader = downloadInfos.get(info);
            if(aliMediaDownloader != null){
                aliMediaDownloader.release();
            }
            downloadInfos.remove(info);
        }
    }

    @ReactMethod
    public void updateWithVid(String vid, int trackIndex, String accessKeyId, String accessKeySecret, String securityToken, String region){
        VidSts vidSts = getVidSts(vid, accessKeyId, accessKeySecret, securityToken, region);
        AliyunDownloadMediaInfo info = new AliyunDownloadMediaInfo(vid,trackIndex);
        info.setVidSts(vidSts);
        AliMediaDownloader jniDownloader = downloadInfos.get(info);
        if (jniDownloader == null) {
            jniDownloader = AliDownloaderFactory.create(mContext);
            downloadInfos.put(info,jniDownloader);
        }
        jniDownloader.updateSource(vidSts);
    }

    /**
     * 设置下载配置
     * @param timeoutMs 最大超时时间 默认15000毫秒
     * @param connnectTimoutMs 最大连接超时时间 默认5000毫秒
     * @param referer 请求referer
     * @param userAgent 用户代理
     * @param httpProxy http代理
     * */
    @ReactMethod
    public void setConfig(int timeoutMs, int connnectTimoutMs, String referer, String userAgent, String httpProxy, String vid, int trackIndex){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        config = new DownloaderConfig();
        //连接超时时间
        config.mConnectTimeoutS = connnectTimoutMs > 0? connnectTimoutMs/1000 : 15;
        //网络请求超时时间
        config.mNetworkTimeoutMs = timeoutMs > 0? timeoutMs : 5000;
        if (!TextUtils.isEmpty(referer)){
            config.mReferrer = referer;
        }
        if (!TextUtils.isEmpty(userAgent)){
            config.mUserAgent = userAgent;
        }
        if (!TextUtils.isEmpty(httpProxy)){
            config.mHttpProxy = httpProxy;
        }
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            jniDownloader = AliDownloaderFactory.create(mContext);
            jniDownloader.setDownloaderConfig(config);
            downloadInfos.put(downloadMediaInfo,jniDownloader);
        }else {
            jniDownloader.setDownloaderConfig(config);
        }
    }

    /**
     * 删除下载
     * @param saveDir 文件保存路径
     * @param vid 视频播放的vid标识
     * @param format 视频格式
     * @param index 分辨率下标
     * */
    @ReactMethod
    public void deleteFile(String saveDir, String vid, String format, int index, Callback callback){
        if (TextUtils.isEmpty(vid) || TextUtils.isEmpty(saveDir)){
            return;
        }
        int ret = AliDownloaderFactory.deleteFile(saveDir, vid, format, index);
        callback.invoke(ret);
    }


    /**
     * 获取下载之后的文件路径
     * */
    @ReactMethod
    public void downloadedFilePathWithVid(String vid, int trackIndex, Callback callback){
        if (TextUtils.isEmpty(vid)){
            return;
        }
        AliyunDownloadMediaInfo downloadMediaInfo = new AliyunDownloadMediaInfo(vid,trackIndex);
        AliMediaDownloader jniDownloader = downloadInfos.get(downloadMediaInfo);
        if (jniDownloader == null) {
            return;
        }
        String filePath = jniDownloader.getFilePath();
        callback.invoke(filePath);
    }

    /**
     * 构造VidSts实体
     * @param vid   videoId
     */
    private VidSts getVidSts(String vid, String accessKeyId, String accessKeySecret, String securityToken, String region){
        VidSts vidSts = new VidSts();
        vidSts.setVid(vid);
        vidSts.setRegion(region);
        vidSts.setAccessKeyId(accessKeyId);
        vidSts.setSecurityToken(securityToken);
        vidSts.setAccessKeySecret(accessKeySecret);
        return vidSts;
    }

    /**
     * 原生向rn发送的事件定义
     * */
    private enum DownloadEvents {
        //下载准备完成事件回调
        downloaderOnPrepared("downloaderOnPrepared"),
        //错误代理回调
        downloaderOnError("downloaderOnError"),
        //下载进度回调
        downloaderOnDownloadingProgress("downloaderOnDownloadingProgress"),
        //下载文件的处理进度回调
        downloaderOnProcessingProgress("downloaderOnProcessingProgress"),
        //下载完成回调
        downloaderOnCompletion("downloaderOnCompletion");

        private final String mName;

        DownloadEvents(final String name) {
            mName = name;
        }

        @Override
        public String toString() {
            return mName;
        }
    }

    /**
     * 设置监听
     */
    private void setListener(@NonNull final AliyunDownloadMediaInfo downloadMediaInfo, @Nullable final AliMediaDownloader jniDownloader) {
        if (jniDownloader == null){
            return;
        }
        jniDownloader.setOnProgressListener(new AliMediaDownloader.OnProgressListener() {

            @Override
            public void onDownloadingProgress(int percent) {
                if (TextUtils.isEmpty(downloadMediaInfo.getmVid())){
                    return;
                }
                WritableMap event = Arguments.createMap();
                event.putString("vid",downloadMediaInfo.getmVid());
                event.putInt("trackIndex",downloadMediaInfo.getTrackIndex());
                event.putInt("percent",percent);
                sendEventToRn(DownloadEvents.downloaderOnDownloadingProgress.toString(),event);
            }

            @Override
            public void onProcessingProgress(int percent) {
                if (TextUtils.isEmpty(downloadMediaInfo.getmVid())){
                    return;
                }
                WritableMap event = Arguments.createMap();
                event.putString("vid",downloadMediaInfo.getmVid());
                event.putInt("trackIndex",downloadMediaInfo.getTrackIndex());
                event.putInt("percent",percent);
                sendEventToRn(DownloadEvents.downloaderOnProcessingProgress.toString(),event);
            }
        });

        jniDownloader.setOnCompletionListener(new AliMediaDownloader.OnCompletionListener() {
            @Override
            public void onCompletion() {
                if (TextUtils.isEmpty(downloadMediaInfo.getmVid())){
                    return;
                }
                WritableMap event = Arguments.createMap();
                event.putString("vid",downloadMediaInfo.getmVid());
                event.putInt("trackIndex",downloadMediaInfo.getTrackIndex());
                event.putString("filePath",jniDownloader.getFilePath());
                sendEventToRn(DownloadEvents.downloaderOnCompletion.toString(),event);
            }
        });

        setErrorListener(jniDownloader,downloadMediaInfo);
    }
    /**
     * 原生向rn发送消息
     * @param eventName 事件名称
     * @param data 数据
     * */
    private void sendEventToRn(final String eventName, final WritableMap data) {
        ThreadUtils.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName,data);
            }
        });
    }

    /**
     * 设置错误监听
     * @param jniDownloader             下载类
     * @param aliyunDownloadMediaInfo   javaBean
     */
    private void setErrorListener(@Nullable final AliMediaDownloader jniDownloader, @NonNull final AliyunDownloadMediaInfo aliyunDownloadMediaInfo) {
        if(jniDownloader == null){
            return ;
        }
        jniDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                if (TextUtils.isEmpty(aliyunDownloadMediaInfo.getmVid())){
                    return;
                }
                WritableMap event = Arguments.createMap();
                event.putString("vid",aliyunDownloadMediaInfo.getmVid());
                event.putInt("trackIndex",aliyunDownloadMediaInfo.getTrackIndex());
                event.putString("message",errorInfo.getMsg());
                event.putInt("code",errorInfo.getCode().getValue());
                sendEventToRn(DownloadEvents.downloaderOnError.toString(),event);
            }
        });
    }

}

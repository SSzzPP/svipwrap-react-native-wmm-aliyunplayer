package com.wmmaliyunplayer;

import android.text.TextUtils;

import com.aliyun.player.source.VidSts;

import java.util.Arrays;

public class AliyunDownloadMediaInfo {
    private String mVid;
    private int trackIndex = -1;
    private VidSts vidSts;

    public AliyunDownloadMediaInfo(){}

    public AliyunDownloadMediaInfo(String mVid, int trackIndex){
        this.mVid = mVid;
        this.trackIndex = trackIndex;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass() || TextUtils.isEmpty(this.mVid) || this.trackIndex == -1) {
            return false;
        }
        AliyunDownloadMediaInfo that = (AliyunDownloadMediaInfo) o;
        return this.mVid.equals(that.mVid) && this.trackIndex == that.trackIndex;
    }

    @Override
    public int hashCode() {
        Object[] hashObject = new Object[2];
        hashObject[0] = mVid;
        hashObject[1] = trackIndex;
        return Arrays.hashCode(hashObject);
    }

    public VidSts getVidSts(){
        return vidSts;
    }

    public void setVidSts(VidSts vidSts) {
        this.vidSts = vidSts;
    }

    public String getmVid(){
        return mVid;
    }

    public void setmVid(String mVid){
        this.mVid = mVid;
    }

    public void setTrackIndex(int trackIndex){
        this.trackIndex = trackIndex;
    }

    public int getTrackIndex(){
        return trackIndex;
    }

}

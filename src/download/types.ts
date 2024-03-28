export interface IProgress {
  percent: number;
  trackIndex: number;
  vid: string;
}
export interface ICompletion {
  filePath: string;
  trackIndex: number;
  vid: string;
}
export interface IAssumeRole {
  AccessKeyId: string;
  AccessKeySecret: string;
  SecurityToken: string;
  Region: string;
}

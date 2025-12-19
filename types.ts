export interface Song {
  id: string;
  title: string;
  artist: string;
  url: string;
  file: File;
  duration?: number;
}

export interface PlayerState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  isMuted: boolean;
  shuffle: boolean;
  repeat: 'none' | 'all' | 'one';
}

export type RepeatMode = 'none' | 'all' | 'one';

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { PlayerState, RepeatMode, Song } from '../types';

interface UsePlayerReturn {
  audioRef: React.RefObject<HTMLAudioElement>;
  state: PlayerState;
  currentSong: Song | null;
  togglePlay: () => void;
  playSong: (song: Song) => void;
  playNext: () => void;
  playPrev: () => void;
  seek: (time: number) => void;
  setVolume: (volume: number) => void;
  toggleMute: () => void;
  toggleShuffle: () => void;
  toggleRepeat: () => void;
  loadSongs: (files: FileList) => void;
  playlist: Song[];
  currentSongIndex: number;
}

export const usePlayer = (): UsePlayerReturn => {
  const audioRef = useRef<HTMLAudioElement>(null);
  
  // Web Audio API Refs
  const audioContextRef = useRef<AudioContext | null>(null);
  const sourceNodeRef = useRef<MediaElementAudioSourceNode | null>(null);
  const compressorRef = useRef<DynamicsCompressorNode | null>(null);

  const [playlist, setPlaylist] = useState<Song[]>([]);
  const [currentSongIndex, setCurrentSongIndex] = useState<number>(-1);
  const [state, setState] = useState<PlayerState>({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    volume: 1,
    isMuted: false,
    shuffle: false,
    repeat: 'none',
  });

  const currentSong = currentSongIndex >= 0 ? playlist[currentSongIndex] : null;

  // Initialize Web Audio API on first interaction to improve quality
  const initAudioContext = useCallback(() => {
    if (!audioRef.current || audioContextRef.current) return;

    // Create Audio Context with playback latency hint (better quality than interactive)
    const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
    const ctx = new AudioContextClass({
      latencyHint: 'playback', 
    });

    // Create Source from HTML Audio Element
    const source = ctx.createMediaElementSource(audioRef.current);

    // Create a Dynamics Compressor Node
    // This reduces the dynamic range, preventing clipping (distortion/noise)
    // and makes the audio sound fuller, similar to VLC/Native players.
    const compressor = ctx.createDynamicsCompressor();
    compressor.threshold.value = -24;
    compressor.knee.value = 30;
    compressor.ratio.value = 12;
    compressor.attack.value = 0.003;
    compressor.release.value = 0.25;

    // Connect the chain: Source -> Compressor -> Destination (Speakers)
    source.connect(compressor);
    compressor.connect(ctx.destination);

    audioContextRef.current = ctx;
    sourceNodeRef.current = source;
    compressorRef.current = compressor;
  }, []);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateTime = () => setState(prev => ({ ...prev, currentTime: audio.currentTime }));
    const updateDuration = () => setState(prev => ({ ...prev, duration: audio.duration }));
    const onEnded = () => handleEnded();

    audio.addEventListener('timeupdate', updateTime);
    audio.addEventListener('loadedmetadata', updateDuration);
    audio.addEventListener('ended', onEnded);

    return () => {
      audio.removeEventListener('timeupdate', updateTime);
      audio.removeEventListener('loadedmetadata', updateDuration);
      audio.removeEventListener('ended', onEnded);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentSongIndex, playlist, state.repeat, state.shuffle]);

  const handleEnded = () => {
    if (state.repeat === 'one') {
      audioRef.current?.play();
    } else {
      playNext();
    }
  };

  const playSong = useCallback((song: Song) => {
    // Ensure Audio Context is initialized
    initAudioContext();
    if (audioContextRef.current?.state === 'suspended') {
      audioContextRef.current.resume();
    }

    const index = playlist.findIndex(s => s.id === song.id);
    if (index !== -1) {
      setCurrentSongIndex(index);
      setState(prev => ({ ...prev, isPlaying: true }));
      setTimeout(() => audioRef.current?.play(), 0);
    }
  }, [playlist, initAudioContext]);

  const togglePlay = useCallback(() => {
    initAudioContext();
    if (audioContextRef.current?.state === 'suspended') {
      audioContextRef.current.resume();
    }

    if (state.isPlaying) {
      audioRef.current?.pause();
    } else {
      audioRef.current?.play();
    }
    setState(prev => ({ ...prev, isPlaying: !prev.isPlaying }));
  }, [state.isPlaying, initAudioContext]);

  const playNext = useCallback(() => {
    if (playlist.length === 0) return;
    initAudioContext();

    let nextIndex = currentSongIndex + 1;
    
    if (state.shuffle) {
        nextIndex = Math.floor(Math.random() * playlist.length);
    } else if (nextIndex >= playlist.length) {
        if (state.repeat === 'all') nextIndex = 0;
        else {
            setState(prev => ({...prev, isPlaying: false}));
            return;
        }
    }
    
    setCurrentSongIndex(nextIndex);
    setState(prev => ({ ...prev, isPlaying: true }));
    setTimeout(() => audioRef.current?.play(), 0);
  }, [currentSongIndex, playlist.length, state.shuffle, state.repeat, initAudioContext]);

  const playPrev = useCallback(() => {
    if (playlist.length === 0) return;
    initAudioContext();

    if (audioRef.current && audioRef.current.currentTime > 3) {
      audioRef.current.currentTime = 0;
      return;
    }

    let prevIndex = currentSongIndex - 1;
    if (prevIndex < 0) {
        prevIndex = playlist.length - 1;
    }
    setCurrentSongIndex(prevIndex);
    setState(prev => ({ ...prev, isPlaying: true }));
    setTimeout(() => audioRef.current?.play(), 0);
  }, [currentSongIndex, playlist.length, initAudioContext]);

  const seek = useCallback((time: number) => {
    if (audioRef.current) {
      audioRef.current.currentTime = time;
      setState(prev => ({ ...prev, currentTime: time }));
    }
  }, []);

  const setVolume = useCallback((volume: number) => {
    if (audioRef.current) {
      audioRef.current.volume = volume;
      setState(prev => ({ ...prev, volume }));
    }
  }, []);

  const toggleMute = useCallback(() => {
    if (audioRef.current) {
      const newMuted = !state.isMuted;
      audioRef.current.muted = newMuted;
      setState(prev => ({ ...prev, isMuted: newMuted }));
    }
  }, [state.isMuted]);

  const toggleShuffle = useCallback(() => {
    setState(prev => ({ ...prev, shuffle: !prev.shuffle }));
  }, []);

  const toggleRepeat = useCallback(() => {
    setState(prev => {
      const modes: RepeatMode[] = ['none', 'all', 'one'];
      const nextIndex = (modes.indexOf(prev.repeat) + 1) % modes.length;
      return { ...prev, repeat: modes[nextIndex] };
    });
  }, []);

  const loadSongs = useCallback((files: FileList) => {
    const newSongs: Song[] = Array.from(files)
      .filter(file => file.type.startsWith('audio/'))
      .map(file => ({
        id: crypto.randomUUID(),
        title: file.name.replace(/\.[^/.]+$/, ""),
        artist: 'Unknown Artist',
        file: file,
        url: URL.createObjectURL(file),
      }));

    setPlaylist(prev => [...prev, ...newSongs]);
    if (currentSongIndex === -1 && newSongs.length > 0) {
      setCurrentSongIndex(0); 
    }
  }, [currentSongIndex]);

  return {
    audioRef,
    state,
    currentSong,
    togglePlay,
    playSong,
    playNext,
    playPrev,
    seek,
    setVolume,
    toggleMute,
    toggleShuffle,
    toggleRepeat,
    loadSongs,
    playlist,
    currentSongIndex,
  };
};
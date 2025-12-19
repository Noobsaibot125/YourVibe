import React from 'react';
import { Song } from '../types';

interface SongListProps {
  songs: Song[];
  currentSong: Song | null;
  isPlaying: boolean;
  onSongSelect: (song: Song) => void;
}

const SongList: React.FC<SongListProps> = ({ songs, currentSong, isPlaying, onSongSelect }) => {
  if (songs.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full text-outline p-8 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round" className="mb-4 opacity-50"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
        <p className="text-lg">Your playlist is empty.</p>
        <p className="text-sm mt-2">Add local audio files to start listening.</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col w-full h-full overflow-y-auto pb-32">
        <div className="px-4 py-3 border-b border-surfaceVariant sticky top-0 bg-surface/95 backdrop-blur-sm z-10 flex justify-between items-center">
            <h2 className="text-sm font-semibold tracking-wider text-outline uppercase">Library</h2>
            <span className="text-xs text-outline">{songs.length} Songs</span>
        </div>
      <ul className="divide-y divide-surfaceVariant/30">
        {songs.map((song) => {
          const isActive = currentSong?.id === song.id;
          return (
            <li
              key={song.id}
              onClick={() => onSongSelect(song)}
              className={`group flex items-center justify-between p-4 cursor-pointer transition-colors hover:bg-surfaceVariant/30 ${
                isActive ? 'bg-primaryContainer/10' : ''
              }`}
            >
              <div className="flex items-center gap-4 overflow-hidden">
                <div className={`w-10 h-10 rounded-md flex items-center justify-center shrink-0 ${isActive ? 'bg-primary text-onPrimary' : 'bg-surfaceVariant text-outline'}`}>
                   {isActive && isPlaying ? (
                       <div className="flex gap-1 items-end h-4">
                           <span className="w-1 bg-onPrimary animate-[bounce_1s_infinite] h-2"></span>
                           <span className="w-1 bg-onPrimary animate-[bounce_1.2s_infinite] h-4"></span>
                           <span className="w-1 bg-onPrimary animate-[bounce_0.8s_infinite] h-3"></span>
                       </div>
                   ) : (
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
                   )}
                </div>
                <div className="flex flex-col overflow-hidden">
                  <span className={`truncate font-medium ${isActive ? 'text-primary' : 'text-onSurface'}`}>
                    {song.title}
                  </span>
                  <span className="truncate text-xs text-outline">
                    {song.artist}
                  </span>
                </div>
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
};

export default SongList;

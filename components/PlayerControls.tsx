import React from 'react';
import { PlayerState } from '../types';
import { formatTime } from '../utils/time';

interface PlayerControlsProps {
  state: PlayerState;
  onTogglePlay: () => void;
  onNext: () => void;
  onPrev: () => void;
  onSeek: (time: number) => void;
  onToggleShuffle: () => void;
  onToggleRepeat: () => void;
}

const PlayerControls: React.FC<PlayerControlsProps> = ({
  state,
  onTogglePlay,
  onNext,
  onPrev,
  onSeek,
  onToggleShuffle,
  onToggleRepeat,
}) => {
  return (
    <div className="flex flex-col w-full max-w-2xl mx-auto space-y-4">
      {/* Progress Bar */}
      <div className="flex items-center gap-3 text-xs text-onSurface font-medium">
        <span>{formatTime(state.currentTime)}</span>
        <input
          type="range"
          min="0"
          max={state.duration || 0}
          value={state.currentTime}
          onChange={(e) => onSeek(Number(e.target.value))}
          className="flex-1 h-1 bg-surfaceVariant rounded-lg appearance-none cursor-pointer accent-primary hover:h-2 transition-all"
        />
        <span>{formatTime(state.duration)}</span>
      </div>

      {/* Buttons */}
      <div className="flex items-center justify-center gap-6 sm:gap-10">
        <button
          onClick={onToggleShuffle}
          className={`p-2 rounded-full transition-colors ${state.shuffle ? 'text-primary' : 'text-outline hover:text-onSurface'}`}
          title="Shuffle"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M2 18h1.4c1.3 0 2.5-.6 3.3-1.7l14.2-12.6c.8-1 1.9-1.7 3.1-1.7H22"/><path d="M2 5h1.6c1.2 0 2.4.7 3.2 1.7l1.6 2.1"/><path d="M15.2 15.2l1.6 2.1c.8 1 2 1.7 3.2 1.7H22"/></svg>
        </button>

        <button
          onClick={onPrev}
          className="text-onSurface hover:text-primary transition-colors p-2"
          title="Previous"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="19 20 9 12 19 4 19 20"/><line x1="5" y1="19" x2="5" y2="5"/></svg>
        </button>

        <button
          onClick={onTogglePlay}
          className="bg-primary text-onPrimary rounded-full p-4 hover:bg-opacity-90 transition-transform active:scale-95 shadow-lg shadow-primary/30"
          title={state.isPlaying ? "Pause" : "Play"}
        >
          {state.isPlaying ? (
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="currentColor" stroke="none"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          )}
        </button>

        <button
          onClick={onNext}
          className="text-onSurface hover:text-primary transition-colors p-2"
          title="Next"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="5 4 15 12 5 20 5 4"/><line x1="19" y1="5" x2="19" y2="19"/></svg>
        </button>

        <button
          onClick={onToggleRepeat}
          className={`p-2 rounded-full transition-colors ${state.repeat !== 'none' ? 'text-primary' : 'text-outline hover:text-onSurface'}`}
          title={`Repeat: ${state.repeat}`}
        >
           {state.repeat === 'one' ? (
              <div className="relative">
                 <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m17 2 4 4-4 4"/><path d="M3 11v-1a4 4 0 0 1 4-4h14"/><path d="m7 22-4-4 4-4"/><path d="M21 13v1a4 4 0 0 1-4 4H3"/></svg>
                 <span className="absolute -top-1 -right-1 text-[8px] font-bold bg-primary text-onPrimary rounded-full w-3 h-3 flex items-center justify-center">1</span>
              </div>
           ) : (
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m17 2 4 4-4 4"/><path d="M3 11v-1a4 4 0 0 1 4-4h14"/><path d="m7 22-4-4 4-4"/><path d="M21 13v1a4 4 0 0 1-4 4H3"/></svg>
           )}
        </button>
      </div>
    </div>
  );
};

export default PlayerControls;

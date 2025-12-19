import React, { useRef } from 'react';
import { usePlayer } from './hooks/usePlayer';
import PlayerControls from './components/PlayerControls';
import SongList from './components/SongList';
import VolumeControl from './components/VolumeControl';

const App: React.FC = () => {
  const {
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
  } = usePlayer();

  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      loadSongs(e.target.files);
    }
    // Reset input so same files can be selected again if needed
    if (fileInputRef.current) {
        fileInputRef.current.value = "";
    }
  };

  return (
    <div className="flex flex-col h-screen bg-surface text-onSurface overflow-hidden">
      {/* Hidden Audio Element */}
      <audio
        ref={audioRef}
        src={currentSong?.url}
        crossOrigin="anonymous"
      />

      {/* Header */}
      <header className="flex items-center justify-between px-6 py-4 bg-surfaceVariant/20 backdrop-blur-md border-b border-surfaceVariant/50 z-20">
        <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/20">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
            </div>
            <h1 className="text-xl font-bold tracking-tight text-onSurface">FlutterVibe <span className="text-primary text-sm font-normal">Web</span></h1>
        </div>
        <div className="flex items-center gap-4">
            <input
                type="file"
                ref={fileInputRef}
                onChange={handleFileChange}
                accept="audio/*"
                multiple
                className="hidden"
            />
            <button 
                onClick={() => fileInputRef.current?.click()}
                className="flex items-center gap-2 px-4 py-2 rounded-full bg-primaryContainer text-onPrimaryContainer hover:bg-primary/20 transition-colors text-sm font-medium"
            >
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                Add Songs
            </button>
            <div className="hidden sm:block">
                 <VolumeControl 
                    volume={state.volume} 
                    isMuted={state.isMuted} 
                    onVolumeChange={setVolume}
                    onToggleMute={toggleMute}
                 />
            </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 flex overflow-hidden relative">
          
          {/* Song List (Left/Main) */}
          <div className="flex-1 relative z-10">
              <SongList 
                songs={playlist} 
                currentSong={currentSong} 
                isPlaying={state.isPlaying} 
                onSongSelect={playSong} 
              />
          </div>

          {/* Visualization / Cover Art Placeholder (Hidden on mobile, visible on lg screens) */}
          <div className="hidden lg:flex flex-1 items-center justify-center bg-surfaceVariant/5 border-l border-surfaceVariant/30">
             {currentSong ? (
                 <div className="flex flex-col items-center text-center p-8 animate-in fade-in duration-500">
                    <div className="w-64 h-64 rounded-2xl bg-gradient-to-tr from-surfaceVariant to-surface shadow-2xl flex items-center justify-center mb-8 border border-surfaceVariant/50">
                        <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round" className="text-outline/50"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
                    </div>
                    <h2 className="text-3xl font-bold text-onSurface mb-2 max-w-md truncate">{currentSong.title}</h2>
                    <p className="text-xl text-primary">{currentSong.artist}</p>
                 </div>
             ) : (
                <div className="text-outline text-center">
                    <p className="text-2xl font-light">Select a song to play</p>
                </div>
             )}
          </div>
      </main>

      {/* Persistent Player Footer */}
      <footer className="bg-surfaceVariant/10 backdrop-blur-xl border-t border-surfaceVariant/30 px-4 py-4 md:px-8 z-30">
        <div className="flex flex-col md:flex-row items-center gap-4 md:gap-8 max-w-7xl mx-auto">
            
            {/* Now Playing Info (Mobile/Desktop) */}
            <div className="flex items-center gap-4 w-full md:w-1/4 min-w-0">
                {currentSong ? (
                    <>
                        <div className="w-12 h-12 rounded-lg bg-surfaceVariant flex items-center justify-center shrink-0">
                             <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-outline"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
                        </div>
                        <div className="flex flex-col overflow-hidden">
                            <span className="text-onSurface font-medium truncate">{currentSong.title}</span>
                            <span className="text-xs text-outline truncate">{currentSong.artist}</span>
                        </div>
                    </>
                ) : (
                    <div className="text-outline text-sm italic">No song selected</div>
                )}
            </div>

            {/* Controls */}
            <div className="w-full md:flex-1">
                <PlayerControls
                    state={state}
                    onTogglePlay={togglePlay}
                    onNext={playNext}
                    onPrev={playPrev}
                    onSeek={seek}
                    onToggleShuffle={toggleShuffle}
                    onToggleRepeat={toggleRepeat}
                />
            </div>
            
            {/* Volume (Desktop Right) */}
             <div className="hidden md:flex justify-end w-1/4">
                 {/* Re-using volume control here if wanted, or keeping it in header */}
             </div>
        </div>
      </footer>
    </div>
  );
};

export default App;

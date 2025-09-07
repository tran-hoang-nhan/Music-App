package com.example.musicapp.player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;

import androidx.annotation.Nullable;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;

import com.example.musicapp.model.Song;
import com.example.musicapp.personalization.PersonalizationManager;
import com.example.musicapp.storage.FavoritesManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class MusicPlayerManager {

    public enum RepeatMode {
        OFF, ONE, ALL
    }

    private static MusicPlayerManager instance;
    private ExoPlayer player;
    private OnPlayerStateChangeListener listener;
    private Song currentSong;
    private Context context;
    private SharedPreferences prefs;
    private PersonalizationManager personalizationManager;
    private long trackStartTime = 0;

    private List<Song> playlist = new ArrayList<>();
    private List<Song> originalPlaylist = new ArrayList<>();
    private List<Song> recentlyPlayed = new ArrayList<>();
    private FavoritesManager favoritesManager;
    private int currentIndex = -1;
    private boolean isShuffleEnabled = false;
    private RepeatMode repeatMode = RepeatMode.OFF;
    private Random random = new Random();


    private MusicPlayerManager(Context context) {
        this.context = context.getApplicationContext();
        this.prefs = context.getSharedPreferences("music_player_prefs", Context.MODE_PRIVATE);
        this.personalizationManager = PersonalizationManager.getInstance(context);
        this.favoritesManager = FavoritesManager.getInstance(context);
        
        player = new ExoPlayer.Builder(this.context).build();
        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_ENDED) {
                    handleTrackEnded();
                } else if (state == Player.STATE_READY) {
                    if (currentSong != null) {
                        long duration = player.getDuration();
                        notifyAllListeners("onTrackChanged", currentSong.getName(), currentSong.getArtistName(), currentSong.getImageUrl(), duration);
                    }
                }
            }
            
            @Override
            public void onIsPlayingChanged(boolean isPlaying) {
                if (isPlaying) {
                    notifyAllListeners("onPlay");
                } else {
                    notifyAllListeners("onPause");
                }
            }
        });
        
        loadPlayerState();
    }

    private void handleTrackEnded() {
        switch (repeatMode) {
            case ONE:
                player.seekTo(0);
                player.play();
                // Không gọi callback vì vẫn là bài cũ
                break;
            case ALL:
                playNext();
                break;
            case OFF:
            default:
                if (hasNext()) {
                    playNext();
                } else {
                    notifyAllListeners("onTrackCompleted");
                }
                break;
        }
    }

    private void loadPlayerState() {
        isShuffleEnabled = prefs.getBoolean("shuffle_enabled", false);
        int repeatOrdinal = prefs.getInt("repeat_mode", 0);
        repeatMode = RepeatMode.values()[repeatOrdinal];
    }

    private void savePlayerState() {
        prefs.edit()
            .putBoolean("shuffle_enabled", isShuffleEnabled)
            .putInt("repeat_mode", repeatMode.ordinal())
            .apply();
    }
    @SuppressLint("DefaultLocale")
    public static String formatTime(long ms) {
        int totalSec = (int) (ms / 1000);
        int min = totalSec / 60;
        int sec = totalSec % 60;
        return String.format("%d:%02d", min, sec);
    }


    public static synchronized MusicPlayerManager getInstance(Context context) {
        if (instance == null) instance = new MusicPlayerManager(context);
        return instance;
    }

    private List<OnPlayerStateChangeListener> listeners = new ArrayList<>();
    
    public void setOnPlayerStateChangeListener(@Nullable OnPlayerStateChangeListener listener) {
        this.listener = listener;
        if (currentSong != null && listener != null) {
            long duration = player != null ? player.getDuration() : 0;
            listener.onTrackChanged(currentSong.getName(), currentSong.getArtistName(), currentSong.getImageUrl(), duration);
            if (isPlaying()) listener.onPlay();
        }
    }
    
    public void addPlayerStateChangeListener(OnPlayerStateChangeListener listener) {
        if (listener != null && !listeners.contains(listener)) {
            listeners.add(listener);
        }
    }
    
    public void removePlayerStateChangeListener(OnPlayerStateChangeListener listener) {
        listeners.remove(listener);
    }
    
    private void notifyAllListeners(String method, Object... args) {
        if (listener != null) {
            switch (method) {
                case "onTrackChanged":
                    listener.onTrackChanged((String)args[0], (String)args[1], (String)args[2], (Long)args[3]);
                    break;
                case "onPlay":
                    listener.onPlay();
                    break;
                case "onPause":
                    listener.onPause();
                    break;
                case "onTrackCompleted":
                    listener.onTrackCompleted();
                    break;
            }
        }
        for (OnPlayerStateChangeListener l : listeners) {
            switch (method) {
                case "onTrackChanged":
                    l.onTrackChanged((String)args[0], (String)args[1], (String)args[2], (Long)args[3]);
                    break;
                case "onPlay":
                    l.onPlay();
                    break;
                case "onPause":
                    l.onPause();
                    break;
                case "onTrackCompleted":
                    l.onTrackCompleted();
                    break;
            }
        }
    }

    /** Set playlist mới */
    public void setPlaylist(List<Song> songs, int startIndex) {
        if (songs == null || songs.isEmpty()) return;
        
        originalPlaylist.clear();
        originalPlaylist.addAll(songs);
        
        playlist.clear();
        playlist.addAll(songs);
        
        if (isShuffleEnabled) {
            shufflePlaylist();
        }
        
        currentIndex = Math.max(0, Math.min(startIndex, playlist.size() - 1));
        play(playlist.get(currentIndex));
    }

    private void shufflePlaylist() {
        if (playlist.size() <= 1) return;
        
        Song currentSong = null;
        if (currentIndex >= 0 && currentIndex < playlist.size()) {
            currentSong = playlist.get(currentIndex);
        }
        
        Collections.shuffle(playlist, random);
        
        if (currentSong != null) {
            int newIndex = playlist.indexOf(currentSong);
            if (newIndex != -1) {
                currentIndex = newIndex;
            }
        }
    }

    /** Phát 1 bài */
    public void play(Song song) {
        if (song == null) return;

        // Nếu chưa có playlist thì tạo
        if (playlist.isEmpty()) {
            playlist.add(song);
            originalPlaylist.add(song);
            currentIndex = 0;
        } else {
            int idx = playlist.indexOf(song);
            if (idx == -1) {
                playlist.add(song);
                originalPlaylist.add(song);
                currentIndex = playlist.size() - 1;
            } else {
                currentIndex = idx;
            }
        }

        // Trường hợp bấm lại đúng bài đang phát -> restart
        if (currentSong != null && currentSong.equals(song) && player.isPlaying()) {
            player.seekTo(0);
            player.play();
            notifyAllListeners("onPlay");
            return;
        } else {
            // Track previous song completion if exists
            if (currentSong != null && trackStartTime > 0) {
                long playedDuration = System.currentTimeMillis() - trackStartTime;
                if (playedDuration > 30000) { // Played for more than 30 seconds
                    personalizationManager.recordComplete(currentSong);
                }
            }
            
            currentSong = song;
            trackStartTime = System.currentTimeMillis();
            addToRecentlyPlayed(song);
            
            String audioUrl = song.getAudioUrl();
            if (audioUrl != null && !audioUrl.isEmpty()) {
                player.stop();
                player.setMediaItem(MediaItem.fromUri(Uri.parse(audioUrl)));
                player.prepare();
                player.play();
            } else {
                android.util.Log.e("MusicPlayerManager", "Audio URL is null or empty for song: " + song.getName());
                return;
            }
        }

        // Gọi callback ngay để cập nhật UI
        notifyAllListeners("onTrackChanged", song.getName(), song.getArtistName(), song.getImageUrl(), 0L);
        // onPlay sẽ được gọi tự động bởi onIsPlayingChanged listener
    }

    private void addToRecentlyPlayed(Song song) {
        recentlyPlayed.remove(song);
        recentlyPlayed.add(0, song);
        if (recentlyPlayed.size() > 50) {
            recentlyPlayed.remove(recentlyPlayed.size() - 1);
        }
    }

    /** Phát bài tiếp theo */
    public void playNext() {
        // Track skip if current song played less than 30 seconds
        if (currentSong != null && trackStartTime > 0) {
            long playedDuration = System.currentTimeMillis() - trackStartTime;
            if (playedDuration < 30000) {
                personalizationManager.recordSkip(currentSong);
            }
        }
        
        if (playlist.isEmpty()) return;
        
        if (isShuffleEnabled) {
            playRandomNext();
        } else {
            currentIndex++;
            if (currentIndex >= playlist.size()) {
                if (repeatMode == RepeatMode.ALL) {
                    currentIndex = 0;
                    play(playlist.get(currentIndex));
                } else {
                    currentIndex = playlist.size() - 1;
                    return;
                }
            } else {
                play(playlist.get(currentIndex));
            }
        }
    }

    /** Phát bài trước */
    public void playPrevious() {
        // Track skip if current song played less than 30 seconds
        if (currentSong != null && trackStartTime > 0) {
            long playedDuration = System.currentTimeMillis() - trackStartTime;
            if (playedDuration < 30000) {
                personalizationManager.recordSkip(currentSong);
            }
        }
        
        if (playlist.isEmpty()) return;
        
        if (isShuffleEnabled) {
            playRandomPrevious();
        } else {
            currentIndex--;
            if (currentIndex < 0) {
                if (repeatMode == RepeatMode.ALL) {
                    currentIndex = playlist.size() - 1;
                    play(playlist.get(currentIndex));
                } else {
                    currentIndex = 0;
                    return;
                }
            } else {
                play(playlist.get(currentIndex));
            }
        }
    }

    private void playRandomNext() {
        if (playlist.size() <= 1) return;
        
        int nextIndex;
        do {
            nextIndex = random.nextInt(playlist.size());
        } while (nextIndex == currentIndex && playlist.size() > 1);
        
        currentIndex = nextIndex;
        play(playlist.get(currentIndex));
    }

    private void playRandomPrevious() {
        if (recentlyPlayed.size() > 1) {
            Song previousSong = recentlyPlayed.get(1);
            int index = playlist.indexOf(previousSong);
            if (index != -1) {
                currentIndex = index;
                play(playlist.get(currentIndex));
                return;
            }
        }
        playRandomNext();
    }

    public boolean hasNext() {
        if (isShuffleEnabled || repeatMode == RepeatMode.ALL) return true;
        return currentIndex < playlist.size() - 1;
    }

    public boolean hasPrevious() {
        if (isShuffleEnabled || repeatMode == RepeatMode.ALL) return true;
        return currentIndex > 0;
    }

    public void pause() {
        if (player != null && player.isPlaying()) {
            player.pause();
            // onPause sẽ được gọi tự động bởi onIsPlayingChanged listener
        }
    }

    public void resume() {
        if (player != null && !player.isPlaying()) {
            player.play();
            // onPlay sẽ được gọi tự động bởi onIsPlayingChanged listener
        }
    }

    public boolean isPlaying() {
        return player != null && player.isPlaying();
    }

    public Song getCurrentSong() {
        return currentSong;
    }

    public ExoPlayer getPlayer() {
        return player;
    }

    // Shuffle và Repeat controls
    public void toggleShuffle() {
        isShuffleEnabled = !isShuffleEnabled;
        
        if (isShuffleEnabled) {
            shufflePlaylist();
        } else {
            // Restore original order
            Song currentSong = getCurrentSong();
            playlist.clear();
            playlist.addAll(originalPlaylist);
            if (currentSong != null) {
                currentIndex = playlist.indexOf(currentSong);
            }
        }
        
        savePlayerState();
        if (listener != null) listener.onShuffleChanged(isShuffleEnabled);
    }

    public void toggleRepeat() {
        switch (repeatMode) {
            case OFF:
                repeatMode = RepeatMode.ALL;
                break;
            case ALL:
                repeatMode = RepeatMode.ONE;
                break;
            case ONE:
                repeatMode = RepeatMode.OFF;
                break;
        }
        
        savePlayerState();
        if (listener != null) listener.onRepeatModeChanged(repeatMode);
    }

    // Favorites management
    public void toggleFavorite(Song song) {
        favoritesManager.toggleFavorite(song);
        if (listener != null) listener.onFavoriteChanged(song, isFavorite(song));
    }

    public boolean isFavorite(Song song) {
        return favoritesManager.isFavorite(song);
    }

    // Getters
    public boolean isShuffleEnabled() { return isShuffleEnabled; }
    public RepeatMode getRepeatMode() { return repeatMode; }
    public List<Song> getRecentlyPlayed() { return new ArrayList<>(recentlyPlayed); }
    public List<Song> getFavorites() { return favoritesManager.getFavorites(); }
    public List<Song> getCurrentPlaylist() { return new ArrayList<>(playlist); }

    public void release() {
        savePlayerState();
        if (player != null) {
            player.release();
            player = null;
        }
        instance = null;
        playlist.clear();
        originalPlaylist.clear();
        currentIndex = -1;
    }

    public interface OnPlayerStateChangeListener {
        void onTrackChanged(String title, String artist, String coverUrl, long durationMs);
        void onPlay();
        void onPause();
        void onTrackCompleted();
        default void onShuffleChanged(boolean enabled) {}
        default void onRepeatModeChanged(RepeatMode mode) {}
        default void onFavoriteChanged(Song song, boolean isFavorite) {}
    }
}

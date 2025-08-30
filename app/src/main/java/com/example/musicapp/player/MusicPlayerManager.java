package com.example.musicapp.player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.Nullable;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;

import com.example.musicapp.model.Song;

import java.util.ArrayList;
import java.util.List;

public class MusicPlayerManager {

    private static MusicPlayerManager instance;
    private ExoPlayer player;
    private OnPlayerStateChangeListener listener;
    private Song currentSong;

    private List<Song> playlist = new ArrayList<>();
    private int currentIndex = -1;


    private MusicPlayerManager(Context context) {
        Context context1 = context.getApplicationContext();
        player = new ExoPlayer.Builder(context1).build();
        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_ENDED) {
                    playNext();
                    if (listener != null) listener.onTrackCompleted();
                } else if (state == Player.STATE_READY) {
                    if (currentSong != null && listener != null) {
                        long duration = player.getDuration();
                        listener.onTrackChanged(currentSong.getName(), currentSong.getArtistName(), currentSong.getImageUrl(), duration);
                    }
                }
            }
        });

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

    public void setOnPlayerStateChangeListener(@Nullable OnPlayerStateChangeListener listener) {
        this.listener = listener;
        if (currentSong != null && listener != null) {
            long duration = player != null ? player.getDuration() : 0;
            listener.onTrackChanged(currentSong.getName(), currentSong.getArtistName(), currentSong.getImageUrl(), duration);
            if (isPlaying()) listener.onPlay();
        }
    }

    /** Set playlist mới */
    public void setPlaylist(List<Song> songs, int startIndex) {
        if (songs == null || songs.isEmpty()) return;
        playlist.clear();
        playlist.addAll(songs);
        currentIndex = Math.max(0, Math.min(startIndex, songs.size() - 1));
        play(playlist.get(currentIndex));
    }

    /** Phát 1 bài (reset playlist = chỉ bài đó) */
    public void play(Song song) {
        if (song == null) return;

        // Nếu chưa có playlist thì tạo
        if (playlist.isEmpty()) {
            playlist.add(song);
            currentIndex = 0;
        } else {
            int idx = playlist.indexOf(song);
            if (idx == -1) {
                // nếu bài chưa có trong playlist -> thêm vào
                playlist.add(song);
                currentIndex = playlist.size() - 1;
            } else {
                currentIndex = idx;
            }
        }

        // Trường hợp bấm lại đúng bài đang phát -> restart
        if (currentSong != null && currentSong.equals(song)) {
            player.seekTo(0);
            player.play();
        } else {
            currentSong = song;
            String audioUrl = song.getAudioUrl();
            if (audioUrl != null && !audioUrl.isEmpty()) {
                player.setMediaItem(MediaItem.fromUri(Uri.parse(audioUrl)));
                player.prepare();
                player.play();
            } else {
                android.util.Log.e("MusicPlayerManager", "Audio URL is null or empty for song: " + song.getName());
                return;
            }
        }

        if (listener != null) {
            long duration = player.getDuration(); // lấy duration thật
            listener.onTrackChanged(song.getName(), song.getArtistName(), song.getImageUrl(), duration);
            listener.onPlay();
        }
    }

    /** Phát bài tiếp theo */
    public void playNext() {
        if (playlist.isEmpty()) return;
        currentIndex++;
        if (currentIndex >= playlist.size()) {
            currentIndex = 0; // loop lại playlist
        }
        play(playlist.get(currentIndex));
    }

    /** Phát bài trước */
    public void playPrevious() {
        if (playlist.isEmpty()) return;
        currentIndex--;
        if (currentIndex < 0) {
            currentIndex = playlist.size() - 1; // loop về cuối
        }
        play(playlist.get(currentIndex));
    }

    public void pause() {
        if (player != null && player.isPlaying()) {
            player.pause();
            if (listener != null) listener.onPause();
        }
    }

    public void resume() {
        if (player != null && !player.isPlaying()) {
            player.play();
            if (listener != null) listener.onPlay();
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

    public void release() {
        if (player != null) {
            player.release();
            player = null;
        }
        instance = null;
        playlist.clear();
        currentIndex = -1;
    }

    public interface OnPlayerStateChangeListener {
        void onTrackChanged(String title, String artist, String coverUrl, long durationMs);
        void onPlay();
        void onPause();
        void onTrackCompleted();
    }
}

package com.example.musicapp.player;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.Nullable;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;

import com.example.musicapp.model.Song;


public class MusicPlayerManager {

    private static MusicPlayerManager instance;
    private ExoPlayer player;
    private final Context context;
    private OnPlayerStateChangeListener listener;
    private Song currentSong;

    private MusicPlayerManager(Context context) {
        this.context = context.getApplicationContext();
        player = new ExoPlayer.Builder(this.context).build();
        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_ENDED) {
                    if (listener != null) listener.onTrackCompleted();
                }
            }
        });
    }

    public static synchronized MusicPlayerManager getInstance(Context context) {
        if (instance == null) instance = new MusicPlayerManager(context);
        return instance;
    }

    public void setOnPlayerStateChangeListener(@Nullable OnPlayerStateChangeListener listener) {
        this.listener = listener;
        if (currentSong != null && listener != null) {
            listener.onTrackChanged(currentSong.getName(), currentSong.getArtistName(), currentSong.getImageUrl());
            if (isPlaying()) listener.onPlay();
        }
    }

    public void play(Song song) {
        if (song == null) return;
        currentSong = song;

        player.setMediaItem(MediaItem.fromUri(Uri.parse(song.getAudioUrl())));
        player.prepare();
        player.play();

        if (listener != null) {
            listener.onTrackChanged(song.getName(), song.getArtistName(), song.getImageUrl());
            listener.onPlay();
        }
    }

    public void pause() {
        if (player.isPlaying()) {
            player.pause();
            if (listener != null) listener.onPause();
        }
    }

    public void resume() {
        if (!player.isPlaying()) {
            player.play();
            if (listener != null) listener.onPlay();
        }
    }

    public boolean isPlaying() {
        return player.isPlaying();
    }

    public Song getCurrentSong() {
        return currentSong;
    }

    public void release() {
        player.release();
        player = null;
        instance = null;
    }

    public interface OnPlayerStateChangeListener {
        void onTrackChanged(String title, String artist, String coverUrl);
        void onPlay();
        void onPause();
        void onTrackCompleted();
    }
}

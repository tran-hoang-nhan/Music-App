package com.example.musicapp.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.support.v4.media.session.MediaSessionCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.media.session.MediaButtonReceiver;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.example.musicapp.MainActivity;
import com.example.musicapp.R;
import com.example.musicapp.model.Song;
import com.example.musicapp.player.MusicPlayerManager;

public class MusicService extends Service implements MusicPlayerManager.OnPlayerStateChangeListener {

    private static final String CHANNEL_ID = "MusicPlayerChannel";
    private static final int NOTIFICATION_ID = 1;

    public static final String ACTION_PLAY = "ACTION_PLAY";
    public static final String ACTION_PAUSE = "ACTION_PAUSE";
    public static final String ACTION_NEXT = "ACTION_NEXT";
    public static final String ACTION_PREVIOUS = "ACTION_PREVIOUS";
    public static final String ACTION_STOP = "ACTION_STOP";

    private MusicPlayerManager playerManager;
    private MediaSessionCompat mediaSession;
    private NotificationManager notificationManager;
    private boolean isServiceStarted = false;

    public class MusicBinder extends Binder {
        public MusicService getService() {
            return MusicService.this;
        }
    }

    private final IBinder binder = new MusicBinder();

    @Override
    public void onCreate() {
        super.onCreate();
        
        playerManager = MusicPlayerManager.getInstance(this);
        playerManager.addPlayerStateChangeListener(this);
        
        notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        createNotificationChannel();
        
        mediaSession = new MediaSessionCompat(this, "MusicService");
        mediaSession.setActive(true);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && intent.getAction() != null) {
            handleAction(intent.getAction());
        }
        return START_STICKY;
    }

    private void handleAction(String action) {
        switch (action) {
            case ACTION_PLAY:
                playerManager.resume();
                break;
            case ACTION_PAUSE:
                playerManager.pause();
                break;
            case ACTION_NEXT:
                playerManager.playNext();
                break;
            case ACTION_PREVIOUS:
                playerManager.playPrevious();
                break;
            case ACTION_STOP:
                stopForeground(true);
                stopSelf();
                break;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Music Player",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Music playback controls");
            channel.setShowBadge(false);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void showNotification(String title, String artist, String imageUrl, boolean isPlaying) {
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_music_note)
            .setContentTitle(title)
            .setContentText(artist)
            .setContentIntent(pendingIntent)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(createAction(R.drawable.ic_skip_previous, "Previous", ACTION_PREVIOUS))
            .addAction(createAction(
                isPlaying ? R.drawable.ic_pause : R.drawable.ic_play,
                isPlaying ? "Pause" : "Play",
                isPlaying ? ACTION_PAUSE : ACTION_PLAY
            ))
            .addAction(createAction(R.drawable.ic_skip_next, "Next", ACTION_NEXT))
            .setStyle(new androidx.media.app.NotificationCompat.MediaStyle()
                .setShowActionsInCompactView(0, 1, 2)
                .setMediaSession(mediaSession.getSessionToken()));

        if (imageUrl != null && !imageUrl.isEmpty()) {
            Glide.with(this)
                .asBitmap()
                .load(imageUrl)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        builder.setLargeIcon(resource);
                        startForeground(NOTIFICATION_ID, builder.build());
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {
                        startForeground(NOTIFICATION_ID, builder.build());
                    }
                });
        } else {
            startForeground(NOTIFICATION_ID, builder.build());
        }
    }

    private NotificationCompat.Action createAction(int icon, String title, String action) {
        Intent intent = new Intent(this, MusicService.class);
        intent.setAction(action);
        PendingIntent pendingIntent = PendingIntent.getService(this, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        
        return new NotificationCompat.Action.Builder(icon, title, pendingIntent).build();
    }

    @Override
    public void onTrackChanged(String title, String artist, String coverUrl, long durationMs) {
        showNotification(title, artist, coverUrl, playerManager.isPlaying());
        if (!isServiceStarted) {
            isServiceStarted = true;
        }
    }

    @Override
    public void onPlay() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            showNotification(currentSong.getName(), currentSong.getArtistName(), 
                currentSong.getImageUrl(), true);
        }
    }

    @Override
    public void onPause() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            showNotification(currentSong.getName(), currentSong.getArtistName(), 
                currentSong.getImageUrl(), false);
        }
    }

    @Override
    public void onTrackCompleted() {
        // Handle track completion if needed
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mediaSession != null) {
            mediaSession.release();
        }
        if (playerManager != null) {
            playerManager.setOnPlayerStateChangeListener(null);
        }
        stopForeground(true);
    }
}
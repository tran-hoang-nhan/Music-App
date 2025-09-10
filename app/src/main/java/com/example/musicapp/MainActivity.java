package com.example.musicapp;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import com.bumptech.glide.Glide;
import com.example.musicapp.model.Song;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.service.MusicService;
import com.example.musicapp.storage.FavoritesManager;
import com.example.musicapp.utils.ColorExtractor;
import androidx.core.content.ContextCompat;
import com.google.android.material.bottomnavigation.BottomNavigationView;

import android.content.ComponentName;
import android.content.ServiceConnection;

public class MainActivity extends AppCompatActivity implements MusicPlayerManager.OnPlayerStateChangeListener {

    private MusicPlayerManager playerManager;
    private boolean isServiceBound = false;
    
    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, android.os.IBinder service) {
            MusicService.MusicBinder binder = (MusicService.MusicBinder) service;
            MusicService musicService = binder.getService();
            isServiceBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            isServiceBound = false;
        }
    };

    private View playerView;
    private ImageView imgCover;
    private TextView txtSongTitle, txtArtist, tvCurrentTime, tvDuration;
    private ImageButton btnPlayPause, btnNext, btnPrevious;
    private SeekBar seekBar;
    private boolean isInFullPlayer = false;


    private final Handler handler = new Handler(Looper.getMainLooper());
    private Runnable updateProgress;

    private NavController navController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Navigation
        BottomNavigationView navView = findViewById(R.id.nav_view);
        navController = Navigation.findNavController(this, R.id.nav_host_fragment_activity_main);
        navController.addOnDestinationChangedListener((controller, destination, arguments) -> {
            isInFullPlayer = destination.getId() == R.id.navigation_music_player;
            updateMiniPlayerVisibility();
        });
        AppBarConfiguration appBarConfiguration = new AppBarConfiguration.Builder(
                R.id.navigation_dashboard, R.id.navigation_profile, R.id.navigation_discover, R.id.navigation_library
        ).build();
        NavigationUI.setupWithNavController(navView, navController);

        // PlayerView
        playerView = findViewById(R.id.playerView);
        if (playerView != null) {
            imgCover = playerView.findViewById(R.id.imgCover);
            txtSongTitle = playerView.findViewById(R.id.txtSongTitle);
            txtArtist = playerView.findViewById(R.id.txtArtist);
            btnPlayPause = playerView.findViewById(R.id.btnPlayPause);
            btnPrevious = playerView.findViewById(R.id.btnPrevious);
            btnNext = playerView.findViewById(R.id.btnNext);
            seekBar = playerView.findViewById(R.id.seekBar);
            tvCurrentTime = playerView.findViewById(R.id.txtCurrentTime);
            tvDuration = playerView.findViewById(R.id.tvDuration);
        }

        if (playerView != null) {
            playerView.setVisibility(View.GONE);
        }

        // MusicPlayerManager
        playerManager = MusicPlayerManager.getInstance(this);
        playerManager.setOnPlayerStateChangeListener(this);
        
        // Force reload favorites when app starts
        FavoritesManager favoritesManager = FavoritesManager.getInstance(this);
        favoritesManager.forceReloadFavorites();
        
        // Start and bind to MusicService
        Intent serviceIntent = new Intent(this, MusicService.class);
        startService(serviceIntent);
        bindService(serviceIntent, serviceConnection, BIND_AUTO_CREATE);

        // Play/Pause
        btnPlayPause.setOnClickListener(v -> {
            if (playerManager.isPlaying()) {
                playerManager.pause();
            } else {
                playerManager.resume();
            }
            // Cập nhật ngay lập tức để tránh lag
            updatePlayPauseButton();
        });

        // Nhấn vào artist → chuyển sang ArtistDetail
        txtArtist.setOnClickListener(v -> {
            Song currentSong = playerManager.getCurrentSong();
            if (currentSong != null) {
                Bundle bundle = new Bundle();
                bundle.putString("artist_id", currentSong.getArtistId());
                bundle.putString("artist_name", currentSong.getArtistName());
                bundle.putString("artist_image", currentSong.getArtistImage());

                navController.navigate(R.id.navigation_artist_detail, bundle);
            }
        });

        btnPrevious.setOnClickListener(v -> playerManager.playPrevious());
        btnNext.setOnClickListener(v -> playerManager.playNext());

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser && playerManager.getPlayer() != null) {
                    long dur = playerManager.getPlayer().getDuration();
                    playerManager.getPlayer().seekTo(progress * dur / 100);
                }
            }
            @Override public void onStartTrackingTouch(SeekBar seekBar) {}
            @Override public void onStopTrackingTouch(SeekBar seekBar) {}
        });

        updateProgress = new Runnable() {
            @Override
            public void run() {
                if (playerManager.getPlayer() != null) {
                    long pos = playerManager.getPlayer().getCurrentPosition();
                    long dur = playerManager.getPlayer().getDuration();
                    if (dur > 0) {
                        int progress = (int) (pos * 100 / dur);
                        seekBar.setProgress(progress);

                        tvCurrentTime.setText(MusicPlayerManager.formatTime(pos));
                    }
                }
                handler.postDelayed(this, 500);
            }
        };

        setupMiniPlayerClick();
        handler.post(updateProgress);
        
        // Cập nhật trạng thái ban đầu
        updatePlayPauseButton();
    }
    
    private void updatePlayPauseButton() {
        if (btnPlayPause != null && playerManager != null) {
            if (playerManager.isPlaying()) {
                btnPlayPause.setImageResource(R.drawable.ic_pause);
            } else {
                btnPlayPause.setImageResource(R.drawable.ic_play);
            }
        }
    }

    // Phát bài hát từ fragment
    public void playSong(Song song) {
        if (song == null) return;
        android.util.Log.d("MainActivity", "playSong: " + song.getName());
        
        // Đảm bảo player đã sẵn sàng
        if (playerManager != null) {
            playerManager.play(song);
            // Force update mini player visibility and button state immediately
            updateMiniPlayerVisibility();
            updatePlayPauseButton();
        }
    }

    @Override
    public void onTrackChanged(String title, String artist, String coverUrl, long durationMs) {
        android.util.Log.d("MainActivity", "onTrackChanged: " + title + " - " + artist);
        if (txtSongTitle != null) {
            txtSongTitle.setText(title);
            android.util.Log.d("MainActivity", "Set title: " + title);
        }
        if (txtArtist != null) {
            txtArtist.setText(artist);
            android.util.Log.d("MainActivity", "Set artist: " + artist);
        }

        // Cập nhật duration - lấy từ player nếu API không có
        if (tvDuration != null) {
            if (durationMs > 0) {
                tvDuration.setText(MusicPlayerManager.formatTime(durationMs));
            } else {
                // Delay để lấy duration từ player
                handler.postDelayed(() -> {
                    if (playerManager.getPlayer() != null) {
                        long duration = playerManager.getPlayer().getDuration();
                        if (duration > 0 && tvDuration != null) {
                            tvDuration.setText(MusicPlayerManager.formatTime(duration));
                        }
                    }
                }, 1000);
            }
        }
        if (tvCurrentTime != null) tvCurrentTime.setText("0:00");

        if (coverUrl != null && !coverUrl.isEmpty() && imgCover != null) {
            Glide.with(this)
                .load(coverUrl)
                .placeholder(R.drawable.placeholder)
                .error(R.drawable.placeholder)
                .into(imgCover);
                
            // Update mini player background color
            updateMiniPlayerBackground(coverUrl);
        }
        
        // Update mini player visibility and button state
        updateMiniPlayerVisibility();
        updatePlayPauseButton();
    }

    @Override
    public void onPlay() {
        if (btnPlayPause != null) {
            btnPlayPause.setImageResource(R.drawable.ic_pause);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (btnPlayPause != null) {
            btnPlayPause.setImageResource(R.drawable.ic_play);
        }
    }

    @Override
    public void onTrackCompleted() {
        btnPlayPause.setImageResource(R.drawable.ic_play);
        seekBar.setProgress(0);
        tvCurrentTime.setText("0:00");
    }
    private void updateMiniPlayerVisibility() {
        if (playerView != null) {
            if (isInFullPlayer) {
                playerView.setVisibility(View.GONE);
            } else {
                if (playerManager != null && playerManager.getCurrentSong() != null) {
                    playerView.setVisibility(View.VISIBLE);
                } else {
                    playerView.setVisibility(View.GONE);
                }
            }
        }
    }

    private void updateMiniPlayerBackground(String imageUrl) {
        View miniPlayerBg = findViewById(R.id.miniPlayerBackground);
        if (miniPlayerBg != null && imageUrl != null) {
            ColorExtractor.extractDominantColor(this, imageUrl, color -> runOnUiThread(() -> {
                // Create subtle gradient for mini player
                int darkerColor = ColorExtractor.darkenColor(color, 0.3f);
                android.graphics.drawable.GradientDrawable gradient = new android.graphics.drawable.GradientDrawable(
                        android.graphics.drawable.GradientDrawable.Orientation.LEFT_RIGHT,
                        new int[]{color, darkerColor}
                );
                gradient.setCornerRadius(16f);
                miniPlayerBg.setBackground(gradient);
                
                // Update text color based on background brightness
                updateMiniPlayerTextColor(color);
            }));
        }
    }
    
    private void updateMiniPlayerTextColor(int backgroundColor) {
        boolean isLight = ColorExtractor.isColorLight(backgroundColor);
        int textColor = isLight ? getColor(android.R.color.black) : getColor(android.R.color.white);
        
        if (txtSongTitle != null) txtSongTitle.setTextColor(textColor);
        if (txtArtist != null) txtArtist.setTextColor(textColor);
        if (tvCurrentTime != null) tvCurrentTime.setTextColor(textColor);
        if (tvDuration != null) tvDuration.setTextColor(textColor);
    }
    
    public void setupMiniPlayerClick() {
        View miniPlayer = findViewById(R.id.playerView);
        if (miniPlayer != null) {
            miniPlayer.setOnClickListener(v -> {
                NavController navController = Navigation.findNavController(
                        this,
                        R.id.nav_host_fragment_activity_main
                );
                navController.navigate(R.id.navigation_music_player);
            });
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(updateProgress);
        
        if (isServiceBound) {
            unbindService(serviceConnection);
            isServiceBound = false;
        }
    }

}

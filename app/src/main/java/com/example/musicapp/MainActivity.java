package com.example.musicapp;

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
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity implements MusicPlayerManager.OnPlayerStateChangeListener {

    private MusicPlayerManager playerManager;

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
        });
        AppBarConfiguration appBarConfiguration = new AppBarConfiguration.Builder(
                R.id.navigation_dashboard, R.id.navigation_profile, R.id.navigation_discover
        ).build();
        NavigationUI.setupWithNavController(navView, navController);

        // PlayerView
        playerView = findViewById(R.id.playerView);
        imgCover = findViewById(R.id.imgCover);
        txtSongTitle = findViewById(R.id.txtSongTitle);
        txtArtist = findViewById(R.id.txtArtist);
        btnPlayPause = findViewById(R.id.btnPlayPause);
        btnPrevious = findViewById(R.id.btnPrevious);
        btnNext = findViewById(R.id.btnNext);
        seekBar = findViewById(R.id.seekBar);
        tvCurrentTime = findViewById(R.id.txtCurrentTime);
        tvDuration = findViewById(R.id.tvDuration);

        playerView.setVisibility(View.GONE);

        // MusicPlayerManager
        playerManager = MusicPlayerManager.getInstance(this);
        playerManager.setOnPlayerStateChangeListener(this);

        // Play/Pause
        btnPlayPause.setOnClickListener(v -> {
            if (playerManager.isPlaying()) {
                playerManager.pause();
            } else {
                playerManager.resume();
            }
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

        // SeekBar listener để tua bài hát
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

        // Runnable update SeekBar & thời gian hiện tại
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
    }

    // Phát bài hát từ fragment
    public void playSong(Song song) {
        if (song == null) return;
        playerManager.play(song);
    }

    @Override
    public void onTrackChanged(String title, String artist, String coverUrl, long durationMs) {
        txtSongTitle.setText(title);
        txtArtist.setText(artist);

        // Cập nhật duration ngay khi load bài mới
        tvDuration.setText(MusicPlayerManager.formatTime(durationMs));
        tvCurrentTime.setText("0:00");

        if (coverUrl != null && !coverUrl.isEmpty()) {
            Glide.with(this).load(coverUrl).into(imgCover);
        }
        if (!isInFullPlayer) {
            playerView.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onPlay() {
        btnPlayPause.setImageResource(R.drawable.ic_pause);
    }

    @Override
    public void onPause() {
        super.onPause();
        btnPlayPause.setImageResource(R.drawable.ic_play);
    }

    @Override
    public void onTrackCompleted() {
        btnPlayPause.setImageResource(R.drawable.ic_play);
        seekBar.setProgress(0);
        tvCurrentTime.setText("0:00");
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
    }

}

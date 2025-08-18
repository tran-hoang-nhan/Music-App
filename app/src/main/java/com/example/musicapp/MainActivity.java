package com.example.musicapp;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
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

    // UI của PlayerView
    private View playerView;
    private ImageView imgCover;
    private TextView txtSongTitle, txtArtist;
    private ImageButton btnPlayPause;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Navigation setup
        try {
            BottomNavigationView navView = findViewById(R.id.nav_view);
            NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment_activity_main);
            AppBarConfiguration appBarConfiguration = new AppBarConfiguration.Builder(
                    R.id.navigation_dashboard
            ).build();
            NavigationUI.setupWithNavController(navView, navController);
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("MainActivity", "Navigation setup error: " + e.getMessage());
        }

        // Khởi tạo PlayerView (đúng ID trong music_player.xml)
        playerView = findViewById(R.id.playerView);
        imgCover = findViewById(R.id.imgCover);
        txtSongTitle = findViewById(R.id.txtSongTitle);
        txtArtist = findViewById(R.id.txtArtist);
        btnPlayPause = findViewById(R.id.btnPlayPause);

        playerView.setVisibility(View.GONE);

        // Quản lý nhạc
        playerManager = MusicPlayerManager.getInstance(this);
        playerManager.setOnPlayerStateChangeListener(this);

        btnPlayPause.setOnClickListener(v -> {
            if (playerManager.isPlaying()) {
                playerManager.pause();
            } else {
                playerManager.resume();
            }
        });
    }

    public void playSong(Song song) {
        if (song == null) return;
        playerManager.play(song);
    }

    @Override
    public void onTrackChanged(String title, String artist, String coverUrl) {
        txtSongTitle.setText(title);
        txtArtist.setText(artist);
        if (coverUrl != null && !coverUrl.isEmpty()) Glide.with(this).load(coverUrl).into(imgCover);
        playerView.setVisibility(View.VISIBLE);
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
    }
}

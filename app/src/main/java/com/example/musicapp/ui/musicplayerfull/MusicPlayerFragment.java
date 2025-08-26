package com.example.musicapp.ui.musicplayerfull;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.model.Song;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.concurrent.TimeUnit;

public class MusicPlayerFragment extends Fragment {

    private TextView textCurrentTime;
    private TextView textTotalTime;
    private SeekBar seekBar;
    private ImageButton btnPlayPause;

    private Handler handler = new Handler();
    private MusicPlayerManager playerManager;

    private Runnable updateSeekbarRunnable = new Runnable() {
        @Override
        public void run() {
            if (playerManager != null && playerManager.getPlayer() != null) {
                long current = playerManager.getPlayer().getCurrentPosition();
                long total = playerManager.getPlayer().getDuration();

                seekBar.setMax((int) total);
                seekBar.setProgress((int) current);

                textCurrentTime.setText(formatTime(current));
                textTotalTime.setText(formatTime(total));

                handler.postDelayed(this, 500);
            }
        }
    };

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_music_player_full, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view,
                              @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        ImageView imageCover = view.findViewById(R.id.imageCover);
        TextView textSongTitle = view.findViewById(R.id.textSongTitle);
        TextView textArtist = view.findViewById(R.id.textArtist);
        textCurrentTime = view.findViewById(R.id.textCurrentTime);
        textTotalTime = view.findViewById(R.id.textTotalTime);
        seekBar = view.findViewById(R.id.seekBar);
        btnPlayPause = view.findViewById(R.id.btnPlayPause);
        ImageButton btnNext = view.findViewById(R.id.btnNext);
        ImageButton btnPrevious = view.findViewById(R.id.btnPrevious);
        ImageButton btnShuffle = view.findViewById(R.id.btnShuffle);
        ImageButton btnRepeat = view.findViewById(R.id.btnRepeat);
        ImageButton btnFavorite = view.findViewById(R.id.btnFavorite);

        playerManager = MusicPlayerManager.getInstance(requireContext());

        // Lấy bài hiện tại đang phát
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            textSongTitle.setText(currentSong.getName());
            textArtist.setText(currentSong.getArtistName());
            Glide.with(this)
                    .load(currentSong.getImageUrl())
                    .placeholder(R.drawable.placeholder)
                    .into(imageCover);
        }

        updatePlayPauseIcon();
        handler.post(updateSeekbarRunnable);

        // Xử lý nút Play/Pause
        btnPlayPause.setOnClickListener(v -> {
            if (playerManager.getPlayer().isPlaying()) {
                playerManager.getPlayer().pause();
            } else {
                playerManager.getPlayer().play();
            }
            updatePlayPauseIcon();
        });

        // Xử lý seekbar
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    playerManager.getPlayer().seekTo(progress);
                }
            }
            @Override public void onStartTrackingTouch(SeekBar seekBar) {}
            @Override public void onStopTrackingTouch(SeekBar seekBar) {}
        });
    }

    private void updatePlayPauseIcon() {
        if (playerManager.getPlayer().isPlaying()) {
            btnPlayPause.setImageResource(R.drawable.ic_pause);
        } else {
            btnPlayPause.setImageResource(R.drawable.ic_play);
        }
    }

    @SuppressLint("DefaultLocale")
    private String formatTime(long millis) {
        return String.format("%d:%02d",
                TimeUnit.MILLISECONDS.toMinutes(millis),
                TimeUnit.MILLISECONDS.toSeconds(millis) % 60);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        handler.removeCallbacks(updateSeekbarRunnable);
    }
}

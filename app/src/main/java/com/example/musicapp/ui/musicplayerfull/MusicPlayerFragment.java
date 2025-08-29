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
import com.example.musicapp.ui.library.AddToPlaylistDialog;
import com.example.musicapp.ui.library.LibraryViewModel;
import androidx.lifecycle.ViewModelProvider;

import java.util.concurrent.TimeUnit;

public class MusicPlayerFragment extends Fragment {

    private TextView textCurrentTime;
    private TextView textTotalTime;
    private SeekBar seekBar;
    private ImageButton btnPlayPause, btnShuffle, btnRepeat, btnNext, btnPrevious;

    private final Handler handler = new Handler();
    private MusicPlayerManager playerManager;
    private boolean isShuffleEnabled = false;
    private boolean isRepeatEnabled = false;

    private final Runnable updateSeekbarRunnable = new Runnable() {
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
        btnNext = view.findViewById(R.id.btnNext);
        btnPrevious = view.findViewById(R.id.btnPrevious);
        btnShuffle = view.findViewById(R.id.btnShuffle);
        btnRepeat = view.findViewById(R.id.btnRepeat);
        ImageButton btnAddToPlaylist = view.findViewById(R.id.btnAddToPlaylist);

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

        // Shuffle button
        btnShuffle.setOnClickListener(v -> {
            isShuffleEnabled = !isShuffleEnabled;
            updateShuffleButton();
        });

        // Repeat button
        btnRepeat.setOnClickListener(v -> {
            isRepeatEnabled = !isRepeatEnabled;
            updateRepeatButton();
        });

        // Next button
        btnNext.setOnClickListener(v -> {
            playerManager.playNext();
            updateCurrentSongInfo();
        });

        // Previous button
        btnPrevious.setOnClickListener(v -> {
            playerManager.playPrevious();
            updateCurrentSongInfo();
        });

        // Add to playlist button
        btnAddToPlaylist.setOnClickListener(v -> {
            Song song = playerManager.getCurrentSong();
            if (song != null) {
                showAddToPlaylistDialog(song);
            }
        });
    }

    private void updatePlayPauseIcon() {
        if (playerManager.getPlayer().isPlaying()) {
            btnPlayPause.setImageResource(R.drawable.ic_pause);
        } else {
            btnPlayPause.setImageResource(R.drawable.ic_play);
        }
    }

    private void updateShuffleButton() {
        if (isShuffleEnabled) {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
        } else {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.white));
        }
    }

    private void updateRepeatButton() {
        if (isRepeatEnabled) {
            btnRepeat.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
        } else {
            btnRepeat.setColorFilter(getResources().getColor(android.R.color.white));
        }
    }

    private void updateCurrentSongInfo() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null && getView() != null) {
            TextView textSongTitle = getView().findViewById(R.id.textSongTitle);
            TextView textArtist = getView().findViewById(R.id.textArtist);
            ImageView imageCover = getView().findViewById(R.id.imageCover);
            
            textSongTitle.setText(currentSong.getName());
            textArtist.setText(currentSong.getArtistName());
            Glide.with(this)
                    .load(currentSong.getImageUrl())
                    .placeholder(R.drawable.placeholder)
                    .into(imageCover);
        }
    }

    @SuppressLint("DefaultLocale")
    private String formatTime(long millis) {
        return String.format("%d:%02d",
                TimeUnit.MILLISECONDS.toMinutes(millis),
                TimeUnit.MILLISECONDS.toSeconds(millis) % 60);
    }

    private void showAddToPlaylistDialog(Song song) {
        AddToPlaylistDialog dialog = new AddToPlaylistDialog();
        dialog.setSong(song);
        dialog.setOnPlaylistSelectedListener(playlist -> {
            LibraryViewModel libraryViewModel = new ViewModelProvider(this).get(LibraryViewModel.class);
            libraryViewModel.addSongToPlaylist(playlist.getId(), song);
            // You can add a toast message here if needed
        });
        dialog.show(getParentFragmentManager(), "AddToPlaylistDialog");
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        handler.removeCallbacks(updateSeekbarRunnable);
    }
}

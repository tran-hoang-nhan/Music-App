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
import com.example.musicapp.storage.FavoritesManager;
import com.example.musicapp.ui.library.AddToPlaylistDialog;
import com.example.musicapp.ui.library.LibraryViewModel;
import com.example.musicapp.utils.AnimationHelper;
import com.example.musicapp.utils.ColorExtractor;
import androidx.lifecycle.ViewModelProvider;

import java.util.concurrent.TimeUnit;

public class MusicPlayerFragment extends Fragment {

    private TextView textCurrentTime;
    private TextView textTotalTime;
    private SeekBar seekBar;
    private ImageButton btnPlayPause;
    private ImageButton btnShuffle;
    private ImageButton btnRepeat;

    private final Handler handler = new Handler();
    private MusicPlayerManager playerManager;
    private ImageButton btnFavorite;
    private FavoritesManager favoritesManager;
    private MusicPlayerManager.OnPlayerStateChangeListener playerStateListener;

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
        ImageButton btnNext = view.findViewById(R.id.btnNext);
        ImageButton btnPrevious = view.findViewById(R.id.btnPrevious);
        btnShuffle = view.findViewById(R.id.btnShuffle);
        btnRepeat = view.findViewById(R.id.btnRepeat);
        btnFavorite = view.findViewById(R.id.btnFavorite);
        ImageButton btnLyrics = view.findViewById(R.id.btnLyrics);
        ImageButton btnAddToPlaylist = view.findViewById(R.id.btnAddToPlaylist);

        playerManager = MusicPlayerManager.getInstance(requireContext());
        favoritesManager = FavoritesManager.getInstance(requireContext());

        // Setup player state listener
        playerStateListener = new MusicPlayerManager.OnPlayerStateChangeListener() {
            @Override
            public void onTrackChanged(String title, String artist, String coverUrl, long durationMs) {
                updateCurrentSongInfo();
                updatePlayPauseIcon();
                updateFavoriteButton();
            }

            @Override
            public void onPlay() {
                updatePlayPauseIcon();
            }

            @Override
            public void onPause() {
                updatePlayPauseIcon();
            }

            @Override
            public void onTrackCompleted() {
                updatePlayPauseIcon();
            }
        };
        
        playerManager.addPlayerStateChangeListener(playerStateListener);

        // Lấy bài hiện tại đang phát
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            textSongTitle.setText(currentSong.getName());
            textArtist.setText(currentSong.getArtistName());
            Glide.with(this)
                    .load(currentSong.getImageUrl())
                    .placeholder(R.drawable.placeholder)
                    .into(imageCover);
                    
            // Extract color and create gradient background
            updateBackgroundGradient(currentSong.getImageUrl());
        }

        updatePlayPauseIcon();
        updateShuffleButton();
        updateRepeatButton();
        updateFavoriteButton();
        handler.post(updateSeekbarRunnable);
        
        // Add entrance animations
        AnimationHelper.fadeIn(requireContext(), view);
        AnimationHelper.scaleIn(requireContext(), imageCover);

        // Xử lý nút Play/Pause
        btnPlayPause.setOnClickListener(v -> {
            AnimationHelper.bounce(requireContext(), v);
            if (playerManager.isPlaying()) {
                playerManager.pause();
            } else {
                playerManager.resume();
            }
            // Không cần gọi updatePlayPauseIcon() vì listener sẽ tự động cập nhật
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
            playerManager.toggleShuffle();
            updateShuffleButton();
        });

        // Repeat button
        btnRepeat.setOnClickListener(v -> {
            playerManager.toggleRepeat();
            updateRepeatButton();
        });
        
        // Favorite button
        btnFavorite.setOnClickListener(v -> {
            Song song = playerManager.getCurrentSong();
            if (song != null) {
                // Disable button temporarily
                btnFavorite.setEnabled(false);
                
                boolean currentState = favoritesManager.isFavorite(song);
                boolean newState = !currentState;
                
                // Update UI immediately
                if (newState) {
                    btnFavorite.setImageResource(R.drawable.ic_favorite_filled);
                    btnFavorite.setColorFilter(getResources().getColor(android.R.color.holo_red_light));
                } else {
                    btnFavorite.setImageResource(R.drawable.ic_favorite_border);
                    btnFavorite.setColorFilter(getResources().getColor(android.R.color.white));
                }
                
                // Update Firebase
                if (newState) {
                    favoritesManager.addFavorite(song);
                } else {
                    favoritesManager.removeFavorite(song);
                }
                
                // Re-enable button
                btnFavorite.postDelayed(() -> btnFavorite.setEnabled(true), 1000);
            }
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

        // Lyrics button
        btnLyrics.setOnClickListener(v -> {
            AnimationHelper.animateButton(requireContext(), v, () -> {
                androidx.navigation.fragment.NavHostFragment.findNavController(this)
                    .navigate(R.id.action_music_player_to_lyrics);
            });
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
        if (playerManager != null && btnPlayPause != null) {
            if (playerManager.isPlaying()) {
                btnPlayPause.setImageResource(R.drawable.ic_pause);
            } else {
                btnPlayPause.setImageResource(R.drawable.ic_play);
            }
        }
    }

    private void updateShuffleButton() {
        if (playerManager.isShuffleEnabled()) {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
        } else {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.white));
        }
    }

    private void updateRepeatButton() {
        MusicPlayerManager.RepeatMode mode = playerManager.getRepeatMode();
        switch (mode) {
            case OFF:
                btnRepeat.setColorFilter(getResources().getColor(android.R.color.white));
                btnRepeat.setImageResource(R.drawable.ic_repeat);
                break;
            case ALL:
                btnRepeat.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
                btnRepeat.setImageResource(R.drawable.ic_repeat);
                break;
            case ONE:
                btnRepeat.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
                btnRepeat.setImageResource(R.drawable.ic_repeat_one);
                break;
        }
    }
    
    private void updateFavoriteButton() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            // Load favorites from Firebase first
            favoritesManager.loadFavoritesWithCallback(() -> {
                boolean isFavorite = favoritesManager.isFavorite(currentSong);
                
                // Update UI on main thread
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        if (isFavorite) {
                            btnFavorite.setImageResource(R.drawable.ic_favorite_filled);
                            btnFavorite.setColorFilter(getResources().getColor(android.R.color.holo_red_light));
                        } else {
                            btnFavorite.setImageResource(R.drawable.ic_favorite_border);
                            btnFavorite.setColorFilter(getResources().getColor(android.R.color.white));
                        }
                    });
                }
            });
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
                    
            // Update background gradient for new song
            updateBackgroundGradient(currentSong.getImageUrl());
                    
            // Update favorite button for new song
            updateFavoriteButton();
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

    private void updateBackgroundGradient(String imageUrl) {
        if (imageUrl != null && getView() != null) {
            ColorExtractor.extractDominantColor(requireContext(), imageUrl, color -> {
                if (getView() != null) {
                    View background = getView().findViewById(R.id.playerBackground);
                    ColorExtractor.applyGradientBackground(background, color);
                }
            });
        }
    }
    
    @Override
    public void onResume() {
        super.onResume();
        // Update favorite button when fragment becomes visible
        updateFavoriteButton();
    }
    
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        handler.removeCallbacks(updateSeekbarRunnable);
        if (playerManager != null && playerStateListener != null) {
            playerManager.removePlayerStateChangeListener(playerStateListener);
        }
    }
}

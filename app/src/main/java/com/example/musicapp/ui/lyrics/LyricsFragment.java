package com.example.musicapp.ui.lyrics;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.api.LyricsService;
import com.example.musicapp.databinding.FragmentLyricsBinding;
import com.example.musicapp.model.Song;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.utils.AnimationHelper;
import com.example.musicapp.utils.ColorExtractor;

public class LyricsFragment extends Fragment {

    private FragmentLyricsBinding binding;
    private MusicPlayerManager playerManager;
    private LyricsService lyricsService;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        binding = FragmentLyricsBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        playerManager = MusicPlayerManager.getInstance(requireContext());
        lyricsService = LyricsService.getInstance();

        setupToolbar();
        setupUI();
        loadCurrentSong();
        
        // Add entrance animation
        AnimationHelper.fadeIn(requireContext(), view);
    }

    private void setupToolbar() {
        binding.toolbar.setNavigationOnClickListener(v -> {
            AnimationHelper.fadeOut(requireContext(), binding.getRoot());
            binding.getRoot().postDelayed(() -> 
                NavHostFragment.findNavController(this).popBackStack(), 200);
        });
    }

    private void setupUI() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            binding.txtSongTitle.setText(currentSong.getName());
            binding.txtArtistName.setText(currentSong.getArtistName());

            Glide.with(this)
                .load(currentSong.getImageUrl())
                .placeholder(R.drawable.placeholder)
                .into(binding.imgSongCover);

            updateBackgroundColor(currentSong.getImageUrl());
        }
    }

    private void loadCurrentSong() {
        Song currentSong = playerManager.getCurrentSong();
        if (currentSong != null) {
            loadLyrics(currentSong.getArtistName(), currentSong.getName());
        } else {
            binding.txtLyrics.setText("Không có bài hát nào đang phát");
        }
    }

    private void loadLyrics(String artist, String title) {
        binding.progressBar.setVisibility(View.VISIBLE);
        binding.txtLyrics.setText("Đang tải lời bài hát...");

        lyricsService.getLyrics(artist, title, new LyricsService.LyricsCallback() {
            @Override
            public void onSuccess(String lyrics) {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        binding.progressBar.setVisibility(View.GONE);
                        binding.txtLyrics.setText(lyrics);
                        AnimationHelper.slideUp(requireContext(), binding.txtLyrics);
                    });
                }
            }

            @Override
            public void onError(String error) {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        binding.progressBar.setVisibility(View.GONE);
                        binding.txtLyrics.setText(error);
                    });
                }
            }
        });
    }

    private void updateBackgroundColor(String imageUrl) {
        ColorExtractor.extractDominantColor(requireContext(), imageUrl, color -> {
            if (getActivity() != null) {
                getActivity().runOnUiThread(() -> {
                    if (binding != null) {
                        ColorExtractor.applyGradientBackground(binding.lyricsBackground, color);
                    }
                });
            }
        });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
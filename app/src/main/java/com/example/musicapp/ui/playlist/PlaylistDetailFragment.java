package com.example.musicapp.ui.playlist;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.SongAdapter;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.utils.ColorExtractor;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.google.android.material.appbar.CollapsingToolbarLayout;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

import java.util.ArrayList;

public class PlaylistDetailFragment extends Fragment {

    private PlaylistDetailViewModel viewModel;
    private SongAdapter songAdapter;
    private boolean isShuffleEnabled = false;
    private ImageView imageCover;
    private View backgroundColor;
    private CollapsingToolbarLayout collapsingToolbar;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_playlist_detail, container, false);

        viewModel = new ViewModelProvider(this).get(PlaylistDetailViewModel.class);

        TextView titleText;
        RecyclerView recyclerView = view.findViewById(R.id.recyclerSongs);
        imageCover = view.findViewById(R.id.image_cover);
        backgroundColor = view.findViewById(R.id.background_color);
        collapsingToolbar = view.findViewById(R.id.collapsingToolbar);

        titleText = view.findViewById(R.id.textPlaylistTitle);
        ImageButton btnShuffle = view.findViewById(R.id.btnShuffle);
        ImageButton btnPlayAll = view.findViewById(R.id.btnPlayAll);
        
        songAdapter = new SongAdapter(getContext(), new ArrayList<>());
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setAdapter(songAdapter);

        // Mini player click
        View miniPlayer = requireActivity().findViewById(R.id.playerView);
        if (miniPlayer != null) {
            miniPlayer.setOnClickListener(v -> {
                NavController navController = Navigation.findNavController(
                        requireActivity(),
                        R.id.nav_host_fragment_activity_main
                );
                navController.navigate(R.id.navigation_music_player);
            });
        }

        songAdapter.setOnItemClickListener((song, position) -> {
            MusicPlayerManager.getInstance(requireContext()).play(song);
            songAdapter.setSelectedPosition(position);
        });

        songAdapter.setOnArtistClickListener(artistName -> {
            Bundle bundle = new Bundle();
            bundle.putString("artist_name", artistName);

            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_artist_detail, bundle);
        });

        btnPlayAll.setOnClickListener(v -> viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> {
            if (songs != null && !songs.isEmpty()) {
                MusicPlayerManager.getInstance(requireContext()).play(songs.get(0));
            }
        }));

        btnShuffle.setOnClickListener(v -> {
            isShuffleEnabled = !isShuffleEnabled;
            updateShuffleButton(btnShuffle);
            
            // Play random song from playlist
            viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> {
                if (songs != null && !songs.isEmpty()) {
                    int randomIndex = (int) (Math.random() * songs.size());
                    MusicPlayerManager.getInstance(requireContext()).play(songs.get(randomIndex));
                }
            });
        });

        observeData();

        if (getArguments() != null) {
            String playlistName = getArguments().getString("playlist_name", "");
            titleText.setText(playlistName);
            viewModel.loadPlaylistSongs(playlistName);
            
            // Load playlist image and extract colors
            loadPlaylistImage(playlistName);
        }

        return view;
    }

    private void observeData() {
        viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> songAdapter.updateSongs(songs));
    }

    private void updateShuffleButton(ImageButton btnShuffle) {
        if (isShuffleEnabled) {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.holo_blue_light));
        } else {
            btnShuffle.setColorFilter(getResources().getColor(android.R.color.white));
        }
    }
    
    private void loadPlaylistImage(String playlistName) {
        // For demo, use placeholder. In real app, get image URL from API
        String imageUrl = "https://via.placeholder.com/300x300/1E88E5/FFFFFF?text=" + playlistName;
        
        Glide.with(this)
            .asBitmap()
            .load(imageUrl)
            .placeholder(R.drawable.placeholder)
            .into(new CustomTarget<Bitmap>() {
                @Override
                public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                    imageCover.setImageBitmap(resource);
                    
                    // Extract colors from image
                    ColorExtractor.extractColorsFromBitmap(resource, (dominantColor, vibrantColor) -> {
                        // Update background colors
                        backgroundColor.setBackgroundColor(dominantColor);
                        collapsingToolbar.setContentScrimColor(dominantColor);
                    });
                }
                
                @Override
                public void onLoadCleared(@Nullable Drawable placeholder) {
                    // Keep default colors if image fails to load
                }
            });
    }
}
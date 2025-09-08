package com.example.musicapp.ui.library;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongAdapter;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.storage.FavoritesManager;
import com.example.musicapp.utils.AnimationHelper;
import com.google.android.material.appbar.CollapsingToolbarLayout;

import android.widget.ImageButton;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class FavoritesPlaylistFragment extends Fragment implements FavoritesManager.OnFavoritesChangeListener {

    private RecyclerView recyclerView;
    private SongAdapter adapter;
    private FavoritesManager favoritesManager;
    private ImageView imageCover;
    private TextView playlistTitle;
    private View backgroundColor;
    private CollapsingToolbarLayout collapsingToolbar;
    private ImageButton btnShuffle, btnPlayAll;
    private MusicPlayerManager playerManager;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_playlist_detail, container, false);

        // Initialize views
        recyclerView = view.findViewById(R.id.recyclerSongs);
        imageCover = view.findViewById(R.id.image_cover);
        playlistTitle = view.findViewById(R.id.textPlaylistTitle);
        backgroundColor = view.findViewById(R.id.background_color);
        collapsingToolbar = view.findViewById(R.id.collapsingToolbar);

        // Initialize buttons
        btnShuffle = view.findViewById(R.id.btnShuffle);
        btnPlayAll = view.findViewById(R.id.btnPlayAll);
        
        playerManager = MusicPlayerManager.getInstance(requireContext());
        
        setupFavoritesPlaylist();
        setupRecyclerView();
        setupFavorites();
        setupControlButtons();
        
        // Add entrance animations
        AnimationHelper.fadeIn(requireContext(), view);
        AnimationHelper.slideUp(requireContext(), recyclerView);

        return view;
    }

    private void setupFavoritesPlaylist() {
        // Set favorites playlist UI
        playlistTitle.setText("Bài hát yêu thích");
        imageCover.setImageResource(R.drawable.ic_heart_playlist);
        
        // Set pink color for favorites
        backgroundColor.setBackgroundColor(0xFFE91E63);
        collapsingToolbar.setContentScrimColor(0xFFE91E63);
    }

    private void setupRecyclerView() {
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new SongAdapter(getContext(), new ArrayList<>());
        recyclerView.setAdapter(adapter);

        adapter.setOnItemClickListener((song, position) -> {
            // Set current favorites as playlist and play selected song
            List<Song> favorites = favoritesManager.getFavorites();
            playerManager.setPlaylist(favorites, position);
            
            // Update UI
            adapter.setSelectedPosition(position);
        });
        
        // Handle artist click
        adapter.setOnArtistClickListener(artistName -> {
            // Navigate to artist detail if needed
            android.util.Log.d("FavoritesPlaylist", "Artist clicked: " + artistName);
        });
    }

    private void setupFavorites() {
        favoritesManager = FavoritesManager.getInstance(requireContext());
        favoritesManager.setOnFavoritesChangeListener(this);
        
        // Load favorites with callback
        favoritesManager.loadFavoritesWithCallback(() -> {
            if (getActivity() != null) {
                getActivity().runOnUiThread(() -> {
                    List<Song> favorites = favoritesManager.getFavorites();
                    adapter.updateSongs(favorites);
                });
            }
        });
    }
    
    private void setupControlButtons() {
        btnPlayAll.setOnClickListener(v -> AnimationHelper.animateButton(requireContext(), v, () -> {
            List<Song> favorites = favoritesManager.getFavorites();
            if (favorites.isEmpty()) {
                Toast.makeText(getContext(), "Chưa có bài hát yêu thích nào", Toast.LENGTH_SHORT).show();
                return;
            }

            // Play all favorites
            playerManager.setPlaylist(favorites, 0);
            Toast.makeText(getContext(), "Phát tất cả bài hát yêu thích", Toast.LENGTH_SHORT).show();
        }));
        
        btnShuffle.setOnClickListener(v -> AnimationHelper.animateButton(requireContext(), v, () -> {
            List<Song> favorites = favoritesManager.getFavorites();
            if (favorites.isEmpty()) {
                Toast.makeText(getContext(), "Chưa có bài hát yêu thích nào", Toast.LENGTH_SHORT).show();
                return;
            }

            // Enable shuffle and play
            if (!playerManager.isShuffleEnabled()) {
                playerManager.toggleShuffle();
            }
            playerManager.setPlaylist(favorites, 0);
            Toast.makeText(getContext(), "Phát ngẫu nhiên bài hát yêu thích", Toast.LENGTH_SHORT).show();
        }));
    }

    @Override
    public void onFavoritesLoaded(List<Song> favorites) {
        if (getActivity() != null) {
            getActivity().runOnUiThread(() -> {
                adapter.updateSongs(favorites);
                AnimationHelper.slideUp(requireContext(), recyclerView);
            });
        }
    }

    @Override
    public void onFavoriteAdded(Song song) {
        if (getActivity() != null) {
            getActivity().runOnUiThread(() -> {
                List<Song> currentFavorites = favoritesManager.getFavorites();
                adapter.updateSongs(currentFavorites);
            });
        }
    }

    @Override
    public void onFavoriteRemoved(Song song) {
        if (getActivity() != null) {
            getActivity().runOnUiThread(() -> {
                List<Song> currentFavorites = favoritesManager.getFavorites();
                adapter.updateSongs(currentFavorites);
            });
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (favoritesManager != null) {
            favoritesManager.setOnFavoritesChangeListener(null);
        }
    }
}
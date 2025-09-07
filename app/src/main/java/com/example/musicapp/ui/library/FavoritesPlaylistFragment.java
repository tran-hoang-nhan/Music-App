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

import com.example.musicapp.MainActivity;
import com.example.musicapp.R;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongAdapter;
import com.example.musicapp.storage.FavoritesManager;
import com.google.android.material.appbar.CollapsingToolbarLayout;

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

        setupFavoritesPlaylist();
        setupRecyclerView();
        setupFavorites();

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
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).playSong(song);
            }
            adapter.setSelectedPosition(position);
        });
    }

    private void setupFavorites() {
        favoritesManager = FavoritesManager.getInstance(requireContext());
        favoritesManager.setOnFavoritesChangeListener(this);
        
        // Load initial favorites
        List<Song> favorites = favoritesManager.getFavorites();
        adapter.updateSongs(favorites);
    }

    @Override
    public void onFavoritesLoaded(List<Song> favorites) {
        adapter.updateSongs(favorites);
    }

    @Override
    public void onFavoriteAdded(Song song) {
        List<Song> currentFavorites = favoritesManager.getFavorites();
        adapter.updateSongs(currentFavorites);
    }

    @Override
    public void onFavoriteRemoved(Song song) {
        List<Song> currentFavorites = favoritesManager.getFavorites();
        adapter.updateSongs(currentFavorites);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (favoritesManager != null) {
            favoritesManager.setOnFavoritesChangeListener(null);
        }
    }
}
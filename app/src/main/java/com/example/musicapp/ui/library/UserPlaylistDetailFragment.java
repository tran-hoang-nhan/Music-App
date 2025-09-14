package com.example.musicapp.ui.library;

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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.SongAdapter;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.ArrayList;

public class UserPlaylistDetailFragment extends Fragment {

    private UserPlaylistDetailViewModel viewModel;
    private SongAdapter songAdapter;
    private boolean isShuffleEnabled = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_playlist_detail, container, false);

        viewModel = new ViewModelProvider(this).get(UserPlaylistDetailViewModel.class);

        TextView titleText = view.findViewById(R.id.textPlaylistTitle);
        ImageButton btnShuffle = view.findViewById(R.id.btnShuffle);
        ImageButton btnPlayAll = view.findViewById(R.id.btnPlayAll);
        RecyclerView recyclerView = view.findViewById(R.id.recyclerSongs);

        songAdapter = new SongAdapter(getContext(), new ArrayList<>());
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setAdapter(songAdapter);

        songAdapter.setOnItemClickListener((song, position) -> {
            MusicPlayerManager.getInstance(requireContext()).play(song);
            songAdapter.setSelectedPosition(position);
        });

        btnPlayAll.setOnClickListener(v -> viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> {
            if (songs != null && !songs.isEmpty()) {
                MusicPlayerManager.getInstance(requireContext()).play(songs.get(0));
            }
        }));

        btnShuffle.setOnClickListener(v -> {
            isShuffleEnabled = !isShuffleEnabled;
            updateShuffleButton(btnShuffle);

            viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> {
                if (songs != null && !songs.isEmpty()) {
                    int randomIndex = (int) (Math.random() * songs.size());
                    MusicPlayerManager.getInstance(requireContext()).play(songs.get(randomIndex));
                }
            });
        });

        observeData();

        if (getArguments() != null) {
            String playlistId = getArguments().getString("playlist_id", "");
            String playlistName = getArguments().getString("playlist_name", "");
            titleText.setText(playlistName);
            viewModel.loadPlaylistSongs(playlistId);
        }

        songAdapter.setShowRemoveButton(true);
        songAdapter.setOnRemoveFromPlaylistListener((song, position) -> {
            if (getArguments() != null) {
                String playlistId = getArguments().getString("playlist_id", "");
                viewModel.deleteSongFromPlaylist(playlistId, song.getId());
            }
        });

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
}
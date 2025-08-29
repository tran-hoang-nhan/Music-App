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

import java.util.ArrayList;

public class PlaylistDetailFragment extends Fragment {

    private PlaylistDetailViewModel viewModel;
    private SongAdapter songAdapter;
    private boolean isShuffleEnabled = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_playlist_detail, container, false);

        viewModel = new ViewModelProvider(this).get(PlaylistDetailViewModel.class);

        TextView titleText;
        RecyclerView recyclerView = view.findViewById(R.id.recyclerSongs);

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
            String playlistId = getArguments().getString("playlist_id", "");
            String playlistName = getArguments().getString("playlist_name", "");
            titleText.setText(playlistName);
            viewModel.loadPlaylistSongs(playlistId);
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
}
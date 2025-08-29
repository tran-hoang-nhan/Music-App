package com.example.musicapp.ui.discover;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
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

public class GenreDetailFragment extends Fragment {

    private GenreDetailViewModel viewModel;
    private SongAdapter songAdapter;
    private ProgressBar progressBar;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_genre_detail, container, false);

        viewModel = new ViewModelProvider(this).get(GenreDetailViewModel.class);

        TextView titleText = view.findViewById(R.id.textGenreTitle);
        progressBar = view.findViewById(R.id.progressBar);
        RecyclerView recyclerView = view.findViewById(R.id.recyclerSongs);

        songAdapter = new SongAdapter(getContext(), new ArrayList<>());
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setAdapter(songAdapter);

        // Mini player click
        if (getActivity() != null) {
            View miniPlayer = getActivity().findViewById(R.id.playerView);
            if (miniPlayer != null) {
                miniPlayer.setOnClickListener(v -> {
                    if (getActivity() != null) {
                        NavController navController = Navigation.findNavController(
                                getActivity(),
                                R.id.nav_host_fragment_activity_main
                        );
                        navController.navigate(R.id.navigation_music_player);
                    }
                });
            }
        }

        songAdapter.setOnItemClickListener((song, position) -> {
            MusicPlayerManager.getInstance(requireContext()).play(song);
            songAdapter.setSelectedPosition(position);
        });

        songAdapter.setOnArtistClickListener(artistName -> {
            if (getActivity() != null) {
                Bundle bundle = new Bundle();
                bundle.putString("artist_name", artistName);

                NavController navController = Navigation.findNavController(
                        getActivity(),
                        R.id.nav_host_fragment_activity_main
                );
                navController.navigate(R.id.navigation_artist_detail, bundle);
            }
        });

        observeData();

        if (getArguments() != null) {
            String genreName = getArguments().getString("genre_name", "");
            titleText.setText(genreName + " Music");
            viewModel.loadSongsByGenre(genreName);
        }

        return view;
    }

    private void observeData() {
        viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> songAdapter.updateSongs(songs));
        viewModel.isLoading().observe(getViewLifecycleOwner(), loading -> 
            progressBar.setVisibility(loading ? View.VISIBLE : View.GONE));
    }
}
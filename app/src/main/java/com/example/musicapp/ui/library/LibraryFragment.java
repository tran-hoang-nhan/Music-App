package com.example.musicapp.ui.library;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.PlaylistAdapter;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;

public class LibraryFragment extends Fragment {

    private LibraryViewModel viewModel;
    private PlaylistAdapter playlistAdapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_library, container, false);

        viewModel = new ViewModelProvider(this).get(LibraryViewModel.class);

        RecyclerView recyclerPlaylists = view.findViewById(R.id.recyclerPlaylists);
        FloatingActionButton fabCreatePlaylist = view.findViewById(R.id.fabCreatePlaylist);

        playlistAdapter = new PlaylistAdapter(getContext(), new ArrayList<>());
        recyclerPlaylists.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerPlaylists.setAdapter(playlistAdapter);

        playlistAdapter.setOnUserPlaylistClickListener(playlist -> {
            // Set as current playing playlist
            playlistAdapter.setCurrentPlayingPlaylist(playlist.getId());
            
            Bundle bundle = new Bundle();
            bundle.putString("playlist_id", playlist.getId());
            bundle.putString("playlist_name", playlist.getName());
            
            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_user_playlist_detail, bundle);
        });

        fabCreatePlaylist.setOnClickListener(v -> showCreatePlaylistDialog());

        observeData();
        viewModel.testFirebaseConnection();
        viewModel.loadUserPlaylists();

        return view;
    }

    private void observeData() {
        viewModel.getPlaylists().observe(getViewLifecycleOwner(), playlists -> 
            playlistAdapter.updatePlaylists(playlists));
        
        viewModel.getError().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                Toast.makeText(getContext(), error, Toast.LENGTH_LONG).show();
                android.util.Log.e("LibraryFragment", "Error: " + error);
            }
        });
    }

    private void showCreatePlaylistDialog() {
        CreatePlaylistDialog dialog = new CreatePlaylistDialog();
        dialog.setOnPlaylistCreatedListener(playlistName -> 
            viewModel.createPlaylist(playlistName));
        dialog.show(getParentFragmentManager(), "CreatePlaylistDialog");
    }
}
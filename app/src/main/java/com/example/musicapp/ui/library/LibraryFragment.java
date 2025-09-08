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
import com.example.musicapp.storage.FavoritesManager;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.utils.AnimationHelper;
import androidx.cardview.widget.CardView;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

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
        CardView cardFavorites = view.findViewById(R.id.cardFavorites);
        TextView txtFavoritesCount = view.findViewById(R.id.txtFavoritesCount);
        ImageButton btnPlayFavorites = view.findViewById(R.id.btnPlayFavorites);
        ImageButton btnShuffleFavorites = view.findViewById(R.id.btnShuffleFavorites);

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
        
        // Handle favorites playlist click
        cardFavorites.setOnClickListener(v -> {
            AnimationHelper.scaleIn(requireContext(), v);
            v.postDelayed(() -> {
                NavController navController = Navigation.findNavController(
                        requireActivity(),
                        R.id.nav_host_fragment_activity_main
                );
                navController.navigate(R.id.navigation_favorites_playlist);
            }, 200);
        });
        
        // Handle play favorites button
        btnPlayFavorites.setOnClickListener(v -> {
            AnimationHelper.animateButton(requireContext(), v, () -> playFavorites(false));
        });
        
        // Handle shuffle favorites button
        btnShuffleFavorites.setOnClickListener(v -> {
            AnimationHelper.animateButton(requireContext(), v, () -> playFavorites(true));
        });
        
        // Update favorites count
        updateFavoritesCount(txtFavoritesCount);

        observeData();
        viewModel.testFirebaseConnection();
        viewModel.loadUserPlaylists();
        
        // Add entrance animations
        AnimationHelper.slideUp(requireContext(), cardFavorites);
        AnimationHelper.slideUp(requireContext(), recyclerPlaylists);

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
    
    private void updateFavoritesCount(TextView txtFavoritesCount) {
        FavoritesManager favoritesManager = FavoritesManager.getInstance(requireContext());
        favoritesManager.loadFavoritesWithCallback(() -> {
            int count = favoritesManager.getFavoritesCount();
            if (getActivity() != null) {
                getActivity().runOnUiThread(() -> {
                    txtFavoritesCount.setText(count + " bài hát");
                });
            }
        });
    }
    
    @Override
    public void onResume() {
        super.onResume();
        // Update favorites count when returning to fragment
        TextView txtFavoritesCount = getView() != null ? getView().findViewById(R.id.txtFavoritesCount) : null;
        if (txtFavoritesCount != null) {
            updateFavoritesCount(txtFavoritesCount);
        }
    }
    
    private void playFavorites(boolean shuffle) {
        FavoritesManager favoritesManager = FavoritesManager.getInstance(requireContext());
        favoritesManager.loadFavoritesWithCallback(() -> {
            if (favoritesManager.getFavoritesCount() == 0) {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        Toast.makeText(getContext(), "Chưa có bài hát yêu thích nào", Toast.LENGTH_SHORT).show();
                    });
                }
                return;
            }
            
            MusicPlayerManager playerManager = MusicPlayerManager.getInstance(requireContext());
            if (shuffle) {
                playerManager.toggleShuffle(); // Enable shuffle
            }
            playerManager.setPlaylist(favoritesManager.getFavorites(), 0);
            
            if (getActivity() != null) {
                getActivity().runOnUiThread(() -> {
                    String message = shuffle ? "Phát ngẫu nhiên bài hát yêu thích" : "Phát danh sách yêu thích";
                    Toast.makeText(getContext(), message, Toast.LENGTH_SHORT).show();
                });
            }
        });
    }
}
package com.example.musicapp.ui.dashboard;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.example.musicapp.R;
import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.storage.FavoritesManager;
import com.example.musicapp.utils.NetworkUtils;
import com.example.musicapp.utils.PerformanceOptimizer;
import com.example.musicapp.recommendation.MusicRecommendationEngine;
import com.example.musicapp.personalization.PersonalizationManager;
import com.google.android.material.snackbar.Snackbar;
import com.example.musicapp.model.ArtistAdapter;
import com.example.musicapp.model.PlaylistAdapter;
import com.example.musicapp.model.RandomAdapter;
import com.example.musicapp.model.TopHitsAdapter;

import java.util.ArrayList;

public class DashboardFragment extends Fragment {

    private SwipeRefreshLayout swipeRefreshLayout;
    private NetworkUtils networkUtils;
    private DashboardViewModel dashboardViewModel;
    private MusicRecommendationEngine recommendationEngine;
    private PersonalizationManager personalizationManager;
    private PerformanceOptimizer performanceOptimizer;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_dashboard, container, false);

        // Khởi tạo ViewModel và các managers
        dashboardViewModel = new ViewModelProvider(this).get(DashboardViewModel.class);
        
        // Initialize Repository for ViewModel
        AppDatabase database = AppDatabase.getDatabase(requireContext());
        dashboardViewModel.initRepository(database);
        
        // Listen for favorites changes to refresh UI
        FavoritesManager.getInstance(requireContext()).setOnFavoritesChangeListener(new FavoritesManager.OnFavoritesChangeListener() {
            @Override
            public void onFavoritesLoaded(java.util.List<com.example.musicapp.model.Song> favorites) {
                // Refresh adapters when favorites loaded
                refreshAdapters();
            }

            @Override
            public void onFavoriteAdded(com.example.musicapp.model.Song song) {
                refreshAdapters();
            }

            @Override
            public void onFavoriteRemoved(com.example.musicapp.model.Song song) {
                refreshAdapters();
            }
        });
        
        networkUtils = NetworkUtils.getInstance(requireContext());
        recommendationEngine = MusicRecommendationEngine.getInstance(requireContext());
        personalizationManager = PersonalizationManager.getInstance(requireContext());
        performanceOptimizer = PerformanceOptimizer.getInstance(requireContext());
        
        // SwipeRefreshLayout
        swipeRefreshLayout = root.findViewById(R.id.swipeRefreshLayout);
        swipeRefreshLayout.setOnRefreshListener(this::refreshData);
        swipeRefreshLayout.setColorSchemeResources(
            android.R.color.holo_blue_bright,
            android.R.color.holo_green_light,
            android.R.color.holo_orange_light,
            android.R.color.holo_red_light
        );

        // Ánh xạ RecyclerView
        RecyclerView rvTopHits = root.findViewById(R.id.rvTopHits);
        RecyclerView rvArtists = root.findViewById(R.id.rvArtists);
        RecyclerView rvPlaylists = root.findViewById(R.id.rvPlaylists);
        RecyclerView rvSuggestions = root.findViewById(R.id.rvSuggestions);

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

        // LayoutManager (scroll ngang)
        rvTopHits.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        rvArtists.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvPlaylists.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvSuggestions.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));

        // Tạo Adapter
        TopHitsAdapter topHitsAdapter = new TopHitsAdapter(getContext(), new ArrayList<>());
        ArtistAdapter artistAdapter = new ArtistAdapter(getContext(), new ArrayList<>());
        PlaylistAdapter playlistAdapter = new PlaylistAdapter(getContext(), new ArrayList<>());
        RandomAdapter randomAdapter = new RandomAdapter(getContext(), new ArrayList<>());

        // Gắn Adapter
        rvTopHits.setAdapter(topHitsAdapter);
        rvArtists.setAdapter(artistAdapter);
        rvPlaylists.setAdapter(playlistAdapter);
        rvSuggestions.setAdapter(randomAdapter);

        // SnapHelper
        new PagerSnapHelper().attachToRecyclerView(rvSuggestions);

        // Quan sát LiveData
        dashboardViewModel.getTopHits().observe(getViewLifecycleOwner(), topHitsAdapter::updateTopHits);
        dashboardViewModel.getRandomTracks().observe(getViewLifecycleOwner(), songs -> {
            // Apply recommendations to random tracks
            if (songs != null && !songs.isEmpty()) {
                performanceOptimizer.executeInBackground(() -> {
                    java.util.List<com.example.musicapp.model.Song> recommendations = 
                        recommendationEngine.getPersonalizedRecommendations(songs, 10);
                    performanceOptimizer.executeOnMainThread(() -> 
                        randomAdapter.updateRandom(recommendations));
                });
            }
        });
        dashboardViewModel.getPlaylists().observe(getViewLifecycleOwner(), playlistAdapter::updatePlaylists);
        dashboardViewModel.getTopArtists().observe(getViewLifecycleOwner(), artistAdapter::updateArtists);

        // Observe network status
        networkUtils.getNetworkStatus().observe(getViewLifecycleOwner(), isConnected -> {
            if (!isConnected) {
                Snackbar.make(root, "Không có kết nối mạng", Snackbar.LENGTH_LONG)
                    .setAction("Thử lại", v -> refreshData())
                    .show();
            }
        });
        
        // Observe loading state
        dashboardViewModel.isLoading().observe(getViewLifecycleOwner(), isLoading -> swipeRefreshLayout.setRefreshing(isLoading));
        
        // Load API
        refreshData();

        // Sự kiện click với personalization tracking
        topHitsAdapter.setOnItemClickListener((song, position) -> {
            if (getActivity() instanceof com.example.musicapp.MainActivity) {
                ((com.example.musicapp.MainActivity) getActivity()).playSong(song);
                // Track user interaction for recommendations
                recommendationEngine.updateUserPreferences(song, "play");
                personalizationManager.updateGenrePreference(song.getArtistName(), 1);
            }
        });

        randomAdapter.setOnItemClickListener((song, position) -> {
            if (getActivity() instanceof com.example.musicapp.MainActivity) {
                ((com.example.musicapp.MainActivity) getActivity()).playSong(song);
                // Track user interaction for recommendations
                recommendationEngine.updateUserPreferences(song, "play");
                personalizationManager.updateGenrePreference(song.getArtistName(), 1);
            }
            randomAdapter.setSelectedPosition(position);
        });
        
        randomAdapter.setOnFavoriteClickListener((song, isFavorite) -> {
            // Track favorite action for recommendations
            if (isFavorite) {
                recommendationEngine.updateUserPreferences(song, "play");
                personalizationManager.updateGenrePreference(song.getArtistName(), 5);
            }
        });

        artistAdapter.setOnItemClickListener(artist -> {
            Bundle bundle = new Bundle();
            bundle.putString("artist_name", artist.getName());
            bundle.putString("artist_image", artist.getImage());

            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_artist_detail, bundle);
        });

        playlistAdapter.setOnItemClickListener(playlist -> {
            Bundle bundle = new Bundle();
            bundle.putString("playlist_id", playlist.getId());
            bundle.putString("playlist_name", playlist.getName());
            
            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_playlist_detail, bundle);
        });

        return root;
    }
    
    private void refreshAdapters() {
        if (getActivity() != null && getView() != null && isAdded()) {
            getActivity().runOnUiThread(() -> {
                // Check if view still exists
                if (getView() == null || !isAdded()) return;
                
                // Find and refresh all adapters with specific item changes
                RecyclerView rvTopHits = getView().findViewById(R.id.rvTopHits);
                RecyclerView rvSuggestions = getView().findViewById(R.id.rvSuggestions);
                
                if (rvTopHits != null && rvTopHits.getAdapter() != null) {
                    int itemCount = rvTopHits.getAdapter().getItemCount();
                    if (itemCount > 0) {
                        rvTopHits.getAdapter().notifyItemRangeChanged(0, itemCount);
                    }
                }
                if (rvSuggestions != null && rvSuggestions.getAdapter() != null) {
                    int itemCount = rvSuggestions.getAdapter().getItemCount();
                    if (itemCount > 0) {
                        rvSuggestions.getAdapter().notifyItemRangeChanged(0, itemCount);
                    }
                }
            });
        }
    }
    
    private void refreshData() {
        if (networkUtils.isNetworkAvailable()) {
            dashboardViewModel.fetchAll();
        } else {
            swipeRefreshLayout.setRefreshing(false);
            Snackbar.make(requireView(), "Không có kết nối mạng", Snackbar.LENGTH_SHORT).show();
        }
    }
}

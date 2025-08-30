package com.example.musicapp.ui.search;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SnapHelper;

import com.example.musicapp.R;
import com.example.musicapp.model.AlbumAdapter;
import com.example.musicapp.model.SongAdapter;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.ArrayList;

public class SearchFragment extends Fragment {

    private SearchViewModel viewModel;
    private SongAdapter songAdapter;
    private AlbumAdapter albumAdapter;
    private ProgressBar progressBar;
    private EditText searchInput;
    private Handler searchHandler = new Handler(Looper.getMainLooper());
    private Runnable searchRunnable;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_search, container, false);        searchInput = view.findViewById(R.id.edtSearch);

        viewModel = new ViewModelProvider(this).get(SearchViewModel.class);

        progressBar = view.findViewById(R.id.progressBar);
        RecyclerView songRecycler = view.findViewById(R.id.recyclerSongs);
        RecyclerView albumRecycler = view.findViewById(R.id.recyclerAlbums);

        // Khởi tạo adapter
        songAdapter = new SongAdapter(getContext(), new ArrayList<>());
        albumAdapter = new AlbumAdapter(getContext(), new ArrayList<>());

        songRecycler.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        albumRecycler.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));

        songRecycler.setAdapter(songAdapter);
        albumRecycler.setAdapter(albumAdapter);

        SnapHelper snapHelperSongs = new PagerSnapHelper();
        snapHelperSongs.attachToRecyclerView(songRecycler);

        SnapHelper snapHelperAlbums = new PagerSnapHelper();
        snapHelperAlbums.attachToRecyclerView(albumRecycler);

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

        // Click listeners
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

        albumAdapter.setOnItemClickListener(album -> {
            Bundle bundle = new Bundle();
            bundle.putString("album_id", album.getId());
            bundle.putString("album_name", album.getName());
            bundle.putString("album_image", album.getImage());
            bundle.putString("artist_name", album.getArtistName());

            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_album_detail, bundle);
        });

        // Khởi tạo ViewModel


        // Realtime search with debounce
        searchInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (searchRunnable != null) {
                    searchHandler.removeCallbacks(searchRunnable);
                }
                
                searchRunnable = () -> {
                    String query = s.toString().trim();
                    if (!TextUtils.isEmpty(query) && query.length() >= 2) {
                        viewModel.searchAll(query);
                    } else if (query.isEmpty()) {
                        // Clear results when search is empty
                        songAdapter.updateSongs(new ArrayList<>());
                        albumAdapter.updateAlbums(new ArrayList<>());
                    }
                };
                
                // Debounce: wait 500ms after user stops typing
                searchHandler.postDelayed(searchRunnable, 500);
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        // Keep Enter key functionality
        searchInput.setOnEditorActionListener((TextView v, int actionId, KeyEvent event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH ||
                    (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER && event.getAction() == KeyEvent.ACTION_DOWN)) {

                String query = searchInput.getText().toString().trim();
                if (!TextUtils.isEmpty(query)) {
                    viewModel.searchAll(query);
                }
                return true;
            }
            return false;
        });

        // Nếu được truyền query từ argument
        if (getArguments() != null) {
            String query = getArguments().getString("query", "");
            if (!query.isEmpty()) {
                searchInput.setText(query);
                viewModel.searchAll(query);
            }
        }

        observeData();

        return view;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (searchHandler != null && searchRunnable != null) {
            searchHandler.removeCallbacks(searchRunnable);
        }
    }



    private void observeData() {
        // Observe LiveData
        viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> songAdapter.updateSongs(songs));
        viewModel.getAlbums().observe(getViewLifecycleOwner(), albums -> albumAdapter.updateAlbums(albums));
        viewModel.isLoading().observe(getViewLifecycleOwner(), loading -> progressBar.setVisibility(loading ? View.VISIBLE : View.GONE));
    }
}

package com.example.musicapp.ui.search;

import android.os.Bundle;
import android.text.TextUtils;
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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SnapHelper;

import com.example.musicapp.R;
import com.example.musicapp.model.AlbumAdapter;
import com.example.musicapp.model.SongAdapter;

import java.util.ArrayList;

public class SearchFragment extends Fragment {

    private SearchViewModel viewModel;
    private SongAdapter songAdapter;
    private AlbumAdapter albumAdapter;
    private ProgressBar progressBar;
    private EditText searchInput;

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

        songRecycler.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        albumRecycler.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));

        songRecycler.setAdapter(songAdapter);
        albumRecycler.setAdapter(albumAdapter);

        SnapHelper snapHelperSongs = new PagerSnapHelper();
        snapHelperSongs.attachToRecyclerView(songRecycler);

        SnapHelper snapHelperAlbums = new PagerSnapHelper();
        snapHelperAlbums.attachToRecyclerView(albumRecycler);

        // Khởi tạo ViewModel


        // Xử lý search khi nhấn Enter
        searchInput.setOnEditorActionListener((TextView v, int actionId, KeyEvent event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH ||
                    (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER && event.getAction() == KeyEvent.ACTION_DOWN)) {

                String query = searchInput.getText().toString().trim();
                if (!TextUtils.isEmpty(query)) {
                    viewModel.searchAll(query); // dùng searchAll thay vì search
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



    private void observeData() {
        // Observe LiveData
        viewModel.getSongs().observe(getViewLifecycleOwner(), songs -> songAdapter.updateSongs(songs));
        viewModel.getAlbums().observe(getViewLifecycleOwner(), albums -> albumAdapter.updateAlbums(albums));
        viewModel.isLoading().observe(getViewLifecycleOwner(), loading -> progressBar.setVisibility(loading ? View.VISIBLE : View.GONE));
    }
}

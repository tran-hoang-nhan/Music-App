package com.example.musicapp.ui.dashboard;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.player.MusicPlayerManager;
import com.example.musicapp.model.AlbumAdapter;
import com.example.musicapp.model.ArtistAdapter;
import com.example.musicapp.model.RandomAdapter;
import com.example.musicapp.model.SongAdapter;

import java.util.ArrayList;

public class DashboardFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_dashboard, container, false);

        // Khởi tạo ViewModel
        DashboardViewModel dashboardViewModel = new ViewModelProvider(this).get(DashboardViewModel.class);

        // Ánh xạ RecyclerView
        RecyclerView rvTopHits = root.findViewById(R.id.rvTopHits);
        RecyclerView rvArtists = root.findViewById(R.id.rvArtists);
        RecyclerView rvNewAlbums = root.findViewById(R.id.rvNewAlbums);
        RecyclerView rvSuggestions = root.findViewById(R.id.rvSuggestions);

        // Thiết lập LayoutManager cho từng RecyclerView (scroll ngang)
        rvTopHits.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvArtists.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvNewAlbums.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvSuggestions.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));

        // Tạo Adapter
        SongAdapter songAdapter = new SongAdapter(getContext(), new ArrayList<>());
        ArtistAdapter artistAdapter = new ArtistAdapter(getContext(), new ArrayList<>());
        AlbumAdapter albumAdapter = new AlbumAdapter(getContext(), new ArrayList<>());
        RandomAdapter randomAdapter = new RandomAdapter(getContext(), new ArrayList<>());

        // Gắn Adapter
        rvTopHits.setAdapter(songAdapter);
        rvArtists.setAdapter(artistAdapter);
        rvNewAlbums.setAdapter(albumAdapter);
        rvSuggestions.setAdapter(randomAdapter);

        // Quan sát LiveData từ ViewModel
        dashboardViewModel.getTopHits().observe(getViewLifecycleOwner(), songAdapter::updateSongs);

        dashboardViewModel.getRandomTracks().observe(getViewLifecycleOwner(), randomAdapter::updateRandom);

        dashboardViewModel.getNewAlbums().observe(getViewLifecycleOwner(), albumAdapter::updateAlbums);

        dashboardViewModel.getTopArtists().observe(getViewLifecycleOwner(), artistAdapter::updateArtists);

        // Gọi fetchAll() để load dữ liệu từ API
        dashboardViewModel.fetchAll();

        songAdapter.setOnItemClickListener(song -> {
            // Gọi hàm play() của MusicPlayerManager
            MusicPlayerManager.getInstance(requireContext()).play(song);
        });

        randomAdapter.setOnItemClickListener(song -> {
            MusicPlayerManager.getInstance(requireContext()).play(song);
        });

        return root;
    }
}

package com.example.musicapp.ui.album;


import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.model.TrackAdapter;

public class AlbumFragment extends Fragment {
    private static final String ARG_ALBUM_ID = "id";

    private AlbumViewModel viewModel;
    private TrackAdapter adapter;

    // UI
    private TextView tvAlbumName, tvAlbumArtist, tvAlbumReleaseDate, tvAlbumGenre;
    private ImageView ivAlbumCover;

    private String albumId;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            albumId = getArguments().getString(ARG_ALBUM_ID);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_album_detail, container, false);

        // bind UI
        tvAlbumName = view.findViewById(R.id.album_title);
        tvAlbumArtist = view.findViewById(R.id.artist_name);
        tvAlbumReleaseDate = view.findViewById(R.id.release_date);
        tvAlbumGenre = view.findViewById(R.id.genre);
        ivAlbumCover = view.findViewById(R.id.image_cover);

        RecyclerView recyclerView = view.findViewById(R.id.recycler_playlist_album);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new TrackAdapter();
        recyclerView.setAdapter(adapter);

        // init ViewModel
        viewModel = new ViewModelProvider(this).get(AlbumViewModel.class);

        observeViewModel();

        if (albumId != null) {
            viewModel.loadAlbum(albumId);
        }

        return view;
    }

    private void observeViewModel() {
        viewModel.getAlbum().observe(getViewLifecycleOwner(), album -> {
            if (album != null) {
                tvAlbumName.setText(album.getName());
                tvAlbumArtist.setText(album.getArtistName());
                tvAlbumReleaseDate.setText(album.getReleaseDate());
                tvAlbumGenre.setText(album.getGenre());

                Glide.with(this)
                        .load(album.getImage())
                        .placeholder(R.drawable.placeholder)
                        .into(ivAlbumCover);
            }
        });

        viewModel.getTracks().observe(getViewLifecycleOwner(), songs -> {
            if (songs != null) {
                adapter.setTracks(songs);
                adapter.notifyDataSetChanged();
            }
        });
    }
}


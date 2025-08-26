package com.example.musicapp.ui.artist;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.model.AlbumAdapter;
import com.example.musicapp.model.SongAdapter;
import com.google.android.material.button.MaterialButton;


public class ArtistFragment extends Fragment {
    private static final String ARG_ARTIST_NAME = "artist_name";
    private static final String ARG_ARTIST_IMAGE = "artist_image";

    private String artistName;
    private String artistImage;

    private RecyclerView recyclerTopSongs;
    private RecyclerView recyclerAlbums;

    private SongAdapter topSongsAdapter;
    private AlbumAdapter albumsAdapter;
    private MaterialButton btnShowMore;

    private ArtistViewModel viewModel;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            artistName = getArguments().getString(ARG_ARTIST_NAME);
            artistImage = getArguments().getString(ARG_ARTIST_IMAGE);
        }
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_artist_detail, container, false);
        ImageView artistCoverImage = view.findViewById(R.id.artist_cover_image);
        TextView artistNameText = view.findViewById(R.id.artist_name_text);

        recyclerTopSongs = view.findViewById(R.id.recyclerTopSongs);
        recyclerAlbums = view.findViewById(R.id.recyclerAlbums);
        btnShowMore = view.findViewById(R.id.btnLoadMoreTopSongs);

        recyclerTopSongs.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerAlbums.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));

        // set info
        artistNameText.setText(artistName);
        Glide.with(requireContext())
                .load(artistImage)
                .placeholder(R.drawable.placeholder)
                .into(artistCoverImage);

        // init ViewModel
        viewModel = new ViewModelProvider(this).get(ArtistViewModel.class);

        observeViewModel();

        if (artistName != null) {
            viewModel.loadArtistData(artistName);
        }

        return view;
    }

    private void observeViewModel() {
        // top songs
        viewModel.getTopSongs().observe(getViewLifecycleOwner(), songs -> {
            if (songs != null) {
                topSongsAdapter = new SongAdapter(getContext(), songs);
                recyclerTopSongs.setAdapter(topSongsAdapter);

                if (songs.size() > 5) {
                    btnShowMore.setVisibility(View.VISIBLE);
                } else {
                    btnShowMore.setVisibility(View.GONE);
                }

                btnShowMore.setOnClickListener(v -> {
                    if (topSongsAdapter.isExpanded()) {
                        topSongsAdapter.collapse();
                        btnShowMore.setIconResource(R.drawable.ic_expand_less);
                    } else {
                        topSongsAdapter.showMore();
                        btnShowMore.setIconResource(R.drawable.ic_expand_more);
                    }
                    btnShowMore.animate()
                            .rotationBy(180f)
                            .setDuration(300)
                            .start();
                });
            }
        });

        // albums
        viewModel.getAlbums().observe(getViewLifecycleOwner(), albums -> {
            if (albums != null) {
                albumsAdapter = new AlbumAdapter(getContext(), albums);
                recyclerAlbums.setAdapter(albumsAdapter);
            }
        });
    }
}


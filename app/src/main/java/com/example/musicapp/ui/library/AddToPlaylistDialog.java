package com.example.musicapp.ui.library;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.fragment.app.DialogFragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.Playlist;

import com.example.musicapp.model.PlaylistAdapter;
import com.example.musicapp.model.Song;

import java.util.ArrayList;

public class AddToPlaylistDialog extends DialogFragment {

    public interface OnPlaylistSelectedListener {
        void onPlaylistSelected(Playlist playlist);
    }

    private OnPlaylistSelectedListener listener;
    private Song song;
    private LibraryViewModel viewModel;
    private PlaylistAdapter adapter;

    public void setSong(Song song) {
        this.song = song;
    }

    public void setOnPlaylistSelectedListener(OnPlaylistSelectedListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.dialog_add_to_playlist, null);
        
        viewModel = new ViewModelProvider(this).get(LibraryViewModel.class);
        
        RecyclerView recyclerView = view.findViewById(R.id.recyclerPlaylists);
        adapter = new PlaylistAdapter(getContext(), new ArrayList<>(), true);
        
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerView.setAdapter(adapter);

        adapter.setOnUserPlaylistClickListener(playlist -> {
            if (listener != null) {
                listener.onPlaylistSelected(playlist);
            }
            dismiss();
        });

        viewModel.getPlaylists().observe(this, playlists -> adapter.updatePlaylists(playlists));
        viewModel.loadUserPlaylists();

        return new AlertDialog.Builder(getContext())
                .setTitle("Add to Playlist")
                .setView(view)
                .setNegativeButton("Cancel", null)
                .create();
    }
}
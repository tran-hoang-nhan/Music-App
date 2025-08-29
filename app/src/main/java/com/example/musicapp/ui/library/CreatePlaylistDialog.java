package com.example.musicapp.ui.library;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.fragment.app.DialogFragment;

public class CreatePlaylistDialog extends DialogFragment {

    public interface OnPlaylistCreatedListener {
        void onPlaylistCreated(String playlistName);
    }

    private OnPlaylistCreatedListener listener;

    public void setOnPlaylistCreatedListener(OnPlaylistCreatedListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        EditText editText = new EditText(getContext());
        editText.setHint("Playlist name");

        return new AlertDialog.Builder(getContext())
                .setTitle("Create Playlist")
                .setView(editText)
                .setPositiveButton("Create", (dialog, which) -> {
                    String name = editText.getText().toString().trim();
                    if (!name.isEmpty() && listener != null) {
                        listener.onPlaylistCreated(name);
                    }
                })
                .setNegativeButton("Cancel", null)
                .create();
    }
}
package com.example.musicapp.model;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.ArrayList;
import java.util.List;

public class TrackAdapter extends RecyclerView.Adapter<TrackAdapter.ViewHolder> {

    private AlbumResponse.Album album;
    private List<Song> trackList = new ArrayList<>();

    public void setAlbum(AlbumResponse.Album album) {
        this.album = album;
        notifyDataSetChanged();
    }

    public void setTracks(List<Song> tracks) {
        trackList.clear();
        if (tracks != null) trackList.addAll(tracks);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_playlist, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Song track = trackList.get(position);
        holder.tvTrackNumber.setText(String.valueOf(position + 1));
        holder.tvSongTitle.setText(track.getName());
        holder.tvSongArtist.setText(track.getArtistName());
        holder.txDuration.setText(formatDuration(track.getDuration()));

        if (album != null) {
            Glide.with(holder.itemView.getContext())
                    .load(album.getImage())
                    .placeholder(R.drawable.placeholder)
                    .into(holder.ivCover);
        }

        holder.btnPlay.setOnClickListener(v -> {
            MusicPlayerManager.getInstance(holder.itemView.getContext()).play(track);
        });
    }

    @SuppressLint("DefaultLocale")
    private String formatDuration(int seconds) {
        int minutes = seconds / 60;
        int sec = seconds % 60;
        return String.format("%d:%02d", minutes, sec);
    }

    @Override
    public int getItemCount() {
        return trackList.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvTrackNumber, tvSongTitle, tvSongArtist, txDuration;
        ImageView ivCover;
        ImageButton btnPlay;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTrackNumber = itemView.findViewById(R.id.tvTrackNumber);
            tvSongTitle = itemView.findViewById(R.id.tvSongTitle);
            tvSongArtist = itemView.findViewById(R.id.tvSongArtist);
            txDuration = itemView.findViewById(R.id.textDuration);
            ivCover = itemView.findViewById(R.id.imgAlbumCover);
            btnPlay = itemView.findViewById(R.id.btnPlay);
        }
    }
}

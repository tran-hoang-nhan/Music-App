// PlaylistAdapter.java
package com.example.musicapp.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.musicapp.R;

import java.util.List;

public class PlaylistAdapter extends RecyclerView.Adapter<PlaylistAdapter.PlaylistViewHolder> {

    private final Context context;
    private List<PlaylistResponse.Playlist> playlists;
    private OnItemClickListener listener;

    public interface OnItemClickListener {
        void onItemClick(PlaylistResponse.Playlist playlist);
    }

    public PlaylistAdapter(Context context, List<PlaylistResponse.Playlist> playlists) {
        this.context = context;
        this.playlists = playlists;
    }

    public void updatePlaylists(List<PlaylistResponse.Playlist> newPlaylists) {
        this.playlists = newPlaylists;
        notifyDataSetChanged();
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public PlaylistViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_playlist_default, parent, false);
        return new PlaylistViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PlaylistViewHolder holder, int position) {
        PlaylistResponse.Playlist playlist = playlists.get(position);
        holder.name.setText(playlist.getName());
        Glide.with(context).load(playlist.getImage()).into(holder.image);

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onItemClick(playlist);
        });
    }

    @Override
    public int getItemCount() {
        return playlists.size();
    }

    static class PlaylistViewHolder extends RecyclerView.ViewHolder {
        TextView name;
        ImageView image;

        public PlaylistViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.playlist_name);
            image = itemView.findViewById(R.id.playlist_image);
        }
    }
}

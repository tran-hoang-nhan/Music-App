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

import java.util.ArrayList;
import java.util.List;

public class SongAdapter extends RecyclerView.Adapter<SongAdapter.ViewHolder> {

    private final Context context;
    private final List<Song> songList;
    private OnItemClickListener listener;

    public SongAdapter(Context context, List<Song> songList) {
        this.context = context;
        this.songList = songList != null ? songList : new ArrayList<>();
    }
    public interface OnItemClickListener {
        void onItemClick(Song song);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_song, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Song song = songList.get(position);
        holder.tvTitle.setText(song.getName());
        holder.tvArtist.setText(song.getArtistName());
        Glide.with(context).load(song.getImageUrl()).into(holder.ivCover);
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onItemClick(song);
            }
        });
    }

    @Override
    public int getItemCount() {
        return songList.size();
    }

    // --- Phương thức update dữ liệu ---
    public void updateSongs(List<Song> newSongs) {
        songList.clear();
        if (newSongs != null) {
            songList.addAll(newSongs);
        }
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCover;
        TextView tvTitle, tvArtist;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCover = itemView.findViewById(R.id.imageCover);
            tvTitle = itemView.findViewById(R.id.textTitle);
            tvArtist = itemView.findViewById(R.id.textArtist);
        }
    }
}

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

public class TopHitsAdapter extends RecyclerView.Adapter<TopHitsAdapter.ViewHolder> {

    private Context context;
    private List<Song> topHitsList;

    public TopHitsAdapter(Context context, List<Song> topHitsList) {
        this.context = context;
        this.topHitsList = topHitsList;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_song, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Song song = topHitsList.get(position);
        holder.tvTitle.setText(song.getName());
        holder.tvArtist.setText(song.getArtistName());
        Glide.with(context).load(song.getImageUrl()).into(holder.ivCover);
    }

    @Override
    public int getItemCount() {
        return topHitsList != null ? topHitsList.size() : 0;
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

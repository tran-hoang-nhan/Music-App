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
    private OnItemClickListener listener;

    public TopHitsAdapter(Context context, List<Song> topHitsList) {
        this.context = context;
        this.topHitsList = topHitsList;
    }
    
    public interface OnItemClickListener {
        void onItemClick(Song song, int position);
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
        Song song = topHitsList.get(position);
        holder.tvTitle.setText(song.getName());
        holder.tvArtist.setText(song.getArtistName());
        Glide.with(context).load(song.getImageUrl()).into(holder.ivCover);
        
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onItemClick(song, position);
            }
        });
    }

    @Override
    public int getItemCount() {
        return topHitsList != null ? topHitsList.size() : 0;
    }
    
    public void updateTopHits(List<Song> newTopHits) {
        if (topHitsList != null) {
            topHitsList.clear();
            if (newTopHits != null) {
                topHitsList.addAll(newTopHits);
            }
            notifyDataSetChanged();
        }
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

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

public class ArtistAdapter extends RecyclerView.Adapter<ArtistAdapter.ViewHolder> {

    private final Context context;
    private final List<ArtistResponse.Artist> artistList;

    public ArtistAdapter(Context context, List<ArtistResponse.Artist> artistList) {
        this.context = context;
        this.artistList = artistList != null ? artistList : new ArrayList<>();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_artist, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ArtistResponse.Artist artist = artistList.get(position);
        holder.tvName.setText(artist.getName());
        Glide.with(context)
                .load(artist.getImage())
                .placeholder(R.drawable.circle_shape)
                .error(R.drawable.circle_shape)
                .circleCrop()
                .into(holder.ivCover);
    }

    @Override
    public int getItemCount() {
        return artistList.size();
    }

    public void updateArtists(List<ArtistResponse.Artist> newList) {
        artistList.clear();
        if (newList != null) {
            artistList.addAll(newList);
        }
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCover;
        TextView tvName;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCover = itemView.findViewById(R.id.imgArtist);
            tvName = itemView.findViewById(R.id.txtArtist); // dùng textTitle hiển thị artistName
        }
    }
}



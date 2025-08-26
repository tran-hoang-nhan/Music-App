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

public class AlbumAdapter extends RecyclerView.Adapter<AlbumAdapter.ViewHolder> {
    private final Context context;
    private final List<AlbumResponse.Album> albumList;

    public AlbumAdapter(Context context, List<AlbumResponse.Album> albumList) {
        this.context = context;
        this.albumList = albumList != null ? albumList : new ArrayList<>();
    }
    public interface OnAlbumClickListener {
        void onAlbumClick(AlbumResponse.Album album);
    }
    private OnAlbumClickListener albumClickListener;
    public void setOnItemClickListener(OnAlbumClickListener l) { this.albumClickListener = l; }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_album, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        AlbumResponse.Album album = albumList.get(position);
        holder.tvTitle.setText(album.getName());
        holder.tvArtist.setText(album.getArtistName());
        holder.tvReleasedate.setText(album.getReleaseDate());
        Glide.with(context)
                .load(album.getImage())
                .placeholder(R.drawable.placeholder)
                .into(holder.ivCover);

        holder.itemView.setOnClickListener(v -> {
            if (albumClickListener != null) albumClickListener.onAlbumClick(album);
        });
    }


    @Override
    public int getItemCount() {
        return albumList.size();
    }

    public void updateAlbums(List<AlbumResponse.Album> newList) {
        albumList.clear();
        if (newList != null) {
            albumList.addAll(newList);
        }
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivCover;
        TextView tvTitle, tvArtist, tvReleasedate;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivCover = itemView.findViewById(R.id.imgAlbumCover);
            tvTitle = itemView.findViewById(R.id.txtAlbumTitle);
            tvArtist = itemView.findViewById(R.id.txtAlbumArtist);
            tvReleasedate = itemView.findViewById(R.id.txtAlbumReleaseDate);
        }
    }
}


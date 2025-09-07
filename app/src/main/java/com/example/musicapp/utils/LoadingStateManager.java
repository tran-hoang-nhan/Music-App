package com.example.musicapp.utils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

public class LoadingStateManager {
    
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    private final MutableLiveData<String> successMessage = new MutableLiveData<>();
    
    public void setLoading(boolean loading) {
        isLoading.postValue(loading);
    }
    
    public void setError(String error) {
        errorMessage.postValue(error);
        setLoading(false);
    }
    
    public void setSuccess(String message) {
        successMessage.postValue(message);
        setLoading(false);
    }
    
    public void clearMessages() {
        errorMessage.postValue(null);
        successMessage.postValue(null);
    }
    
    public LiveData<Boolean> getLoadingState() {
        return isLoading;
    }
    
    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }
    
    public LiveData<String> getSuccessMessage() {
        return successMessage;
    }
}
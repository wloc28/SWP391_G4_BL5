package Models;

import java.sql.Timestamp;

/**
 * Provider Model
 * Represents the providers table
 */
public class Provider {
    private int providerId;
    private String providerName;
    private String providerType; // 'TEL' or 'GAME'
    private String imageUrl;
    private String status; // 'ACTIVE' or 'INACTIVE'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // Constructors
    public Provider() {
        this.providerType = "TEL";
        this.status = "ACTIVE";
        this.isDeleted = false;
    }
    
    public Provider(String providerName, String providerType) {
        this();
        this.providerName = providerName;
        this.providerType = providerType;
    }
    
    // Getters and Setters
    public int getProviderId() {
        return providerId;
    }
    
    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }
    
    public String getProviderName() {
        return providerName;
    }
    
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }
    
    public String getProviderType() {
        return providerType;
    }
    
    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public boolean isDeleted() {
        return isDeleted;
    }
    
    public void setDeleted(boolean deleted) {
        isDeleted = deleted;
    }
    
    @Override
    public String toString() {
        return "Provider{" +
                "providerId=" + providerId +
                ", providerName='" + providerName + '\'' +
                ", providerType='" + providerType + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}



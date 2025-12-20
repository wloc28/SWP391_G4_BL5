package Models;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Card Model
 * Represents the cards table - Thẻ cụ thể từ nhà cung cấp
 */
public class Card {
    private int cardId;
    private int providerStorageId;
    private String serialNumber;
    private String cardCode;
    private Date expiryDate;
    private String status; // 'PENDING', 'AVAILABLE', 'IMPORTED', 'SOLD', 'ERROR', 'EXPIRED'
    private Timestamp importedAt;
    private int importedBy;
    private String errorMessage;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // Reference
    private ProviderStorage providerStorage;
    
    // Constructors
    public Card() {
        this.status = "PENDING";
        this.isDeleted = false;
    }
    
    public Card(int providerStorageId, String serialNumber, String cardCode) {
        this();
        this.providerStorageId = providerStorageId;
        this.serialNumber = serialNumber;
        this.cardCode = cardCode;
    }
    
    // Getters and Setters
    public int getCardId() {
        return cardId;
    }
    
    public void setCardId(int cardId) {
        this.cardId = cardId;
    }
    
    public int getProviderStorageId() {
        return providerStorageId;
    }
    
    public void setProviderStorageId(int providerStorageId) {
        this.providerStorageId = providerStorageId;
    }
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public String getCardCode() {
        return cardCode;
    }
    
    public void setCardCode(String cardCode) {
        this.cardCode = cardCode;
    }
    
    public Date getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getImportedAt() {
        return importedAt;
    }
    
    public void setImportedAt(Timestamp importedAt) {
        this.importedAt = importedAt;
    }
    
    public int getImportedBy() {
        return importedBy;
    }
    
    public void setImportedBy(int importedBy) {
        this.importedBy = importedBy;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
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
    
    public ProviderStorage getProviderStorage() {
        return providerStorage;
    }
    
    public void setProviderStorage(ProviderStorage providerStorage) {
        this.providerStorage = providerStorage;
    }
    
    @Override
    public String toString() {
        return "Card{" +
                "cardId=" + cardId +
                ", providerStorageId=" + providerStorageId +
                ", serialNumber='" + serialNumber + '\'' +
                ", cardCode='" + cardCode + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}





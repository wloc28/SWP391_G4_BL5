package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * ImportTransaction Model
 * Represents the import_transactions table (lịch sử nhập hàng từ provider)
 */
public class ImportTransaction {
    private int importId;
    private int providerStorageId; // ID của provider_storage
    private int quantity; // Số lượng nhập
    private BigDecimal purchasePrice; // Giá nhập từ provider
    private BigDecimal totalCost; // Tổng chi phí
    private int importedBy; // Admin nhập hàng
    private String note; // Ghi chú
    private Timestamp createdAt;
    private boolean isDeleted;
    
    // References
    private ProviderStorage providerStorage;
    private User importedByUser;
    
    // Constructors
    public ImportTransaction() {
        this.isDeleted = false;
    }
    
    public ImportTransaction(int providerStorageId, int quantity, BigDecimal purchasePrice) {
        this();
        this.providerStorageId = providerStorageId;
        this.quantity = quantity;
        this.purchasePrice = purchasePrice;
        this.totalCost = purchasePrice.multiply(new BigDecimal(quantity));
    }
    
    // Getters and Setters
    public int getImportId() {
        return importId;
    }
    
    public void setImportId(int importId) {
        this.importId = importId;
    }
    
    public int getProviderStorageId() {
        return providerStorageId;
    }
    
    public void setProviderStorageId(int providerStorageId) {
        this.providerStorageId = providerStorageId;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
        // Tự động tính lại totalCost khi quantity thay đổi
        if (purchasePrice != null) {
            this.totalCost = purchasePrice.multiply(new BigDecimal(quantity));
        }
    }
    
    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }
    
    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
        // Tự động tính lại totalCost khi purchasePrice thay đổi
        if (quantity > 0) {
            this.totalCost = purchasePrice.multiply(new BigDecimal(quantity));
        }
    }
    
    public BigDecimal getTotalCost() {
        return totalCost;
    }
    
    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }
    
    public int getImportedBy() {
        return importedBy;
    }
    
    public void setImportedBy(int importedBy) {
        this.importedBy = importedBy;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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
    
    public User getImportedByUser() {
        return importedByUser;
    }
    
    public void setImportedByUser(User importedByUser) {
        this.importedByUser = importedByUser;
    }
    
    @Override
    public String toString() {
        return "ImportTransaction{" +
                "importId=" + importId +
                ", providerStorageId=" + providerStorageId +
                ", quantity=" + quantity +
                ", purchasePrice=" + purchasePrice +
                ", totalCost=" + totalCost +
                ", importedBy=" + importedBy +
                '}';
    }
}



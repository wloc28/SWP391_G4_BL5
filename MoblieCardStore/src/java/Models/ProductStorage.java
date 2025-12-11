package Models;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * ProductStorage Model
 * Represents the product_storage table
 */
public class ProductStorage {
    private int storageId;
    private int productId;
    private String serialNumber;
    private String cardCode;
    private Date expiryDate;
    private String status; // 'AVAILABLE', 'SOLD', or 'ERROR'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // Reference to Product (optional, for convenience)
    private Product product;
    
    // Constructors
    public ProductStorage() {
        this.status = "AVAILABLE";
        this.isDeleted = false;
    }
    
    public ProductStorage(int productId, String serialNumber, String cardCode) {
        this();
        this.productId = productId;
        this.serialNumber = serialNumber;
        this.cardCode = cardCode;
    }
    
    // Getters and Setters
    public int getStorageId() {
        return storageId;
    }
    
    public void setStorageId(int storageId) {
        this.storageId = storageId;
    }
    
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
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
    
    public Product getProduct() {
        return product;
    }
    
    public void setProduct(Product product) {
        this.product = product;
    }
    
    @Override
    public String toString() {
        return "ProductStorage{" +
                "storageId=" + storageId +
                ", productId=" + productId +
                ", serialNumber='" + serialNumber + '\'' +
                ", cardCode='" + cardCode + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}



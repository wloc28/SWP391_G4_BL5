package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Voucher Model
 * Represents the vouchers table
 */
public class Voucher {
    private int voucherId;
    private String code;
    private String discountType; // 'PERCENT' or 'FIXED'
    private BigDecimal discountValue;
    private BigDecimal minOrderValue;
    private Integer usageLimit;
    private int usedCount;
    private Date expiryDate;
    private String status; // 'ACTIVE' or 'INACTIVE'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // Constructors
    public Voucher() {
        this.minOrderValue = BigDecimal.ZERO;
        this.usedCount = 0;
        this.status = "ACTIVE";
        this.isDeleted = false;
    }
    
    public Voucher(String code, String discountType, BigDecimal discountValue) {
        this();
        this.code = code;
        this.discountType = discountType;
        this.discountValue = discountValue;
    }
    
    // Getters and Setters
    public int getVoucherId() {
        return voucherId;
    }
    
    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }
    
    public String getCode() {
        return code;
    }
    
    public void setCode(String code) {
        this.code = code;
    }
    
    public String getDiscountType() {
        return discountType;
    }
    
    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }
    
    public BigDecimal getDiscountValue() {
        return discountValue;
    }
    
    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }
    
    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }
    
    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }
    
    public Integer getUsageLimit() {
        return usageLimit;
    }
    
    public void setUsageLimit(Integer usageLimit) {
        this.usageLimit = usageLimit;
    }
    
    public int getUsedCount() {
        return usedCount;
    }
    
    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
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
    
    @Override
    public String toString() {
        return "Voucher{" +
                "voucherId=" + voucherId +
                ", code='" + code + '\'' +
                ", discountType='" + discountType + '\'' +
                ", discountValue=" + discountValue +
                ", status='" + status + '\'' +
                '}';
    }
}


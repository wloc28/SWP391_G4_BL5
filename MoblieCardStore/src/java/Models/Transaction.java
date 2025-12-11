package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Transaction Model
 * Represents the transactions table
 */
public class Transaction {
    private int transactionId;
    private int userId;
    private Integer orderId;
    private BigDecimal amount;
    private String transactionType; // 'DEPOSIT', 'PAYMENT', 'REFUND'
    private String description;
    private String status; // 'PENDING', 'SUCCESS', 'FAILED'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted;
    
    // References (optional, for convenience)
    private User user;
    private Order order;
    
    // Constructors
    public Transaction() {
        this.status = "SUCCESS";
        this.isDeleted = false;
    }
    
    public Transaction(int userId, BigDecimal amount, String transactionType) {
        this();
        this.userId = userId;
        this.amount = amount;
        this.transactionType = transactionType;
    }
    
    // Getters and Setters
    public int getTransactionId() {
        return transactionId;
    }
    
    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public Integer getOrderId() {
        return orderId;
    }
    
    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public String getTransactionType() {
        return transactionType;
    }
    
    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
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
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public Order getOrder() {
        return order;
    }
    
    public void setOrder(Order order) {
        this.order = order;
    }
    
    @Override
    public String toString() {
        return "Transaction{" +
                "transactionId=" + transactionId +
                ", userId=" + userId +
                ", orderId=" + orderId +
                ", amount=" + amount +
                ", transactionType='" + transactionType + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}


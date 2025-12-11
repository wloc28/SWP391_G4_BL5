package Models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * PaymentGatewayTransaction Model
 * Represents the payment_gateway_transactions table
 */
public class PaymentGatewayTransaction {
    private int pgId;
    private int transactionId;
    private String gatewayName; // 'VNPAY' or 'MOMO'
    private String paymentRefId;
    private String gatewayTransactionId;
    private BigDecimal amount;
    private String bankCode;
    private String responseCode;
    private String fullResponseLog;
    private Timestamp createdAt;
    
    // Reference to Transaction (optional, for convenience)
    private Transaction transaction;
    
    // Constructors
    public PaymentGatewayTransaction() {
    }
    
    public PaymentGatewayTransaction(int transactionId, String gatewayName) {
        this.transactionId = transactionId;
        this.gatewayName = gatewayName;
    }
    
    // Getters and Setters
    public int getPgId() {
        return pgId;
    }
    
    public void setPgId(int pgId) {
        this.pgId = pgId;
    }
    
    public int getTransactionId() {
        return transactionId;
    }
    
    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }
    
    public String getGatewayName() {
        return gatewayName;
    }
    
    public void setGatewayName(String gatewayName) {
        this.gatewayName = gatewayName;
    }
    
    public String getPaymentRefId() {
        return paymentRefId;
    }
    
    public void setPaymentRefId(String paymentRefId) {
        this.paymentRefId = paymentRefId;
    }
    
    public String getGatewayTransactionId() {
        return gatewayTransactionId;
    }
    
    public void setGatewayTransactionId(String gatewayTransactionId) {
        this.gatewayTransactionId = gatewayTransactionId;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public String getBankCode() {
        return bankCode;
    }
    
    public void setBankCode(String bankCode) {
        this.bankCode = bankCode;
    }
    
    public String getResponseCode() {
        return responseCode;
    }
    
    public void setResponseCode(String responseCode) {
        this.responseCode = responseCode;
    }
    
    public String getFullResponseLog() {
        return fullResponseLog;
    }
    
    public void setFullResponseLog(String fullResponseLog) {
        this.fullResponseLog = fullResponseLog;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Transaction getTransaction() {
        return transaction;
    }
    
    public void setTransaction(Transaction transaction) {
        this.transaction = transaction;
    }
    
    @Override
    public String toString() {
        return "PaymentGatewayTransaction{" +
                "pgId=" + pgId +
                ", transactionId=" + transactionId +
                ", gatewayName='" + gatewayName + '\'' +
                ", amount=" + amount +
                ", responseCode='" + responseCode + '\'' +
                '}';
    }
}


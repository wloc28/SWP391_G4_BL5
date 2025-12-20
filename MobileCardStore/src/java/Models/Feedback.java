package Models;

import java.sql.Timestamp;

/**
 * Feedback Model
 * Represents the feedbacks table
 */
public class Feedback {
    private int feedbackId;
    private int userId;
    private int productId;
    private String content;
    private Integer rating; // 1-5
    private String adminReply;
    private Timestamp adminReplyAt;
    private boolean isVisible;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Reference to User (optional, for convenience)
    private User user;
    
    // Product name (for display, not stored in DB)
    private String productName;
    
    // Constructors
    public Feedback() {
        this.isVisible = false;
    }
    
    public Feedback(int userId, int productId, String content) {
        this();
        this.userId = userId;
        this.productId = productId;
        this.content = content;
    }
    
    // Getters and Setters
    public int getFeedbackId() {
        return feedbackId;
    }
    
    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public Integer getRating() {
        return rating;
    }
    
    public void setRating(Integer rating) {
        // Validate rating range 1-5
        if (rating != null && (rating < 1 || rating > 5)) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }
        this.rating = rating;
    }
    
    public String getAdminReply() {
        return adminReply;
    }
    
    public void setAdminReply(String adminReply) {
        this.adminReply = adminReply;
    }
    
    public Timestamp getAdminReplyAt() {
        return adminReplyAt;
    }
    
    public void setAdminReplyAt(Timestamp adminReplyAt) {
        this.adminReplyAt = adminReplyAt;
    }
    
    public boolean isVisible() {
        return isVisible;
    }
    
    public void setVisible(boolean visible) {
        isVisible = visible;
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
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    @Override
    public String toString() {
        return "Feedback{" +
                "feedbackId=" + feedbackId +
                ", userId=" + userId +
                ", productId=" + productId +
                ", rating=" + rating +
                ", isVisible=" + isVisible +
                '}';
    }
}


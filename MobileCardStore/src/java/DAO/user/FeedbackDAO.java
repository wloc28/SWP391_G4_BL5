package DAO.user;

import DAO.DBConnection;
import Models.Feedback;
import Models.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {
    
    public boolean addFeedback(Feedback feedback) throws SQLException {
        String sql = "INSERT INTO feedbacks (user_id, provider_storage_id, content, rating, is_visible, created_at) " +
                     "VALUES (?, ?, ?, ?, 1, NOW())";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, feedback.getUserId());
            ps.setInt(2, feedback.getProductId());
            // Content có thể là empty string nếu user chỉ rating không comment
            if (feedback.getContent() != null) {
                ps.setString(3, feedback.getContent().trim());
            } else {
                ps.setString(3, ""); // Empty string thay vì null vì content là NOT NULL
            }
            if (feedback.getRating() != null) {
                ps.setInt(4, feedback.getRating());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            
            int result = ps.executeUpdate();
            if (result > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        feedback.setFeedbackId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                throw new SQLException("Bạn đã feedback sản phẩm này rồi!", e);
            }
            throw e;
        }
        return false;
    }
    
    public List<Feedback> getFeedbacksByProductId(int productId) throws SQLException {
        List<Feedback> feedbacks = new ArrayList<>();
        String sql = "SELECT f.*, u.full_name " +
                     "FROM feedbacks f " +
                     "INNER JOIN users u ON f.user_id = u.user_id " +
                     "WHERE f.provider_storage_id = ? AND f.is_visible = 1 AND f.is_deleted = 0 " +
                     "ORDER BY f.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback feedback = mapFeedbackFromResultSet(rs);
                    User user = new User();
                    user.setFullName(rs.getString("full_name"));
                    user.setImage(null); // Bảng users không có cột image
                    feedback.setUser(user);
                    feedbacks.add(feedback);
                }
            }
        }
        return feedbacks;
    }
    
    public boolean hasUserFeedbackedProduct(int userId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM feedbacks " +
                     "WHERE user_id = ? AND provider_storage_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        return false;
    }
    
    public boolean hasUserPurchasedProduct(int userId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM orders " +
                     "WHERE user_id = ? AND provider_storage_id = ? AND status = 'COMPLETED'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        return false;
    }
    
    // Lấy feedback của user hiện tại cho sản phẩm (để sửa rating)
    public Feedback getUserFeedback(int userId, int productId) throws SQLException {
        String sql = "SELECT f.* FROM feedbacks f " +
                     "WHERE f.user_id = ? AND f.provider_storage_id = ? AND f.is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapFeedbackFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    // Cập nhật rating của feedback
    public boolean updateRating(int feedbackId, Integer rating) throws SQLException {
        String sql = "UPDATE feedbacks SET rating = ?, updated_at = NOW() WHERE feedback_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (rating != null) {
                ps.setInt(1, rating);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, feedbackId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    private Feedback mapFeedbackFromResultSet(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setFeedbackId(rs.getInt("feedback_id"));
        feedback.setUserId(rs.getInt("user_id"));
        feedback.setProductId(rs.getInt("provider_storage_id"));
        feedback.setContent(rs.getString("content"));
        feedback.setRating(rs.getObject("rating") != null ? rs.getInt("rating") : null);
        feedback.setStatus(rs.getString("status"));
        feedback.setVisible(rs.getBoolean("is_visible"));
        feedback.setDeleted(rs.getBoolean("is_deleted"));
        feedback.setCreatedAt(rs.getTimestamp("created_at"));
        feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
        feedback.setAdminReply(rs.getString("admin_reply"));
        feedback.setAdminReplyAt(rs.getTimestamp("admin_reply_at"));
        return feedback;
    }
}


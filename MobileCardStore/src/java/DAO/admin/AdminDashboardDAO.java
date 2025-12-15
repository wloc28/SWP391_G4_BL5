package DAO.admin;

import DAO.DBConnection;
import Models.Order;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin Dashboard DAO
 * Cung cấp các method để lấy thống kê cho admin dashboard
 */
public class AdminDashboardDAO {
    
    /**
     * Lấy tổng số người dùng (không tính admin và không bị xóa)
     */
    public int getTotalUsers() throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM users WHERE role != 'ADMIN' AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }
    
    /**
     * Lấy tổng số sản phẩm (không bị xóa)
     */
    public int getTotalProducts() throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM products WHERE is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }
    
    /**
     * Lấy tổng số đơn hàng (không bị xóa)
     */
    public int getTotalOrders() throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM orders WHERE is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }
    
    /**
     * Lấy tổng doanh thu từ tất cả đơn hàng đã hoàn thành
     */
    public BigDecimal getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE status = 'COMPLETED' AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getBigDecimal("total");
            }
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * Lấy doanh thu tháng hiện tại
     */
    public BigDecimal getMonthlyRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders " +
                     "WHERE status = 'COMPLETED' AND is_deleted = 0 " +
                     "AND YEAR(created_at) = YEAR(CURRENT_DATE) " +
                     "AND MONTH(created_at) = MONTH(CURRENT_DATE)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getBigDecimal("total");
            }
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * Lấy số người dùng mới trong tháng hiện tại
     */
    public int getNewUsersThisMonth() throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM users " +
                     "WHERE role != 'ADMIN' AND is_deleted = 0 " +
                     "AND YEAR(created_at) = YEAR(CURRENT_DATE) " +
                     "AND MONTH(created_at) = MONTH(CURRENT_DATE)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }
    
    /**
     * Lấy số đơn hàng theo từng trạng thái
     */
    public Map<String, Integer> getOrdersByStatus() throws SQLException {
        Map<String, Integer> statusMap = new HashMap<>();
        String sql = "SELECT status, COUNT(*) as count FROM orders " +
                     "WHERE is_deleted = 0 GROUP BY status";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                statusMap.put(status, count);
            }
        }
        
        return statusMap;
    }
    
    /**
     * Lấy danh sách đơn hàng gần đây
     */
    public List<Order> getRecentOrders(int limit) throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.username, u.full_name, p.product_name, pv.provider_name " +
                     "FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "LEFT JOIN products p ON o.product_id = p.product_id " +
                     "LEFT JOIN providers pv ON p.provider_id = pv.provider_id " +
                     "WHERE o.is_deleted = 0 " +
                     "ORDER BY o.created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setProductId(rs.getInt("product_id"));
                    order.setProductName(rs.getString("product_name"));
                    order.setProviderName(rs.getString("provider_name"));
                    order.setQuantity(rs.getInt("quantity"));
                    order.setUnitPrice(rs.getBigDecimal("unit_price"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setStatus(rs.getString("status"));
                    order.setCreatedAt(rs.getTimestamp("created_at"));
                    order.setUpdatedAt(rs.getTimestamp("updated_at"));
                    order.setDeleted(rs.getBoolean("is_deleted"));
                    
                    // Set voucher info if available
                    if (rs.getObject("voucher_id") != null) {
                        order.setVoucherId(rs.getInt("voucher_id"));
                        order.setVoucherCode(rs.getString("voucher_code"));
                        order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    }
                    
                    orders.add(order);
                }
            }
        }
        
        return orders;
    }
}


package DAO.admin;

import DAO.DBConnection;
import Models.Order;
import Models.User;
import Models.Product;
import Models.Voucher;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * Order DAO
 * Xử lý các thao tác database cho Order
 */
public class OrderDAO {
    
    /**
     * Lấy tất cả đơn hàng (không bị xóa)
     */
    public List<Order> getAllOrders() throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.username, u.full_name, u.email " +
                     "FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "WHERE o.is_deleted = 0 " +
                     "ORDER BY o.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                orders.add(order);
            }
        }
        
        return orders;
    }
    
    /**
     * Lấy đơn hàng phân trang với tìm kiếm và lọc
     */
    public List<Order> getOrdersPaginated(int offset, int limit, String searchTerm, String statusFilter, 
                                         String productNameFilter, String providerFilter, 
                                         String minPrice, String maxPrice, 
                                         String sortBy, String sortDir) throws SQLException {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.*, u.username, u.full_name, u.email ")
           .append("FROM orders o ")
           .append("LEFT JOIN users u ON o.user_id = u.user_id ")
           .append("WHERE o.is_deleted = 0 ");
        
        // Add search conditions (sanitized)
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            // Escape special SQL characters
            String sanitizedSearch = searchTerm.trim().replace("_", "\\_").replace("%", "\\%");
            String searchPattern = "%" + sanitizedSearch + "%";
            sql.append("AND (o.order_id LIKE ? OR u.username LIKE ? OR u.full_name LIKE ? OR o.product_name LIKE ? OR u.email LIKE ?) ");
        }
        
        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equals(statusFilter)) {
            sql.append("AND o.status = ? ");
        }
        
        // Add product name filter
        if (productNameFilter != null && !productNameFilter.trim().isEmpty()) {
            String sanitizedProduct = productNameFilter.trim().replace("_", "\\_").replace("%", "\\%");
            sql.append("AND o.product_name LIKE ? ");
        }
        
        // Add provider filter
        if (providerFilter != null && !providerFilter.trim().isEmpty() && !"ALL".equals(providerFilter)) {
            sql.append("AND o.provider_name = ? ");
        }
        
        // Add price filters
        if (minPrice != null && !minPrice.trim().isEmpty()) {
            try {
                Double.parseDouble(minPrice.trim());
                sql.append("AND o.total_amount >= ? ");
            } catch (NumberFormatException e) {
                // Invalid number, ignore
            }
        }
        
        if (maxPrice != null && !maxPrice.trim().isEmpty()) {
            try {
                Double.parseDouble(maxPrice.trim());
                sql.append("AND o.total_amount <= ? ");
            } catch (NumberFormatException e) {
                // Invalid number, ignore
            }
        }
        
        // Add sorting
        String orderBy = "o.created_at";
        String direction = "DESC";
        
        if (sortBy != null && !sortBy.trim().isEmpty()) {
            switch (sortBy) {
                case "order_id":
                    orderBy = "o.order_id";
                    break;
                case "product_name":
                    orderBy = "o.product_name";
                    break;
                case "total_amount":
                    orderBy = "o.total_amount";
                    break;
                case "created_at":
                    orderBy = "o.created_at";
                    break;
                case "status":
                    orderBy = "o.status";
                    break;
                case "username":
                    orderBy = "u.username";
                    break;
                default:
                    orderBy = "o.created_at";
            }
        }
        
        if (sortDir != null && ("ASC".equalsIgnoreCase(sortDir) || "DESC".equalsIgnoreCase(sortDir))) {
            direction = sortDir.toUpperCase();
        }
        
        sql.append("ORDER BY ").append(orderBy).append(" ").append(direction).append(" LIMIT ? OFFSET ?");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set search parameters
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                String sanitizedSearch = searchTerm.trim().replace("_", "\\_").replace("%", "\\%");
                String searchPattern = "%" + sanitizedSearch + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set status filter parameter
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            
            // Set product name filter
            if (productNameFilter != null && !productNameFilter.trim().isEmpty()) {
                String sanitizedProduct = productNameFilter.trim().replace("_", "\\_").replace("%", "\\%");
                ps.setString(paramIndex++, "%" + sanitizedProduct + "%");
            }
            
            // Set provider filter
            if (providerFilter != null && !providerFilter.trim().isEmpty() && !"ALL".equals(providerFilter)) {
                ps.setString(paramIndex++, providerFilter);
            }
            
            // Set price filters
            if (minPrice != null && !minPrice.trim().isEmpty()) {
                try {
                    ps.setBigDecimal(paramIndex++, new java.math.BigDecimal(minPrice.trim()));
                } catch (NumberFormatException e) {
                    // Skip invalid number
                }
            }
            
            if (maxPrice != null && !maxPrice.trim().isEmpty()) {
                try {
                    ps.setBigDecimal(paramIndex++, new java.math.BigDecimal(maxPrice.trim()));
                } catch (NumberFormatException e) {
                    // Skip invalid number
                }
            }
            
            // Set pagination parameters
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    orders.add(order);
                }
            }
        }
        
        return orders;
    }
    
    /**
     * Đếm tổng số đơn hàng với tìm kiếm và lọc
     */
    public int countOrders(String searchTerm, String statusFilter, String productNameFilter, 
                          String providerFilter, String minPrice, String maxPrice) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM orders o ")
           .append("LEFT JOIN users u ON o.user_id = u.user_id ")
           .append("WHERE o.is_deleted = 0 ");
        
        // Add search conditions (sanitized)
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String sanitizedSearch = searchTerm.trim().replace("_", "\\_").replace("%", "\\%");
            sql.append("AND (o.order_id LIKE ? OR u.username LIKE ? OR u.full_name LIKE ? OR o.product_name LIKE ? OR u.email LIKE ?) ");
        }
        
        // Add status filter
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equals(statusFilter)) {
            sql.append("AND o.status = ? ");
        }
        
        // Add product name filter
        if (productNameFilter != null && !productNameFilter.trim().isEmpty()) {
            String sanitizedProduct = productNameFilter.trim().replace("_", "\\_").replace("%", "\\%");
            sql.append("AND o.product_name LIKE ? ");
        }
        
        // Add provider filter
        if (providerFilter != null && !providerFilter.trim().isEmpty() && !"ALL".equals(providerFilter)) {
            sql.append("AND o.provider_name = ? ");
        }
        
        // Add price filters
        if (minPrice != null && !minPrice.trim().isEmpty()) {
            try {
                Double.parseDouble(minPrice.trim());
                sql.append("AND o.total_amount >= ? ");
            } catch (NumberFormatException e) {
                // Invalid number, ignore
            }
        }
        
        if (maxPrice != null && !maxPrice.trim().isEmpty()) {
            try {
                Double.parseDouble(maxPrice.trim());
                sql.append("AND o.total_amount <= ? ");
            } catch (NumberFormatException e) {
                // Invalid number, ignore
            }
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set search parameters
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                String sanitizedSearch = searchTerm.trim().replace("_", "\\_").replace("%", "\\%");
                String searchPattern = "%" + sanitizedSearch + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set status filter parameter
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            
            // Set product name filter
            if (productNameFilter != null && !productNameFilter.trim().isEmpty()) {
                String sanitizedProduct = productNameFilter.trim().replace("_", "\\_").replace("%", "\\%");
                ps.setString(paramIndex++, "%" + sanitizedProduct + "%");
            }
            
            // Set provider filter
            if (providerFilter != null && !providerFilter.trim().isEmpty() && !"ALL".equals(providerFilter)) {
                ps.setString(paramIndex++, providerFilter);
            }
            
            // Set price filters
            if (minPrice != null && !minPrice.trim().isEmpty()) {
                try {
                    ps.setBigDecimal(paramIndex++, new java.math.BigDecimal(minPrice.trim()));
                } catch (NumberFormatException e) {
                    // Skip invalid number
                }
            }
            
            if (maxPrice != null && !maxPrice.trim().isEmpty()) {
                try {
                    ps.setBigDecimal(paramIndex++, new java.math.BigDecimal(maxPrice.trim()));
                } catch (NumberFormatException e) {
                    // Skip invalid number
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Lấy đơn hàng theo ID
     */
    public Order getOrderById(int orderId) throws SQLException {
        String sql = "SELECT o.*, u.username, u.full_name, u.email, u.phone_number " +
                     "FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "WHERE o.order_id = ? AND o.is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrder(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Lấy lịch sử đơn hàng theo user ID
     */
    public List<Order> getOrderHistoryByUserId(int userId) throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.username, u.full_name, u.email " +
                     "FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "WHERE o.user_id = ? AND o.is_deleted = 0 " +
                     "ORDER BY o.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    orders.add(order);
                }
            }
        }
        
        return orders;
    }
    
    /**
     * Cập nhật trạng thái đơn hàng
     */
    public boolean updateOrderStatus(int orderId, String status, int updatedBy) throws SQLException {
        String sql = "UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, orderId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        }
    }
    
    /**
     * Xóa mềm đơn hàng
     */
    public boolean softDeleteOrder(int orderId, int deletedBy) throws SQLException {
        String sql = "UPDATE orders SET is_deleted = 1, deleted_by = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE order_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, deletedBy);
            ps.setInt(2, orderId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        }
    }
    
    /**
     * Lấy thống kê đơn hàng theo trạng thái
     */
    public Map<String, Integer> getOrderStatistics() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT status, COUNT(*) as count FROM orders WHERE is_deleted = 0 GROUP BY status";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("status"), rs.getInt("count"));
            }
        }
        
        return stats;
    }
    
    /**
     * Lấy đơn hàng gần đây (10 đơn hàng mới nhất)
     */
    public List<Order> getRecentOrders(int limit) throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.username, u.full_name, u.email " +
                     "FROM orders o " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "WHERE o.is_deleted = 0 " +
                     "ORDER BY o.created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    orders.add(order);
                }
            }
        }
        
        return orders;
    }
    
    /**
     * Lấy danh sách các provider duy nhất
     */
    public List<String> getDistinctProviders() throws SQLException {
        List<String> providers = new ArrayList<>();
        String sql = "SELECT DISTINCT provider_name FROM orders WHERE is_deleted = 0 ORDER BY provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                providers.add(rs.getString("provider_name"));
            }
        }
        
        return providers;
    }
    
    /**
     * Tạo đơn hàng mới từ thông tin sản phẩm
     */
    public int createOrder(int userId, int productId, String providerName, String productName,
                           BigDecimal unitPrice, int quantity, Integer voucherId, String voucherCode,
                           BigDecimal discountAmount, BigDecimal totalAmount, int createdBy) throws SQLException {
        String sql = "INSERT INTO orders (user_id, product_id, provider_name, product_name, " +
                     "unit_price, quantity, voucher_id, voucher_code, discount_amount, total_amount, " +
                     "status, created_at, updated_at, is_deleted, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW(), NOW(), 0, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.setString(3, providerName);
            ps.setString(4, productName);
            ps.setBigDecimal(5, unitPrice);
            ps.setInt(6, quantity);
            
            if (voucherId != null) {
                ps.setInt(7, voucherId);
                ps.setString(8, voucherCode);
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
                ps.setNull(8, java.sql.Types.VARCHAR);
            }
            
            ps.setBigDecimal(9, discountAmount != null ? discountAmount : BigDecimal.ZERO);
            ps.setBigDecimal(10, totalAmount);
            ps.setInt(11, createdBy);
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        
        return -1;
    }
    
    /**
     * Map ResultSet to Order object
     */
    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setUserId(rs.getInt("user_id"));
        order.setProductId(rs.getInt("product_id"));
        order.setProviderName(rs.getString("provider_name"));
        order.setProductName(rs.getString("product_name"));
        order.setUnitPrice(rs.getBigDecimal("unit_price"));
        order.setQuantity(rs.getInt("quantity"));
        order.setProductLog(rs.getString("product_log"));
        
        // Voucher info
        if (rs.getObject("voucher_id") != null) {
            order.setVoucherId(rs.getInt("voucher_id"));
            order.setVoucherCode(rs.getString("voucher_code"));
            order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        }
        
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
        order.setDeleted(rs.getBoolean("is_deleted"));
        
        // Create user object with basic info
        if (rs.getString("username") != null) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setUsername(rs.getString("username"));
            user.setFullName(rs.getString("full_name"));
            user.setEmail(rs.getString("email"));
            
            // Check if phone_number column exists (only in detailed view)
            try {
                user.setPhoneNumber(rs.getString("phone_number"));
            } catch (SQLException e) {
                // Column doesn't exist, ignore
            }
            
            order.setUser(user);
        }
        
        return order;
    }
}

package DAO.admin;

import DAO.DBConnection;
import Models.Product;
import Models.ProductStorage;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Product Storage DAO
 * Xử lý các thao tác database cho Product Storage
 */
public class ProductStorageDAO {
    
    /**
     * Lấy tất cả storage items (không bị xóa)
     */
    public List<ProductStorage> getAllStorageItems() throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        String sql = "SELECT ps.*, p.product_name, p.price, pr.provider_name " +
                     "FROM product_storage ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE ps.is_deleted = 0 " +
                     "ORDER BY ps.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                ProductStorage item = mapResultSetToStorage(rs);
                items.add(item);
            }
        }
        
        return items;
    }
    
    /**
     * Lấy storage item theo ID
     */
    public ProductStorage getStorageItemById(int storageId) throws SQLException {
        String sql = "SELECT ps.*, p.product_name, p.price, pr.provider_name " +
                     "FROM product_storage ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE ps.storage_id = ? AND ps.is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, storageId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStorage(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Lấy storage items theo product ID
     */
    public List<ProductStorage> getStorageItemsByProductId(int productId) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        String sql = "SELECT ps.*, p.product_name, p.price, pr.provider_name " +
                     "FROM product_storage ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE ps.product_id = ? AND ps.is_deleted = 0 " +
                     "ORDER BY ps.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Thêm storage item mới
     */
    public boolean addStorageItem(ProductStorage item) throws SQLException {
        String sql = "INSERT INTO product_storage (product_id, serial_number, card_code, expiry_date, status, created_at, updated_at, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), NOW(), 0)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, item.getProductId());
            ps.setString(2, item.getSerialNumber());
            ps.setString(3, item.getCardCode());
            if (item.getExpiryDate() != null) {
                ps.setDate(4, item.getExpiryDate());
            } else {
                ps.setDate(4, null);
            }
            ps.setString(5, item.getStatus());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật storage item
     */
    public boolean updateStorageItem(ProductStorage item) throws SQLException {
        String sql = "UPDATE product_storage SET product_id = ?, serial_number = ?, card_code = ?, " +
                     "expiry_date = ?, status = ?, updated_at = NOW() " +
                     "WHERE storage_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, item.getProductId());
            ps.setString(2, item.getSerialNumber());
            ps.setString(3, item.getCardCode());
            if (item.getExpiryDate() != null) {
                ps.setDate(4, item.getExpiryDate());
            } else {
                ps.setDate(4, null);
            }
            ps.setString(5, item.getStatus());
            ps.setInt(6, item.getStorageId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa storage item (soft delete)
     */
    public boolean deleteStorageItem(int storageId) throws SQLException {
        String sql = "UPDATE product_storage SET is_deleted = 1, updated_at = NOW() WHERE storage_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, storageId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Đếm số lượng items available theo product ID
     */
    public int countAvailableItemsByProductId(int productId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM product_storage " +
                     "WHERE product_id = ? AND status = 'AVAILABLE' AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Tìm kiếm storage items theo nhiều tiêu chí
     * @param searchKeyword từ khóa tìm kiếm (tìm trong product name, serial, card code)
     * @param status trạng thái (AVAILABLE, SOLD, ERROR, hoặc null/empty cho tất cả)
     * @return danh sách storage items phù hợp
     */
    public List<ProductStorage> searchStorageItems(String searchKeyword, String status) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ps.*, p.product_name, p.price, pr.provider_name ")
           .append("FROM product_storage ps ")
           .append("LEFT JOIN products p ON ps.product_id = p.product_id ")
           .append("LEFT JOIN providers pr ON p.provider_id = pr.provider_id ")
           .append("WHERE ps.is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR ps.serial_number LIKE ? OR ps.card_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND ps.status = ? ");
        }
        
        sql.append("ORDER BY ps.created_at DESC");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Tìm kiếm storage items với phân trang
     * @param searchKeyword từ khóa tìm kiếm
     * @param status trạng thái
     * @param offset vị trí bắt đầu
     * @param limit số lượng items mỗi trang
     * @return danh sách storage items
     */
    public List<ProductStorage> searchStorageItemsWithPagination(String searchKeyword, String status, int offset, int limit) throws SQLException {
        List<ProductStorage> items = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ps.*, p.product_name, p.price, pr.provider_name ")
           .append("FROM product_storage ps ")
           .append("LEFT JOIN products p ON ps.product_id = p.product_id ")
           .append("LEFT JOIN providers pr ON p.provider_id = pr.provider_id ")
           .append("WHERE ps.is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR ps.serial_number LIKE ? OR ps.card_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND ps.status = ? ");
        }
        
        sql.append("ORDER BY ps.created_at DESC ");
        sql.append("LIMIT ? OFFSET ?");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
            }
            
            // Set pagination parameters
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStorage item = mapResultSetToStorage(rs);
                    items.add(item);
                }
            }
        }
        
        return items;
    }
    
    /**
     * Đếm tổng số storage items theo điều kiện tìm kiếm
     * @param searchKeyword từ khóa tìm kiếm
     * @param status trạng thái
     * @return tổng số items
     */
    public int countStorageItems(String searchKeyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) as total ")
           .append("FROM product_storage ps ")
           .append("LEFT JOIN products p ON ps.product_id = p.product_id ")
           .append("WHERE ps.is_deleted = 0 ");
        
        // Thêm điều kiện tìm kiếm theo từ khóa
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR ps.serial_number LIKE ? OR ps.card_code LIKE ?) ");
        }
        
        // Thêm điều kiện lọc theo trạng thái
        if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
            sql.append("AND ps.status = ? ");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            
            // Set parameters cho từ khóa tìm kiếm
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                String searchPattern = "%" + searchKeyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            // Set parameter cho trạng thái
            if (status != null && !status.trim().isEmpty() && !status.equals("ALL")) {
                ps.setString(paramIndex++, status);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Map ResultSet to ProductStorage object
     */
    private ProductStorage mapResultSetToStorage(ResultSet rs) throws SQLException {
        ProductStorage item = new ProductStorage();
        item.setStorageId(rs.getInt("storage_id"));
        item.setProductId(rs.getInt("product_id"));
        item.setSerialNumber(rs.getString("serial_number"));
        item.setCardCode(rs.getString("card_code"));
        item.setExpiryDate(rs.getDate("expiry_date"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        item.setDeleted(rs.getBoolean("is_deleted"));
        
        // Set product info if available
        if (rs.getString("product_name") != null) {
            Product product = new Product();
            product.setProductId(rs.getInt("product_id"));
            product.setProductName(rs.getString("product_name"));
            product.setPrice(rs.getBigDecimal("price"));
            item.setProduct(product);
        }
        
        return item;
    }
}


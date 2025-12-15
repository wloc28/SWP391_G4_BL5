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


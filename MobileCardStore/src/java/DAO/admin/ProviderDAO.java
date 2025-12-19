package DAO.admin;

import DAO.DBConnection;
import Models.Provider;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Provider DAO
 * Xử lý các thao tác database cho Provider (sản phẩm fix cứng từ nhà cung cấp)
 */
public class ProviderDAO {
    
    /**
     * Lấy tất cả sản phẩm của provider (grouped by provider_name)
     */
    public Map<String, List<Provider>> getProviderProductsGrouped() throws SQLException {
        Map<String, List<Provider>> result = new LinkedHashMap<>();
        String sql = "SELECT * FROM providers " +
                     "WHERE is_deleted = 0 AND status = 'ACTIVE' " +
                     "ORDER BY provider_name, price ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Provider provider = mapResultSetToProvider(rs);
                String providerName = provider.getProviderName();
                
                if (!result.containsKey(providerName)) {
                    result.put(providerName, new ArrayList<>());
                }
                result.get(providerName).add(provider);
            }
        }
        
        return result;
    }
    
    /**
     * Lấy tất cả sản phẩm của một provider cụ thể
     */
    public List<Provider> getProductsByProviderName(String providerName) throws SQLException {
        List<Provider> products = new ArrayList<>();
        String sql = "SELECT * FROM providers " +
                     "WHERE provider_name = ? AND is_deleted = 0 AND status = 'ACTIVE' " +
                     "ORDER BY price ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, providerName);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProvider(rs));
                }
            }
        }
        
        return products;
    }
    
    /**
     * Lấy sản phẩm provider theo ID
     */
    public Provider getProviderProductById(int providerId) throws SQLException {
        String sql = "SELECT * FROM providers WHERE provider_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProvider(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Lấy sản phẩm provider theo product_code và provider_name
     */
    public Provider getProviderProductByCode(String providerName, String productCode) throws SQLException {
        String sql = "SELECT * FROM providers " +
                     "WHERE provider_name = ? AND product_code = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, providerName);
            ps.setString(2, productCode);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProvider(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Giảm số lượng sau khi nhập hàng
     * @param providerId ID của provider product
     * @param quantity Số lượng cần giảm
     * @return true nếu thành công, false nếu không đủ số lượng
     */
    public boolean decreaseQuantity(int providerId, int quantity) throws SQLException {
        // Kiểm tra số lượng đủ không
        Provider provider = getProviderProductById(providerId);
        if (provider == null || provider.getQuantity() < quantity) {
            return false;
        }
        
        String sql = "UPDATE providers SET quantity = quantity - ?, updated_at = NOW() " +
                     "WHERE provider_id = ? AND quantity >= ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, quantity);
            ps.setInt(2, providerId);
            ps.setInt(3, quantity);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Tăng số lượng (nếu cần nhập thêm vào provider)
     */
    public boolean increaseQuantity(int providerId, int quantity) throws SQLException {
        String sql = "UPDATE providers SET quantity = quantity + ?, updated_at = NOW() " +
                     "WHERE provider_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, quantity);
            ps.setInt(2, providerId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Lấy số lượng hiện có
     */
    public int getAvailableQuantity(int providerId) throws SQLException {
        String sql = "SELECT quantity FROM providers WHERE provider_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Lấy danh sách tất cả provider names (unique)
     */
    public List<String> getAllProviderNames() throws SQLException {
        List<String> names = new ArrayList<>();
        String sql = "SELECT DISTINCT provider_name FROM providers " +
                     "WHERE is_deleted = 0 AND status = 'ACTIVE' " +
                     "ORDER BY provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                names.add(rs.getString("provider_name"));
            }
        }
        
        return names;
    }
    
    /**
     * Map ResultSet to Provider object
     */
    private Provider mapResultSetToProvider(ResultSet rs) throws SQLException {
        Provider provider = new Provider();
        provider.setProviderId(rs.getInt("provider_id"));
        provider.setProviderName(rs.getString("provider_name"));
        provider.setProviderType(rs.getString("provider_type"));
        provider.setProductCode(rs.getString("product_code"));
        provider.setProductName(rs.getString("product_name"));
        
        if (rs.getObject("price") != null) {
            provider.setPrice(rs.getBigDecimal("price"));
        }
        if (rs.getObject("purchase_price") != null) {
            provider.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        }
        
        provider.setQuantity(rs.getInt("quantity"));
        provider.setImageUrl(rs.getString("image_url"));
        provider.setStatus(rs.getString("status"));
        provider.setCreatedAt(rs.getTimestamp("created_at"));
        provider.setUpdatedAt(rs.getTimestamp("updated_at"));
        provider.setDeleted(rs.getBoolean("is_deleted"));
        
        return provider;
    }
}




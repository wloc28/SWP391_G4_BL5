package DAO.admin;

import DAO.DBConnection;
import Models.Product;
import Models.Provider;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Product DAO
 * Xử lý các thao tác database cho Product
 */
public class ProductDAO {
    
    /**
     * Lấy tất cả sản phẩm (không bị xóa)
     */
    public List<Product> getAllProducts() throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type " +
                     "FROM products p " +
                     "LEFT JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE p.is_deleted = 0 " +
                     "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Product product = mapResultSetToProduct(rs);
                products.add(product);
            }
        }
        
        return products;
    }
    
    /**
     * Lấy sản phẩm theo ID
     */
    public Product getProductById(int productId) throws SQLException {
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type " +
                     "FROM products p " +
                     "LEFT JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE p.product_id = ? AND p.is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Thêm sản phẩm mới
     */
    public boolean addProduct(Product product) throws SQLException {
        String sql = "INSERT INTO products (provider_id, product_name, price, description, image_url, status, created_at, updated_at, is_deleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), 0)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, product.getProviderId());
            ps.setString(2, product.getProductName());
            ps.setBigDecimal(3, product.getPrice());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getImageUrl());
            ps.setString(6, product.getStatus());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật sản phẩm
     */
    public boolean updateProduct(Product product) throws SQLException {
        String sql = "UPDATE products SET provider_id = ?, product_name = ?, price = ?, description = ?, " +
                     "image_url = ?, status = ?, updated_at = NOW() " +
                     "WHERE product_id = ? AND is_deleted = 0";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, product.getProviderId());
            ps.setString(2, product.getProductName());
            ps.setBigDecimal(3, product.getPrice());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getImageUrl());
            ps.setString(6, product.getStatus());
            ps.setInt(7, product.getProductId());
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa sản phẩm (soft delete)
     */
    public boolean deleteProduct(int productId) throws SQLException {
        String sql = "UPDATE products SET is_deleted = 1, updated_at = NOW() WHERE product_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, productId);
            
            return ps.executeUpdate() > 0;
        }
    }
    
    /**
     * Lấy tất cả providers
     */
    public List<Provider> getAllProviders() throws SQLException {
        List<Provider> providers = new ArrayList<>();
        String sql = "SELECT * FROM providers WHERE is_deleted = 0 ORDER BY provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Provider provider = new Provider();
                provider.setProviderId(rs.getInt("provider_id"));
                provider.setProviderName(rs.getString("provider_name"));
                provider.setProviderType(rs.getString("provider_type"));
                provider.setImageUrl(rs.getString("image_url"));
                provider.setStatus(rs.getString("status"));
                provider.setCreatedAt(rs.getTimestamp("created_at"));
                provider.setUpdatedAt(rs.getTimestamp("updated_at"));
                provider.setDeleted(rs.getBoolean("is_deleted"));
                
                providers.add(provider);
            }
        }
        
        return providers;
    }
    
    /**
     * Map ResultSet to Product object
     */
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setProviderId(rs.getInt("provider_id"));
        product.setProductName(rs.getString("product_name"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setDescription(rs.getString("description"));
        product.setImageUrl(rs.getString("image_url"));
        product.setStatus(rs.getString("status"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        product.setDeleted(rs.getBoolean("is_deleted"));
        
        // Set provider info if available
        if (rs.getString("provider_name") != null) {
            Provider provider = new Provider();
            provider.setProviderId(rs.getInt("provider_id"));
            provider.setProviderName(rs.getString("provider_name"));
            provider.setProviderType(rs.getString("provider_type"));
            product.setProvider(provider);
        }
        
        return product;
    }
}


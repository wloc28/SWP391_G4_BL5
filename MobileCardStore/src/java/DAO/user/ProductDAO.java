package DAO.user;

import DAO.DBConnection;
import Models.Product;
import Models.Provider;
import Models.ProductWithStock;
import Models.ProductDisplay;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;


/**
 * ProductDAO - Data Access Object for Products
 * Handles all database operations related to products
 */
public class ProductDAO {
    
    /**
     * Get all active products with provider information
     */
    public List<Product> getAllProducts() throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type, pr.image_url as provider_image_url " +
                     "FROM products p " +
                     "INNER JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE p.is_deleted = 0 AND p.status = 'ACTIVE' " +
                     "AND pr.is_deleted = 0 AND pr.status = 'ACTIVE' " +
                     "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                products.add(mapResultSetToProduct(rs));
            }
        }
        return products;
    }
    
    /**
     * Get product by ID with provider information
     */
    public Product getProductById(int productId) throws SQLException {
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type, pr.image_url as provider_image_url " +
                     "FROM products p " +
                     "INNER JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE p.product_id = ? AND p.is_deleted = 0 AND p.status = 'ACTIVE' " +
                     "AND pr.is_deleted = 0 AND pr.status = 'ACTIVE'";
        
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
     * Search and filter products with pagination
     * @param searchKeyword - search in product name and description
     * @param providerId - filter by provider (0 = all)
     * @param providerType - filter by provider type (TEL/GAME, null = all)
     * @param minPrice - minimum price (null = no limit)
     * @param maxPrice - maximum price (null = no limit)
     * @param sortBy - sort field (name, price, created_at)
     * @param sortOrder - ASC or DESC
     * @param page - page number (1-based)
     * @param pageSize - items per page
     * @return List of products
     */
    public List<Product> searchAndFilterProducts(String searchKeyword, int providerId, 
                                                  String providerType, BigDecimal minPrice, 
                                                  BigDecimal maxPrice, String sortBy, 
                                                  String sortOrder, int page, int pageSize) throws SQLException {
        List<Product> products = new ArrayList<>();
        
        // Build WHERE clause
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE p.is_deleted = 0 AND p.status = 'ACTIVE' ");
        whereClause.append("AND pr.is_deleted = 0 AND pr.status = 'ACTIVE' ");
        
        List<Object> params = new ArrayList<>();
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            whereClause.append("AND (p.product_name LIKE ? OR p.description LIKE ?) ");
            String searchPattern = "%" + searchKeyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (providerId > 0) {
            whereClause.append("AND p.provider_id = ? ");
            params.add(providerId);
        }
        
        if (providerType != null && !providerType.isEmpty() && !providerType.equals("ALL")) {
            whereClause.append("AND pr.provider_type = ? ");
            params.add(providerType);
        }
        
        if (minPrice != null) {
            whereClause.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        
        if (maxPrice != null) {
            whereClause.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        
        // Build ORDER BY clause
        String orderBy = "p.created_at";
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy.toLowerCase()) {
                case "name":
                    orderBy = "p.product_name";
                    break;
                case "price":
                    orderBy = "p.price";
                    break;
                case "created_at":
                    orderBy = "p.created_at";
                    break;
                default:
                    orderBy = "p.created_at";
            }
        }
        
        String order = (sortOrder != null && sortOrder.equalsIgnoreCase("DESC")) ? "DESC" : "ASC";
        
        // Build SQL query
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type, pr.image_url as provider_image_url " +
                     "FROM products p " +
                     "INNER JOIN providers pr ON p.provider_id = pr.provider_id " +
                     whereClause.toString() +
                     "ORDER BY " + orderBy + " " + order + " " +
                     "LIMIT ? OFFSET ?";
        
        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof BigDecimal) {
                    ps.setBigDecimal(i + 1, (BigDecimal) param);
                }
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }
        }
        return products;
    }
    
    /**
     * Count total products matching search/filter criteria (for pagination)
     */
    public int countProducts(String searchKeyword, int providerId, String providerType, 
                            BigDecimal minPrice, BigDecimal maxPrice) throws SQLException {
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE p.is_deleted = 0 AND p.status = 'ACTIVE' ");
        whereClause.append("AND pr.is_deleted = 0 AND pr.status = 'ACTIVE' ");
        
        List<Object> params = new ArrayList<>();
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            whereClause.append("AND (p.product_name LIKE ? OR p.description LIKE ?) ");
            String searchPattern = "%" + searchKeyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (providerId > 0) {
            whereClause.append("AND p.provider_id = ? ");
            params.add(providerId);
        }
        
        if (providerType != null && !providerType.isEmpty() && !providerType.equals("ALL")) {
            whereClause.append("AND pr.provider_type = ? ");
            params.add(providerType);
        }
        
        if (minPrice != null) {
            whereClause.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        
        if (maxPrice != null) {
            whereClause.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        
        String sql = "SELECT COUNT(*) as total " +
                     "FROM products p " +
                     "INNER JOIN providers pr ON p.provider_id = pr.provider_id " +
                     whereClause.toString();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof BigDecimal) {
                    ps.setBigDecimal(i + 1, (BigDecimal) param);
                }
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
     * Get available stock count for a product
     */
    public int getAvailableStock(int productId) throws SQLException {
        String sql = "SELECT COUNT(*) as count " +
                     "FROM product_storage " +
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
     * Get all active providers for filter dropdown
     */
    public List<Provider> getAllProviders() throws SQLException {
        List<Provider> providers = new ArrayList<>();
        String sql = "SELECT * FROM providers WHERE is_deleted = 0 AND status = 'ACTIVE' ORDER BY provider_name";
        
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
                providers.add(provider);
            }
        }
        return providers;
    }
    
    /**
     * Map ResultSet to Product object with Provider information
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
        
        // Set Provider information
        Provider provider = new Provider();
        provider.setProviderId(rs.getInt("provider_id"));
        provider.setProviderName(rs.getString("provider_name"));
        provider.setProviderType(rs.getString("provider_type"));
        provider.setImageUrl(rs.getString("provider_image_url"));
        product.setProvider(provider);
        
        return product;
    }


    /*HomePage*/
    public Map<Provider, List<ProductWithStock>> getProductsGroupedByProvider() throws SQLException {
        Map<Provider, List<ProductWithStock>> result = new LinkedHashMap<>();

        String sql = """
            SELECT 
                p.product_id, p.product_name, p.price, p.description, p.image_url,
                pr.provider_id, pr.provider_name, pr.provider_type, pr.image_url AS provider_image_url,
                (SELECT COUNT(*) FROM product_storage ps 
                 WHERE ps.product_id = p.product_id 
                 AND ps.status = 'AVAILABLE' 
                 AND ps.is_deleted = 0) AS available_count
            FROM products p
            JOIN providers pr ON p.provider_id = pr.provider_id
            WHERE p.status = 'ACTIVE' AND p.is_deleted = 0
              AND pr.status = 'ACTIVE' AND pr.is_deleted = 0
            ORDER BY FIELD(pr.provider_type, 'TEL', 'GAME'), pr.provider_name, p.price ASC
            """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs. next()) {
                // Extract provider info
                int providerId = rs.getInt("provider_id");
                String providerName = rs.getString("provider_name");
                String providerType = rs.getString("provider_type");
                String providerImageUrl = rs.getString("provider_image_url");

                // Find or create provider key in map
                Provider providerKey = null;
                for (Provider p : result.keySet()) {
                    if (p.getProviderId() == providerId) {
                        providerKey = p;
                        break;
                    }
                }

                if (providerKey == null) {
                    providerKey = new Provider();
                    providerKey.setProviderId(providerId);
                    providerKey.setProviderName(providerName);
                    providerKey.setProviderType(providerType);
                    providerKey.setImageUrl(providerImageUrl);
                    result.put(providerKey, new ArrayList<>());
                }

                // Create ProductWithStock
                ProductWithStock product = new ProductWithStock();
                product.setProductId(rs.getInt("product_id"));
                product.setProductName(rs.getString("product_name"));
                product.setPrice(rs.getBigDecimal("price"));
                product.setDescription(rs.getString("description"));
                product.setImageUrl(rs.getString("image_url"));
                product.setProviderId(providerId);
                product.setProviderName(providerName);
                product.setProviderType(providerType);
                product.setProviderImageUrl(providerImageUrl);
                product.setAvailableCount(rs.getInt("available_count"));

                // Add to provider's product list
                result.get(providerKey).add(product);
            }
        }

        return result;
    }
    
    /**
     * Get related products by same provider (excluding current product)
     * @param currentProductId - ID of current product to exclude
     * @param providerId - Provider ID to filter by
     * @param limit - Maximum number of related products to return
     * @return List of related products
     */
    public List<Product> getRelatedProducts(int currentProductId, int providerId, int limit) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, pr.provider_name, pr.provider_type, pr.image_url as provider_image_url " +
                     "FROM products p " +
                     "INNER JOIN providers pr ON p.provider_id = pr.provider_id " +
                     "WHERE p.is_deleted = 0 AND p.status = 'ACTIVE' " +
                     "AND pr.is_deleted = 0 AND pr.status = 'ACTIVE' " +
                     "AND p.provider_id = ? AND p.product_id != ? " +
                     "ORDER BY p.created_at DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, providerId);
            ps.setInt(2, currentProductId);
            ps.setInt(3, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }
        }
        return products;
    }
    
    /**
     * Get ProductDisplay by product_code and provider_id
     * Query from product_storage joined with products and providers
     */
    public ProductDisplay getProductByCode(String productCode, int providerId) throws SQLException {
        // Query từ product_storage join với products và providers
        // Tìm product có product_code tương ứng (có thể từ provider_storage hoặc từ một mapping table)
        // Tạm thời, tôi sẽ query từ products dựa trên product_name hoặc một cách khác
        // Nhưng vì không có product_code trong products, tôi sẽ query từ product_storage
        // với điều kiện là product_code được lưu trong serial_number hoặc card_code
        // Hoặc query từ provider_storage nếu có
        
        // Cách 1: Query từ provider_storage (nếu product_code được lưu ở đây)
        String sql = """
            SELECT 
                ps.provider_storage_id,
                ps.provider_id,
                ps.product_code,
                ps.product_name,
                ps.price,
                ps.purchase_price,
                pr.provider_name,
                pr.provider_type,
                (SELECT COUNT(*) FROM product_storage pst 
                 JOIN products p ON pst.product_id = p.product_id
                 WHERE p.provider_id = ps.provider_id 
                 AND p.product_name = ps.product_name
                 AND pst.status = 'AVAILABLE' 
                 AND pst.is_deleted = 0) AS available_count
            FROM provider_storage ps
            JOIN providers pr ON ps.provider_id = pr.provider_id
            WHERE ps.product_code = ? AND ps.provider_id = ? 
            AND ps.is_deleted = 0 AND ps.status = 'ACTIVE'
            LIMIT 1
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            ps.setInt(2, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductDisplay product = new ProductDisplay();
                    product.setProductCode(rs.getString("product_code"));
                    product.setProductName(rs.getString("product_name"));
                    product.setProviderId(rs.getInt("provider_id"));
                    product.setProviderName(rs.getString("provider_name"));
                    product.setProviderType(rs.getString("provider_type"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                    product.setAvailableCount(rs.getInt("available_count"));
                    product.setStatus("ACTIVE");
                    return product;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get available stock count by product_code and provider_id
     */
    public int getAvailableStock(String productCode, int providerId) throws SQLException {
        // Query từ product_storage join với products
        // Tìm số lượng available dựa trên product_code và provider_id
        // Join với provider_storage để lấy product_code
        String sql = """
            SELECT COUNT(*) as count
            FROM product_storage pst
            JOIN products p ON pst.product_id = p.product_id
            JOIN provider_storage ps ON p.provider_id = ps.provider_id 
                AND p.product_name = ps.product_name
            WHERE ps.product_code = ? 
            AND ps.provider_id = ?
            AND pst.status = 'AVAILABLE' 
            AND pst.is_deleted = 0
            AND p.is_deleted = 0
            AND p.status = 'ACTIVE'
            AND ps.is_deleted = 0
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            ps.setInt(2, providerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
}



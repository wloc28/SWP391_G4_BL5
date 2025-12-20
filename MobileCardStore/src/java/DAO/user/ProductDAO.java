package DAO.user;

import DAO.DBConnection;
import Models.Provider;
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
 * Handles all database operations related to products from product_storage
 */
public class ProductDAO {
    
    /**
     * Get all product groups from product_storage (grouped by product_code and provider_id)
     */
    public List<ProductDisplay> getAllProductGroups() throws SQLException {
        List<ProductDisplay> products = new ArrayList<>();
        String sql = """
            SELECT 
                product_code,
                product_name,
                provider_id,
                provider_name,
                MAX(price) as price,
                MAX(purchase_price) as purchase_price,
                COUNT(*) as available_count,
                MAX(status) as status
            FROM product_storage
            WHERE is_deleted = 0 AND status = 'AVAILABLE'
            GROUP BY product_code, product_name, provider_id, provider_name
            ORDER BY provider_name, product_code
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                products.add(mapResultSetToProductDisplay(rs));
            }
        }
        return products;
    }
    
    /**
     * Get product group by product_code and provider_id
     * Query from provider_storage first, then check available stock in product_storage
     */
    public ProductDisplay getProductByCode(String productCode, int providerId) throws SQLException {
        // Query từ provider_storage để lấy thông tin sản phẩm
        String sql = """
            SELECT 
                ps.provider_storage_id,
                ps.provider_id,
                ps.product_code,
                ps.product_name,
                ps.price,
                ps.purchase_price,
                ps.available_quantity,
                pr.provider_name,
                COALESCE(pr.provider_type, 'TEL') as provider_type,
                pr.status as provider_status
            FROM provider_storage ps
            LEFT JOIN providers pr ON ps.provider_id = pr.provider_id AND pr.is_deleted = 0
            WHERE ps.product_code = ? AND ps.provider_id = ? AND ps.is_deleted = 0 AND ps.status = 'ACTIVE'
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
                    
                    // Tính available_count từ product_storage
                    int availableCount = getAvailableStock(productCode, providerId);
                    product.setAvailableCount(availableCount);
                    product.setStatus(availableCount > 0 ? "ACTIVE" : "INACTIVE");
                    
                    return product;
                }
            }
        }
        return null;
    }
    
    /**
     * Search and filter products from product_storage with pagination
     */
    public List<ProductDisplay> searchAndFilterProducts(String searchKeyword, int providerId, 
                                                  String providerType, BigDecimal minPrice, 
                                                  BigDecimal maxPrice, String sortBy, 
                                                  String sortOrder, int page, int pageSize) throws SQLException {
        List<ProductDisplay> products = new ArrayList<>();
        
        // Build WHERE clause - only filter by is_deleted, show all statuses
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE ps.is_deleted = 0 ");
        
        List<Object> params = new ArrayList<>();
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            whereClause.append("AND (ps.product_name LIKE ? OR ps.product_code LIKE ?) ");
            String searchPattern = "%" + searchKeyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (providerId > 0) {
            whereClause.append("AND ps.provider_id = ? ");
            params.add(providerId);
        }
        
        if (providerType != null && !providerType.isEmpty() && !providerType.equals("ALL")) {
            whereClause.append("AND EXISTS (SELECT 1 FROM providers pr WHERE pr.provider_id = ps.provider_id AND pr.provider_type = ?) ");
            params.add(providerType);
        }
        
        if (minPrice != null) {
            whereClause.append("AND ps.price >= ? ");
            params.add(minPrice);
        }
        
        if (maxPrice != null) {
            whereClause.append("AND ps.price <= ? ");
            params.add(maxPrice);
        }
        
        // Build ORDER BY clause
        // Note: When using GROUP BY, ORDER BY must use aggregate functions or columns in GROUP BY
        String orderBy = "ps.provider_name, ps.product_code";
        if (sortBy != null && !sortBy.isEmpty()) {
            switch (sortBy.toLowerCase()) {
                case "name":
                    orderBy = "ps.product_name"; // OK - in GROUP BY
                    break;
                case "price":
                    orderBy = "MAX(ps.price)"; // Must use aggregate function
                    break;
                case "created_at":
                    orderBy = "MAX(ps.created_at)"; // Must use aggregate function
                    break;
                default:
                    orderBy = "ps.provider_name, ps.product_code"; // OK - in GROUP BY
            }
        }
        
        String order = (sortOrder != null && sortOrder.equalsIgnoreCase("DESC")) ? "DESC" : "ASC";
        
        // Build SQL query with GROUP BY (without product_status to avoid errors if table doesn't exist)
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT ");
        sqlBuilder.append("    ps.product_code, ");
        sqlBuilder.append("    ps.product_name, ");
        sqlBuilder.append("    ps.provider_id, ");
        sqlBuilder.append("    ps.provider_name, ");
        sqlBuilder.append("    MAX(ps.price) as price, ");
        sqlBuilder.append("    MAX(ps.purchase_price) as purchase_price, ");
        sqlBuilder.append("    COUNT(*) as available_count, ");
        sqlBuilder.append("    COALESCE(pr.provider_type, 'TEL') as provider_type ");
        sqlBuilder.append("FROM product_storage ps ");
        sqlBuilder.append("LEFT JOIN providers pr ON ps.provider_id = pr.provider_id AND pr.is_deleted = 0 AND pr.status = 'ACTIVE' ");
        sqlBuilder.append(whereClause.toString());
        sqlBuilder.append("GROUP BY ps.product_code, ps.product_name, ps.provider_id, ps.provider_name, pr.provider_type ");
        sqlBuilder.append("HAVING COUNT(CASE WHEN ps.status = 'AVAILABLE' THEN 1 END) > 0 ");
        sqlBuilder.append("ORDER BY ").append(orderBy).append(" ").append(order).append(" ");
        sqlBuilder.append("LIMIT ? OFFSET ?");
        
        String sql = sqlBuilder.toString();
        
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
                    ProductDisplay product = mapResultSetToProductDisplay(rs);
                    // Set provider type from result set if available
                    if (rs.getObject("provider_type") != null) {
                        product.setProviderType(rs.getString("provider_type"));
                    }
                    products.add(product);
                }
            }
        }
        return products;
    }
    
    /**
     * Count total product groups matching search/filter criteria (for pagination)
     */
    public int countProducts(String searchKeyword, int providerId, String providerType, 
                            BigDecimal minPrice, BigDecimal maxPrice) throws SQLException {
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE ps.is_deleted = 0 AND ps.status = 'AVAILABLE' ");
        
        List<Object> params = new ArrayList<>();
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            whereClause.append("AND (ps.product_name LIKE ? OR ps.product_code LIKE ?) ");
            String searchPattern = "%" + searchKeyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (providerId > 0) {
            whereClause.append("AND ps.provider_id = ? ");
            params.add(providerId);
        }
        
        if (providerType != null && !providerType.isEmpty() && !providerType.equals("ALL")) {
            whereClause.append("AND EXISTS (SELECT 1 FROM providers pr WHERE pr.provider_id = ps.provider_id AND pr.provider_type = ?) ");
            params.add(providerType);
        }
        
        if (minPrice != null) {
            whereClause.append("AND ps.price >= ? ");
            params.add(minPrice);
        }
        
        if (maxPrice != null) {
            whereClause.append("AND ps.price <= ? ");
            params.add(maxPrice);
        }
        
        String sql = """
            SELECT COUNT(DISTINCT CONCAT(ps.product_code, '-', ps.provider_id)) as total
            FROM product_storage ps
            LEFT JOIN providers pr ON ps.provider_id = pr.provider_id AND pr.is_deleted = 0 AND pr.status = 'ACTIVE'
            """ + whereClause.toString();
        
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
     * Get available stock count for a product group (by product_code and provider_id)
     */
    public int getAvailableStock(String productCode, int providerId) throws SQLException {
        String sql = """
            SELECT COUNT(*) as count
            FROM product_storage
            WHERE product_code = ? AND provider_id = ? AND status = 'AVAILABLE' AND is_deleted = 0
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
    
    /**
     * Get product_id from product_code and provider_id
     * Returns the first product_id found in product_storage for the given product_code and provider_id
     */
    public int getProductId(String productCode, int providerId) throws SQLException {
        String sql = """
            SELECT DISTINCT product_id
            FROM product_storage
            WHERE product_code = ? AND provider_id = ? AND is_deleted = 0
            LIMIT 1
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, productCode);
            ps.setInt(2, providerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("product_id");
                }
            }
        }
        return 0; // Return 0 if not found
    }
    
    /**
     * Get all active providers for filter dropdown
     */
    public List<Provider> getAllProviders() throws SQLException {
        List<Provider> providers = new ArrayList<>();
        String sql = "SELECT provider_id, provider_name, provider_type, status FROM providers WHERE is_deleted = 0 AND status = 'ACTIVE' ORDER BY provider_name";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Provider provider = new Provider();
                provider.setProviderId(rs.getInt("provider_id"));
                provider.setProviderName(rs.getString("provider_name"));
                provider.setProviderType(rs.getString("provider_type"));
                // image_url không có trong providers table, sẽ dùng getProviderImageUrl() từ ProductDisplay
                provider.setImageUrl(null);
                provider.setStatus(rs.getString("status"));
                providers.add(provider);
            }
        }
        return providers;
    }
    
    /**
     * Map ResultSet to ProductDisplay object
     */
    private ProductDisplay mapResultSetToProductDisplay(ResultSet rs) throws SQLException {
        ProductDisplay product = new ProductDisplay();
        product.setProductCode(rs.getString("product_code"));
        product.setProductName(rs.getString("product_name"));
        product.setProviderId(rs.getInt("provider_id"));
        product.setProviderName(rs.getString("provider_name"));
        
        if (rs.getObject("price") != null) {
            product.setPrice(rs.getBigDecimal("price"));
        }
        if (rs.getObject("purchase_price") != null) {
            product.setPurchasePrice(rs.getBigDecimal("purchase_price"));
        }
        
        product.setAvailableCount(rs.getInt("available_count"));
        
        // Set status based on available_count: if available_count > 0 then ACTIVE, else INACTIVE
        int availableCount = rs.getInt("available_count");
        product.setStatus(availableCount > 0 ? "ACTIVE" : "INACTIVE");
        
        // Provider type should be set from the query result, not here
        // This method is called after provider_type is already in the result set
        
        return product;
    }

    /**
     * Get products grouped by provider for HomePage
     */
    public Map<Provider, List<ProductDisplay>> getProductsGroupedByProvider() throws SQLException {
        Map<Provider, List<ProductDisplay>> result = new LinkedHashMap<>();

        // First check if there's any data in product_storage
        String checkSql = "SELECT COUNT(*) as cnt FROM product_storage WHERE is_deleted = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("cnt") == 0) {
                System.out.println("ProductDAO: No data in product_storage table");
                return result; // Return empty map
            }
        }

        String sql = """
            SELECT 
                ps.product_code,
                ps.product_name,
                ps.provider_id,
                ps.provider_name,
                MAX(ps.price) as price,
                MAX(ps.purchase_price) as purchase_price,
                COUNT(*) as available_count,
                COALESCE(pr.provider_type, 'TEL') as provider_type
            FROM product_storage ps
            LEFT JOIN providers pr ON ps.provider_id = pr.provider_id AND pr.is_deleted = 0 AND pr.status = 'ACTIVE'
            WHERE ps.is_deleted = 0 AND ps.status = 'AVAILABLE'
            GROUP BY ps.product_code, ps.product_name, ps.provider_id, ps.provider_name, pr.provider_type
            HAVING COUNT(CASE WHEN ps.status = 'AVAILABLE' THEN 1 END) > 0
            ORDER BY COALESCE(pr.provider_type, 'TEL'), ps.provider_name, MAX(ps.price) ASC
            """;

        System.out.println("ProductDAO: Executing query: " + sql);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                // Extract provider info
                int providerId = rs.getInt("provider_id");
                String providerName = rs.getString("provider_name");
                String providerType = rs.getString("provider_type");
                if (providerType == null) {
                    providerType = "TEL"; // Default
                }

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
                    result.put(providerKey, new ArrayList<>());
                }

                // Create ProductDisplay
                ProductDisplay product = new ProductDisplay();
                product.setProductCode(rs.getString("product_code"));
                product.setProductName(rs.getString("product_name"));
                product.setProviderId(providerId);
                product.setProviderName(providerName);
                product.setProviderType(providerType);
                
                if (rs.getObject("price") != null) {
                    product.setPrice(rs.getBigDecimal("price"));
                }
                if (rs.getObject("purchase_price") != null) {
                    product.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                }
                
                product.setAvailableCount(rs.getInt("available_count"));
                
                // Try to get status from product_status table
                try (Connection conn2 = DBConnection.getConnection()) {
                    String statusSql = "SELECT status FROM product_status WHERE product_code = ? AND provider_id = ?";
                    try (PreparedStatement statusPs = conn2.prepareStatement(statusSql)) {
                        statusPs.setString(1, rs.getString("product_code"));
                        statusPs.setInt(2, providerId);
                        try (ResultSet statusRs = statusPs.executeQuery()) {
                            if (statusRs.next()) {
                                String status = statusRs.getString("status");
                                product.setStatus(status);
                                // Only add ACTIVE products
                                if (!"ACTIVE".equals(status)) {
                                    continue; // Skip this product
                                }
                            } else {
                                // No status in product_status, calculate from available_count
                                int availableCount = rs.getInt("available_count");
                                product.setStatus(availableCount > 0 ? "ACTIVE" : "INACTIVE");
                                if (availableCount == 0) {
                                    continue; // Skip inactive products
                                }
                            }
                        }
                    }
                } catch (SQLException e) {
                    // Table doesn't exist, calculate from available_count
                    int availableCount = rs.getInt("available_count");
                    product.setStatus(availableCount > 0 ? "ACTIVE" : "INACTIVE");
                    if (availableCount == 0) {
                        continue; // Skip inactive products
                    }
                }

                // Add to provider's product list
                result.get(providerKey).add(product);
            }
            
            System.out.println("ProductDAO: Processed " + rowCount + " rows, created " + result.size() + " provider groups");
        }

        return result;
    }
    
    /**
     * Get related products by same provider (excluding current product)
     */
    public List<ProductDisplay> getRelatedProducts(String currentProductCode, int currentProviderId, int providerId, int limit) throws SQLException {
        List<ProductDisplay> products = new ArrayList<>();
        String sql = """
            SELECT 
                ps.product_code,
                ps.product_name,
                ps.provider_id,
                ps.provider_name,
                MAX(ps.price) as price,
                MAX(ps.purchase_price) as purchase_price,
                COUNT(*) as available_count,
                MAX(ps.status) as status,
                pr.provider_type
            FROM product_storage ps
            INNER JOIN providers pr ON ps.provider_id = pr.provider_id
            WHERE ps.is_deleted = 0 AND ps.status = 'AVAILABLE'
              AND pr.is_deleted = 0 AND pr.status = 'ACTIVE'
              AND ps.provider_id = ?
              AND NOT (ps.product_code = ? AND ps.provider_id = ?)
            GROUP BY ps.product_code, ps.product_name, ps.provider_id, ps.provider_name, pr.provider_type
            ORDER BY MAX(ps.created_at) DESC
            LIMIT ?
            """;
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, providerId);
            ps.setString(2, currentProductCode);
            ps.setInt(3, currentProviderId);
            ps.setInt(4, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductDisplay product = new ProductDisplay();
                    product.setProductCode(rs.getString("product_code"));
                    product.setProductName(rs.getString("product_name"));
                    product.setProviderId(rs.getInt("provider_id"));
                    product.setProviderName(rs.getString("provider_name"));
                    product.setProviderType(rs.getString("provider_type"));
                    
                    if (rs.getObject("price") != null) {
                        product.setPrice(rs.getBigDecimal("price"));
                    }
                    if (rs.getObject("purchase_price") != null) {
                        product.setPurchasePrice(rs.getBigDecimal("purchase_price"));
                    }
                    
                    product.setAvailableCount(rs.getInt("available_count"));
                    
                    if (rs.getObject("status") != null) {
                        product.setStatus(rs.getString("status"));
                    }
                    
                    products.add(product);
                }
            }
        }
        return products;
    }
}

package Models;

import java. math.BigDecimal;

/**
 * DTO class for displaying products with available stock count on Homepage.
 * This is NOT a database entity - it combines Product + Provider + Stock count for display.
 */
public class ProductWithStock {

    // Product fields
    private int productId;
    private String productName;
    private BigDecimal price;
    private String description;
    private String imageUrl;

    // Provider fields (denormalized for display)
    private int providerId;
    private String providerName;
    private String providerType;
    private String providerImageUrl;

    // Computed field
    private int availableCount;

    // Constructors
    public ProductWithStock() {
    }

    // Getters and Setters
    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getProviderId() {
        return providerId;
    }

    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderType() {
        return providerType;
    }

    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }

    public String getProviderImageUrl() {
        return providerImageUrl;
    }

    public void setProviderImageUrl(String providerImageUrl) {
        this.providerImageUrl = providerImageUrl;
    }

    public int getAvailableCount() {
        return availableCount;
    }

    public void setAvailableCount(int availableCount) {
        this.availableCount = availableCount;
    }

    /**
     * Check if product is in stock
     */
    public boolean isInStock() {
        return availableCount > 0;
    }
}
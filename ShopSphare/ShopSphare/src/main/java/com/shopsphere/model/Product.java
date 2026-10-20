package com.shopsphere.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long productId;
    private Integer categoryId;
    private String sku;
    private String name;
    private String slug;
    private String description;
    private String imageUrl;
    private BigDecimal price;
    private BigDecimal salePrice;
    private Integer stockQuantity;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Product() {
    }

    public Product(Long productId, Integer categoryId, String sku, String name, String slug,
                   String description, BigDecimal price, BigDecimal salePrice, Integer stockQuantity,
                   String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this(productId, categoryId, sku, name, slug, description, null, price, salePrice, stockQuantity, status, createdAt, updatedAt);
    }

    public Product(Long productId, Integer categoryId, String sku, String name, String slug,
                   String description, String imageUrl, BigDecimal price, BigDecimal salePrice, Integer stockQuantity,
                   String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.productId = productId;
        this.categoryId = categoryId;
        this.sku = sku;
        this.name = name;
        this.slug = slug;
        this.description = description;
        this.imageUrl = imageUrl;
        this.price = price;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
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

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(BigDecimal salePrice) {
        this.salePrice = salePrice;
    }

    public Integer getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(Integer stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getDiscountPercentage() {
        if (price != null && salePrice != null && price.compareTo(BigDecimal.ZERO) > 0 && salePrice.compareTo(price) < 0) {
            return price.subtract(salePrice)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(price, 0, RoundingMode.HALF_UP)
                        .intValue();
        }
        return 0;
    }
}

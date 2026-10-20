package com.shopsphere.service;

import com.shopsphere.dao.CartDAO;
import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.Product;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class CartService {

    private final CartDAO cartDAO;
    private final ProductDAO productDAO;

    public CartService() {
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }

    public CartService(CartDAO cartDAO, ProductDAO productDAO) {
        this.cartDAO = cartDAO;
        this.productDAO = productDAO;
    }

    public boolean addToCart(Long userId, Long productId, int quantity) throws SQLException {
        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException("Valid user ID is required to add items to cart.");
        }
        if (productId == null || productId <= 0) {
            throw new IllegalArgumentException("Invalid product ID.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero.");
        }

        // Validate product exists, is active, and is in stock
        Optional<Product> productOpt = productDAO.findById(productId);
        if (productOpt.isEmpty()) {
            throw new IllegalArgumentException("Product not found.");
        }

        Product product = productOpt.get();
        if (!"active".equalsIgnoreCase(product.getStatus())) {
            throw new IllegalStateException("Product '" + product.getName() + "' is not currently available for purchase.");
        }

        if (product.getStockQuantity() < 1) {
            throw new IllegalStateException("Product '" + product.getName() + "' is out of stock.");
        }

        // Check if existing quantity in cart + requested quantity exceeds stock
        Optional<CartItem> existingItem = cartDAO.findByUserAndProduct(userId, productId);
        int currentQtyInCart = existingItem.map(CartItem::getQuantity).orElse(0);
        int totalRequested = currentQtyInCart + quantity;

        if (totalRequested > product.getStockQuantity()) {
            throw new IllegalStateException("Cannot add " + quantity + " more. Only " + 
                product.getStockQuantity() + " units available (" + currentQtyInCart + " already in your cart).");
        }

        CartItem item = new CartItem();
        item.setUserId(userId);
        item.setProductId(productId);
        item.setQuantity(quantity);

        return cartDAO.addOrUpdateItem(item);
    }

    public List<CartItem> getCartItems(Long userId) throws SQLException {
        if (userId == null || userId <= 0) {
            return List.of();
        }
        return cartDAO.findByUserId(userId);
    }

    public Map<Long, Product> getProductMapForCart(List<CartItem> items) throws SQLException {
        Map<Long, Product> map = new HashMap<>();
        if (items == null) {
            return map;
        }
        for (CartItem item : items) {
            if (!map.containsKey(item.getProductId())) {
                Optional<Product> p = productDAO.findById(item.getProductId());
                p.ifPresent(product -> map.put(item.getProductId(), product));
            }
        }
        return map;
    }

    public boolean updateQuantity(Long cartId, Long userId, int newQuantity) throws SQLException {
        if (cartId == null || cartId <= 0 || userId == null || userId <= 0) {
            throw new IllegalArgumentException("Invalid cart item or user reference.");
        }
        if (newQuantity <= 0) {
            return deleteItem(cartId, userId);
        }

        // Verify cart item exists and belongs to user
        Optional<CartItem> itemOpt = cartDAO.findById(cartId);
        if (itemOpt.isEmpty() || !userId.equals(itemOpt.get().getUserId())) {
            throw new IllegalArgumentException("Cart item not found or does not belong to user.");
        }

        CartItem item = itemOpt.get();
        Optional<Product> productOpt = productDAO.findById(item.getProductId());
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            if (newQuantity > product.getStockQuantity()) {
                throw new IllegalStateException("Cannot update quantity to " + newQuantity + 
                    ". Only " + product.getStockQuantity() + " units in stock.");
            }
        }

        return cartDAO.updateQuantity(cartId, userId, newQuantity);
    }

    public boolean deleteItem(Long cartId, Long userId) throws SQLException {
        if (cartId == null || cartId <= 0 || userId == null || userId <= 0) {
            return false;
        }
        return cartDAO.deleteItem(cartId, userId);
    }

    public boolean clearCart(Long userId) throws SQLException {
        if (userId == null || userId <= 0) {
            return false;
        }
        return cartDAO.clearCart(userId);
    }

    public int getTotalItemCount(Long userId) throws SQLException {
        if (userId == null || userId <= 0) {
            return 0;
        }
        return cartDAO.getTotalItemCount(userId);
    }

    public void mergeGuestCart(Long userId, List<CartItem> guestItems) throws SQLException {
        if (userId == null || userId <= 0 || guestItems == null || guestItems.isEmpty()) {
            return;
        }
        for (CartItem guestItem : guestItems) {
            try {
                addToCart(userId, guestItem.getProductId(), guestItem.getQuantity() != null ? guestItem.getQuantity() : 1);
            } catch (Exception ignored) {
                // Ignore items that can no longer be added
            }
        }
    }
}

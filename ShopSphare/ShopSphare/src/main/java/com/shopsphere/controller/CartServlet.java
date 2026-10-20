package com.shopsphere.controller;

import com.shopsphere.model.CartItem;
import com.shopsphere.model.Product;
import com.shopsphere.model.User;
import com.shopsphere.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart", "/cart/*"})
public class CartServlet extends HttpServlet {

    private final CartService cartService;

    public CartServlet() {
        this.cartService = new CartService();
    }

    public CartServlet(CartService cartService) {
        this.cartService = cartService;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");

        // Move flash messages from session to request attributes
        String flashMessage = (String) session.getAttribute("cartMessage");
        if (flashMessage != null) {
            req.setAttribute("cartMessage", flashMessage);
            session.removeAttribute("cartMessage");
        }
        String flashError = (String) session.getAttribute("cartError");
        if (flashError != null) {
            req.setAttribute("cartError", flashError);
            session.removeAttribute("cartError");
        }

        try {
            List<CartItem> cartItems;
            Map<Long, Product> itemProductMap;

            if (user != null) {
                cartItems = cartService.getCartItems(user.getUserId());
                itemProductMap = cartService.getProductMapForCart(cartItems);
                int totalCount = cartService.getTotalItemCount(user.getUserId());
                session.setAttribute("cartCount", totalCount);
            } else {
                @SuppressWarnings("unchecked")
                List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                if (guestCart == null) {
                    guestCart = new ArrayList<>();
                }
                cartItems = guestCart;
                itemProductMap = cartService.getProductMapForCart(cartItems);
                int totalCount = cartItems.stream().mapToInt(i -> i.getQuantity() != null ? i.getQuantity() : 1).sum();
                session.setAttribute("cartCount", totalCount);
            }

            req.setAttribute("cartItems", cartItems);
            req.setAttribute("itemProductMap", itemProductMap);

            if (getServletContext().getResource("/cart.jsp") != null) {
                req.getRequestDispatcher("/cart.jsp").forward(req, resp);
            } else if (getServletContext().getResource("/WEB-INF/views/cart.jsp") != null) {
                req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
            } else {
                renderFallbackCart(resp, cartItems, itemProductMap);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading shopping cart", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");

        String action = req.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "add";
        }

        try {
            switch (action.toLowerCase()) {
                case "add" -> handleAddToCart(req, session, user);
                case "update" -> handleUpdateQuantity(req, session, user);
                case "delete" -> handleDeleteItem(req, session, user);
                case "clear" -> handleClearCart(session, user);
                default -> session.setAttribute("cartError", "Unrecognized cart action.");
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("cartError", e.getMessage());
        } catch (SQLException e) {
            session.setAttribute("cartError", "Database error updating cart: " + e.getMessage());
        }

        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isBlank() && !redirect.startsWith("http")) {
            resp.sendRedirect(redirect);
        } else {
            resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }

    private void handleAddToCart(HttpServletRequest req, HttpSession session, User user) throws SQLException {
        String productIdStr = req.getParameter("productId");
        String quantityStr = req.getParameter("quantity");

        if (productIdStr == null || productIdStr.isBlank()) {
            throw new IllegalArgumentException("Product ID is required.");
        }

        long productId;
        try {
            productId = Long.parseLong(productIdStr.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid product ID format.");
        }

        int quantity = 1;
        if (quantityStr != null && !quantityStr.isBlank()) {
            try {
                quantity = Math.max(1, Integer.parseInt(quantityStr.trim()));
            } catch (NumberFormatException e) {
                quantity = 1;
            }
        }

        if (user != null) {
            cartService.addToCart(user.getUserId(), productId, quantity);
            session.setAttribute("cartCount", cartService.getTotalItemCount(user.getUserId()));
        } else {
            // Guest cart in session
            @SuppressWarnings("unchecked")
            List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
            if (guestCart == null) {
                guestCart = new ArrayList<>();
                session.setAttribute("guestCart", guestCart);
            }

            boolean found = false;
            for (CartItem item : guestCart) {
                if (item.getProductId().equals(productId)) {
                    item.setQuantity(item.getQuantity() + quantity);
                    found = true;
                    break;
                }
            }
            if (!found) {
                CartItem newItem = new CartItem();
                newItem.setCartId((long) (guestCart.size() + 1));
                newItem.setProductId(productId);
                newItem.setQuantity(quantity);
                guestCart.add(newItem);
            }
            int totalCount = guestCart.stream().mapToInt(i -> i.getQuantity() != null ? i.getQuantity() : 1).sum();
            session.setAttribute("cartCount", totalCount);
        }

        session.setAttribute("cartMessage", "Item added to cart successfully!");
    }

    private void handleUpdateQuantity(HttpServletRequest req, HttpSession session, User user) throws SQLException {
        String cartIdStr = req.getParameter("cartId");
        String quantityStr = req.getParameter("quantity");

        if (cartIdStr == null || cartIdStr.isBlank() || quantityStr == null || quantityStr.isBlank()) {
            throw new IllegalArgumentException("Cart ID and quantity are required.");
        }

        long cartId;
        int quantity;
        try {
            cartId = Long.parseLong(cartIdStr.trim());
            quantity = Integer.parseInt(quantityStr.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid cart item format.");
        }

        if (user != null) {
            cartService.updateQuantity(cartId, user.getUserId(), quantity);
            session.setAttribute("cartCount", cartService.getTotalItemCount(user.getUserId()));
        } else {
            @SuppressWarnings("unchecked")
            List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
            if (guestCart != null) {
                if (quantity <= 0) {
                    guestCart.removeIf(i -> i.getCartId().equals(cartId));
                } else {
                    for (CartItem item : guestCart) {
                        if (item.getCartId().equals(cartId)) {
                            item.setQuantity(quantity);
                            break;
                        }
                    }
                }
                int totalCount = guestCart.stream().mapToInt(i -> i.getQuantity() != null ? i.getQuantity() : 1).sum();
                session.setAttribute("cartCount", totalCount);
            }
        }

        session.setAttribute("cartMessage", "Cart updated successfully!");
    }

    private void handleDeleteItem(HttpServletRequest req, HttpSession session, User user) throws SQLException {
        String cartIdStr = req.getParameter("cartId");
        if (cartIdStr == null || cartIdStr.isBlank()) {
            throw new IllegalArgumentException("Cart ID is required.");
        }

        long cartId;
        try {
            cartId = Long.parseLong(cartIdStr.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid cart item format.");
        }

        if (user != null) {
            cartService.deleteItem(cartId, user.getUserId());
            session.setAttribute("cartCount", cartService.getTotalItemCount(user.getUserId()));
        } else {
            @SuppressWarnings("unchecked")
            List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
            if (guestCart != null) {
                guestCart.removeIf(i -> i.getCartId().equals(cartId));
                int totalCount = guestCart.stream().mapToInt(i -> i.getQuantity() != null ? i.getQuantity() : 1).sum();
                session.setAttribute("cartCount", totalCount);
            }
        }

        session.setAttribute("cartMessage", "Item removed from cart.");
    }

    private void handleClearCart(HttpSession session, User user) throws SQLException {
        if (user != null) {
            cartService.clearCart(user.getUserId());
        } else {
            session.removeAttribute("guestCart");
        }
        session.setAttribute("cartCount", 0);
        session.setAttribute("cartMessage", "Cart cleared.");
    }

    private void renderFallbackCart(HttpServletResponse resp, List<CartItem> items, Map<Long, Product> productMap) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        var out = resp.getWriter();
        out.println("<!DOCTYPE html><html><head><title>Shopping Cart</title></head><body>");
        out.println("<h2>Your Shopping Cart</h2>");
        if (items.isEmpty()) {
            out.println("<p>Your cart is empty.</p>");
        } else {
            out.println("<ul>");
            for (CartItem item : items) {
                Product p = productMap.get(item.getProductId());
                String name = (p != null) ? p.getName() : "Product #" + item.getProductId();
                out.println("<li>" + name + " x " + item.getQuantity() + "</li>");
            }
            out.println("</ul>");
        }
        out.println("<a href='products'>&larr; Continue Shopping</a>");
        out.println("</body></html>");
    }
}

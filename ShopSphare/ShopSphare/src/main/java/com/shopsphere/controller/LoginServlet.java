package com.shopsphere.controller;

import com.shopsphere.dao.UserDAO;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.User;
import com.shopsphere.service.CartService;
import com.shopsphere.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO;
    private final CartService cartService;

    public LoginServlet() {
        this.userDAO = new UserDAO();
        this.cartService = new CartService();
    }

    public LoginServlet(UserDAO userDAO, CartService cartService) {
        this.userDAO = userDAO;
        this.cartService = cartService;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        String redirect = req.getParameter("redirect");
        req.setAttribute("redirectUrl", redirect);
        
        // Forward to JSP or render fallback form if view not present
        if (getServletContext().getResource("/login.jsp") != null) {
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else if (getServletContext().getResource("/WEB-INF/views/login.jsp") != null) {
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        } else {
            resp.setContentType("text/html;charset=UTF-8");
            resp.getWriter().println("<!DOCTYPE html><html><head><title>ShopSphere - Login</title></head><body>" +
                "<h2>Login to ShopSphere</h2>" +
                "<form method='POST' action='" + req.getContextPath() + "/login'>" +
                "<input type='hidden' name='redirect' value='" + (redirect != null ? redirect : "") + "'/>" +
                "<p><label>Email: <input type='email' name='email' required/></label></p>" +
                "<p><label>Password: <input type='password' name='password' required/></label></p>" +
                "<p><button type='submit'>Sign In</button></p>" +
                "</form>" +
                "<p>Don't have an account? <a href='" + req.getContextPath() + "/register'>Register here</a></p>" +
                "</body></html>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String redirect = req.getParameter("redirect");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Email and password are required.");
            return;
        }

        try {
            Optional<User> userOpt = userDAO.findByEmail(email.trim());
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                if ("active".equalsIgnoreCase(user.getStatus()) && 
                    PasswordUtil.verifyPassword(password, user.getPasswordHash())) {

                    // Successful authentication: create session & prevent session fixation
                    HttpSession session = req.getSession(true);
                    req.changeSessionId();
                    session.setAttribute("user", user);

                    // Process pending Add to Cart action if saved before login
                    String pendingProductId = (String) session.getAttribute("pendingCartProductId");
                    String pendingQuantity = (String) session.getAttribute("pendingCartQuantity");
                    if (pendingProductId != null) {
                        try {
                            long pId = Long.parseLong(pendingProductId);
                            int qty = (pendingQuantity != null) ? Integer.parseInt(pendingQuantity) : 1;
                            cartService.addToCart(user.getUserId(), pId, qty);
                            session.setAttribute("cartMessage", "Product added to cart!");
                        } catch (Exception ignored) {
                        }
                        session.removeAttribute("pendingCartProductId");
                        session.removeAttribute("pendingCartQuantity");
                    }

                    // Merge guest session cart items into user's DB cart
                    @SuppressWarnings("unchecked")
                    List<CartItem> guestCart = (List<CartItem>) session.getAttribute("guestCart");
                    if (guestCart != null && !guestCart.isEmpty()) {
                        try {
                            cartService.mergeGuestCart(user.getUserId(), guestCart);
                        } catch (Exception ignored) {
                        }
                        session.removeAttribute("guestCart");
                    }

                    // Update authoritative cart count in session
                    try {
                        session.setAttribute("cartCount", cartService.getTotalItemCount(user.getUserId()));
                    } catch (Exception ignored) {
                    }

                    if (redirect != null && !redirect.trim().isEmpty() && !redirect.startsWith("http")) {
                        resp.sendRedirect(redirect);
                    } else if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/products");
                    }
                    return;
                }
            }

            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            req.setAttribute("error", "Invalid email or password.");
            doGet(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error during authentication", e);
        }
    }
}


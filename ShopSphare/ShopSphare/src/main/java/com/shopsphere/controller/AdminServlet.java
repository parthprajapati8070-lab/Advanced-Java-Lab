package com.shopsphere.controller;

import com.shopsphere.dao.OrderDAO;
import com.shopsphere.dao.ProductDAO;
import com.shopsphere.dao.UserDAO;
import com.shopsphere.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminServlet extends HttpServlet {

    private final ProductDAO productDAO;
    private final OrderDAO orderDAO;
    private final UserDAO userDAO;

    public AdminServlet() {
        this.productDAO = new ProductDAO();
        this.orderDAO = new OrderDAO();
        this.userDAO = new UserDAO();
    }

    public AdminServlet(ProductDAO productDAO, OrderDAO orderDAO, UserDAO userDAO) {
        this.productDAO = productDAO;
        this.orderDAO = orderDAO;
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
            return;
        }

        try {
            int productCount = productDAO.findAllActive(100, 0).size();
            int userCount = userDAO.findAll().size();
            int orderCount = orderDAO.countAll();

            req.setAttribute("productCount", productCount);
            req.setAttribute("userCount", userCount);
            req.setAttribute("orderCount", orderCount);

            if (getServletContext().getResource("/admin-dashboard.jsp") != null) {
                req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, resp);
            } else {
                renderFallbackAdmin(resp, user, productCount, userCount, orderCount);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading admin dashboard", e);
        }
    }

    private void renderFallbackAdmin(HttpServletResponse resp, User user, int productCount, int userCount, int orderCount) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        var out = resp.getWriter();
        out.println("<!DOCTYPE html><html><head><title>Admin Dashboard - ShopSphere</title></head><body>");
        out.println("<h2>ShopSphere Administration Dashboard</h2>");
        out.println("<p>Logged in Administrator: " + user.getFirstName() + " " + user.getLastName() + " (" + user.getEmail() + ")</p>");
        out.println("<ul>");
        out.println("<li>Active Products: " + productCount + "</li>");
        out.println("<li>Registered Users: " + userCount + "</li>");
        out.println("<li>Total Orders: " + orderCount + "</li>");
        out.println("</ul>");
        out.println("<p><a href='products'>&larr; Return to Storefront</a></p>");
        out.println("</body></html>");
    }
}

package com.shopsphere.controller;

import com.shopsphere.dao.AddressDAO;
import com.shopsphere.dao.OrderDAO;
import com.shopsphere.model.Address;
import com.shopsphere.model.Order;
import com.shopsphere.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final AddressDAO addressDAO;
    private final OrderDAO orderDAO;

    public ProfileServlet() {
        this.addressDAO = new AddressDAO();
        this.orderDAO = new OrderDAO();
    }

    public ProfileServlet(AddressDAO addressDAO, OrderDAO orderDAO) {
        this.addressDAO = addressDAO;
        this.orderDAO = orderDAO;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=" + req.getRequestURI());
            return;
        }

        try {
            List<Address> addresses = addressDAO.findByUserId(user.getUserId());
            List<Order> orders = orderDAO.findByUserId(user.getUserId());

            req.setAttribute("user", user);
            req.setAttribute("addresses", addresses);
            req.setAttribute("orders", orders);

            if (getServletContext().getResource("/profile.jsp") != null) {
                req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            } else {
                renderFallbackProfile(resp, user, addresses.size(), orders.size());
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading user profile", e);
        }
    }

    private void renderFallbackProfile(HttpServletResponse resp, User user, int addrCount, int orderCount) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        var out = resp.getWriter();
        out.println("<!DOCTYPE html><html><head><title>My Profile - ShopSphere</title></head><body>");
        out.println("<h2>Customer Profile</h2>");
        out.println("<p>Name: " + user.getFirstName() + " " + user.getLastName() + "</p>");
        out.println("<p>Email: " + user.getEmail() + "</p>");
        out.println("<p>Saved Addresses: " + addrCount + "</p>");
        out.println("<p>Orders Placed: " + orderCount + "</p>");
        out.println("<a href='products'>Back to Products</a>");
        out.println("</body></html>");
    }
}

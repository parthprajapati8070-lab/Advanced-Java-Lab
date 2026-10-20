package com.shopsphere.controller;

import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.Order;
import com.shopsphere.model.OrderItem;
import com.shopsphere.model.Product;
import com.shopsphere.model.User;
import com.shopsphere.service.OrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/orders/*"})
public class OrderServlet extends HttpServlet {

    private final OrderService orderService;
    private final ProductDAO productDAO;

    public OrderServlet() {
        this.orderService = new OrderService();
        this.productDAO = new ProductDAO();
    }

    public OrderServlet(OrderService orderService, ProductDAO productDAO) {
        this.orderService = orderService;
        this.productDAO = productDAO;
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
            String pathInfo = req.getPathInfo();
            String orderIdParam = req.getParameter("id");
            Long selectedOrderId = null;

            if (pathInfo != null && pathInfo.length() > 1) {
                try {
                    selectedOrderId = Long.parseLong(pathInfo.substring(1));
                } catch (NumberFormatException ignored) {
                }
            } else if (orderIdParam != null && !orderIdParam.isBlank()) {
                try {
                    selectedOrderId = Long.parseLong(orderIdParam.trim());
                } catch (NumberFormatException ignored) {
                }
            }

            if (selectedOrderId != null) {
                Optional<Order> orderOpt = orderService.getOrderById(selectedOrderId);
                if (orderOpt.isPresent() && user.getUserId().equals(orderOpt.get().getUserId())) {
                    Order order = orderOpt.get();
                    List<OrderItem> items = orderService.getOrderItems(order.getOrderId());
                    Map<Long, Product> productMap = new HashMap<>();
                    for (OrderItem item : items) {
                        productDAO.findById(item.getProductId()).ifPresent(p -> productMap.put(item.getProductId(), p));
                    }
                    req.setAttribute("selectedOrder", order);
                    req.setAttribute("orderItems", items);
                    req.setAttribute("itemProductMap", productMap);
                }
            }

            List<Order> orders = orderService.getUserOrders(user.getUserId());
            req.setAttribute("orders", orders);

            if (getServletContext().getResource("/orders.jsp") != null) {
                req.getRequestDispatcher("/orders.jsp").forward(req, resp);
            } else {
                renderFallbackOrders(req, resp, orders);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading user orders", e);
        }
    }

    private void renderFallbackOrders(HttpServletRequest req, HttpServletResponse resp, List<Order> orders) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        var out = resp.getWriter();
        out.println("<!DOCTYPE html><html><head><title>My Orders - ShopSphere</title></head><body>");
        out.println("<h2>My Orders</h2>");
        if (orders.isEmpty()) {
            out.println("<p>You have not placed any orders yet.</p>");
        } else {
            out.println("<ul>");
            for (Order o : orders) {
                out.println("<li>Order #" + o.getOrderNumber() + " - $" + o.getTotalAmount() + " (" + o.getOrderStatus() + ")</li>");
            }
            out.println("</ul>");
        }
        out.println("<a href='" + req.getContextPath() + "/products'>Back to Products</a>");
        out.println("</body></html>");
    }
}

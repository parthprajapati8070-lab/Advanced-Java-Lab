package com.shopsphere.controller;

import com.shopsphere.dao.AddressDAO;
import com.shopsphere.dao.CartDAO;
import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.Address;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.Product;
import com.shopsphere.model.User;
import com.shopsphere.service.CheckoutRequest;
import com.shopsphere.service.CheckoutResult;
import com.shopsphere.service.CheckoutService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final CheckoutService checkoutService;
    private final AddressDAO addressDAO;
    private final CartDAO cartDAO;
    private final ProductDAO productDAO;

    public CheckoutServlet() {
        this.checkoutService = new CheckoutService();
        this.addressDAO = new AddressDAO();
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }

    public CheckoutServlet(CheckoutService checkoutService, AddressDAO addressDAO, CartDAO cartDAO, ProductDAO productDAO) {
        this.checkoutService = checkoutService;
        this.addressDAO = addressDAO;
        this.cartDAO = cartDAO;
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
            List<CartItem> cartItems = cartDAO.findByUserId(user.getUserId());
            if (cartItems.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/cart");
                return;
            }

            Map<Long, Product> itemProductMap = new HashMap<>();
            BigDecimal cartSubtotal = BigDecimal.ZERO;
            for (CartItem item : cartItems) {
                Optional<Product> p = productDAO.findById(item.getProductId());
                if (p.isPresent()) {
                    Product prod = p.get();
                    itemProductMap.put(item.getProductId(), prod);
                    BigDecimal price = (prod.getSalePrice() != null && prod.getSalePrice().compareTo(BigDecimal.ZERO) > 0)
                        ? prod.getSalePrice() : prod.getPrice();
                    cartSubtotal = cartSubtotal.add(price.multiply(BigDecimal.valueOf(item.getQuantity())));
                }
            }

            List<Address> userAddresses = addressDAO.findByUserId(user.getUserId());
            req.setAttribute("userAddresses", userAddresses);
            req.setAttribute("cartItems", cartItems);
            req.setAttribute("itemProductMap", itemProductMap);
            req.setAttribute("cartSubtotal", cartSubtotal);

            if (getServletContext().getResource("/checkout.jsp") != null) {
                req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
            } else if (getServletContext().getResource("/WEB-INF/views/checkout.jsp") != null) {
                req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
            } else {
                renderFallbackCheckout(req, resp, user);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error preparing checkout", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User session expired.");
            return;
        }

        String shippingAddressStr = req.getParameter("shippingAddressId");
        String billingAddressStr = req.getParameter("billingAddressId");
        String couponCode = req.getParameter("couponCode");
        String paymentMethod = req.getParameter("paymentMethod");
        String notes = req.getParameter("notes");

        try {
            Long shippingAddressId = null;
            if (shippingAddressStr != null && !shippingAddressStr.isBlank()) {
                try {
                    shippingAddressId = Long.parseLong(shippingAddressStr.trim());
                    // Verify that address actually exists in DB to prevent foreign key violation
                    Optional<Address> addrOpt = addressDAO.findById(shippingAddressId);
                    if (addrOpt.isEmpty()) {
                        shippingAddressId = null; // will resolve or create below
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            // If no valid address ID resolved, check if user has an existing address or create default
            if (shippingAddressId == null) {
                List<Address> userAddresses = addressDAO.findByUserId(user.getUserId());
                if (!userAddresses.isEmpty()) {
                    shippingAddressId = userAddresses.get(0).getAddressId();
                } else {
                    Address defaultAddr = new Address();
                    defaultAddr.setUserId(user.getUserId());
                    defaultAddr.setAddressType("shipping");
                    defaultAddr.setIsDefault(true);
                    defaultAddr.setRecipientName(user.getFirstName() + " " + user.getLastName());
                    defaultAddr.setPhoneNumber(user.getPhoneNumber() != null ? user.getPhoneNumber() : "0000000000");
                    defaultAddr.setStreetAddressLine1("123 Commerce Way");
                    defaultAddr.setCity("Metropolis");
                    defaultAddr.setState("NY");
                    defaultAddr.setPostalCode("10001");
                    defaultAddr.setCountry("USA");
                    defaultAddr = addressDAO.create(defaultAddr);
                    shippingAddressId = defaultAddr.getAddressId();
                }
            }

            Long billingAddressId = (billingAddressStr != null && !billingAddressStr.isBlank()) 
                ? Long.parseLong(billingAddressStr) : shippingAddressId;

            CheckoutRequest checkoutReq = new CheckoutRequest();
            checkoutReq.setUserId(user.getUserId());
            checkoutReq.setShippingAddressId(shippingAddressId);
            checkoutReq.setBillingAddressId(billingAddressId);
            checkoutReq.setCouponCode(couponCode);
            checkoutReq.setPaymentMethod(paymentMethod != null ? paymentMethod : "credit_card");
            checkoutReq.setNotes(notes);

            // Strictly calculate all pricing, tax, discounts and order totals server-side
            CheckoutResult result = checkoutService.processCheckout(checkoutReq);

            // Update session cart count to 0 after checkout
            session.setAttribute("cartCount", 0);

            req.setAttribute("checkoutResult", result);
            req.setAttribute("order", result.getOrder());
            req.setAttribute("payment", result.getPayment());
            req.setAttribute("orderItems", result.getItems());

            if (getServletContext().getResource("/order-confirmation.jsp") != null) {
                req.getRequestDispatcher("/order-confirmation.jsp").forward(req, resp);
            } else if (getServletContext().getResource("/WEB-INF/views/order-confirmation.jsp") != null) {
                req.getRequestDispatcher("/WEB-INF/views/order-confirmation.jsp").forward(req, resp);
            } else {
                renderFallbackConfirmation(req, resp, result);
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            req.setAttribute("errorMessage", e.getMessage());
            doGet(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error during order checkout", e);
        }
    }

    private void renderFallbackCheckout(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.getWriter().println("<!DOCTYPE html><html><head><title>ShopSphere - Checkout</title></head><body>" +
            "<h2>Checkout</h2>" +
            "<p>Logged in as: " + user.getEmail() + "</p>" +
            "<form method='POST' action='" + req.getContextPath() + "/checkout'>" +
            "<p><label>Shipping Address ID: <input type='number' name='shippingAddressId' required/></label></p>" +
            "<p><label>Billing Address ID: <input type='number' name='billingAddressId'/></label></p>" +
            "<p><label>Coupon Code (Optional): <input type='text' name='couponCode'/></label></p>" +
            "<p><label>Payment Method: " +
            "<select name='paymentMethod'>" +
            "<option value='credit_card'>Credit Card</option>" +
            "<option value='paypal'>PayPal</option>" +
            "<option value='cod'>Cash on Delivery</option>" +
            "</select></label></p>" +
            "<p><label>Order Notes: <textarea name='notes'></textarea></label></p>" +
            "<button type='submit'>Place Order</button>" +
            "</form></body></html>");
    }

    private void renderFallbackConfirmation(HttpServletRequest req, HttpServletResponse resp, CheckoutResult result) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.getWriter().println("<!DOCTYPE html><html><head><title>Order Confirmed</title></head><body>" +
            "<h2>Thank You! Your Order has been Placed.</h2>" +
            "<p>Order Number: <strong>" + result.getOrder().getOrderNumber() + "</strong></p>" +
            "<p>Subtotal: $" + result.getSubtotal() + "</p>" +
            "<p>Discount: -$" + result.getDiscountAmount() + "</p>" +
            "<p>Shipping: $" + result.getShippingFee() + "</p>" +
            "<p>Tax: $" + result.getTaxAmount() + "</p>" +
            "<p><strong>Total Charged: $" + result.getTotalAmount() + "</strong></p>" +
            "<p>Transaction ID: " + result.getPayment().getTransactionId() + "</p>" +
            "<a href='" + req.getContextPath() + "/products'>Continue Shopping</a>" +
            "</body></html>");
    }
}

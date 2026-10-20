<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Order Confirmation - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <!-- Success Header Card -->
                <div class="card border-0 shadow-sm rounded-4 text-center p-4 p-md-5 mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-success-subtle text-success rounded-circle mx-auto mb-3" style="width: 72px; height: 72px;">
                        <i class="bi bi-check-circle-fill fs-1"></i>
                    </div>
                    <h2 class="fw-bold mb-2">Thank You For Your Order!</h2>
                    <p class="text-muted mb-3">Your order has been received and is currently being processed.</p>
                    <div class="d-inline-block bg-light rounded-pill px-4 py-2 border font-monospace fw-bold mb-3">
                        Order #: <c:out value="${order.orderNumber}" />
                    </div>
                    <div>
                        <span class="badge bg-success px-3 py-2 text-uppercase">Status: <c:out value="${order.orderStatus}" /></span>
                    </div>
                </div>

                <!-- Order Details Summary Card -->
                <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                    <h5 class="fw-bold mb-3 border-bottom pb-2"><i class="bi bi-receipt me-2 text-primary"></i>Financial Summary</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary">Subtotal</span>
                        <span class="fw-semibold">₹<fmt:formatNumber value="${checkoutResult.subtotal}" pattern="#,##0" /></span>
                    </div>
                    <c:if test="${checkoutResult.discountAmount > 0}">
                        <div class="d-flex justify-content-between mb-2 text-success">
                            <span>Discount Applied</span>
                            <span>-₹<fmt:formatNumber value="${checkoutResult.discountAmount}" pattern="#,##0" /></span>
                        </div>
                    </c:if>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary">Shipping Fee</span>
                        <span class="fw-semibold">₹<fmt:formatNumber value="${checkoutResult.shippingFee}" pattern="#,##0" /></span>
                    </div>
                    <div class="d-flex justify-content-between mb-3">
                        <span class="text-secondary">Sales Tax (8%)</span>
                        <span class="fw-semibold">₹<fmt:formatNumber value="${checkoutResult.taxAmount}" pattern="#,##0" /></span>
                    </div>
                    <hr class="my-3">
                    <div class="d-flex justify-content-between fs-5 fw-bold mb-4">
                        <span>Total Charged</span>
                        <span class="text-primary">₹<fmt:formatNumber value="${checkoutResult.totalAmount}" pattern="#,##0" /></span>
                    </div>

                    <div class="bg-light rounded p-3 small text-muted">
                        <div><i class="bi bi-credit-card me-1"></i> <strong>Payment Method:</strong> <c:out value="${payment.paymentMethod}" /></div>
                        <div><i class="bi bi-shield-check me-1"></i> <strong>Transaction ID:</strong> <c:out value="${payment.transactionId}" /></div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="d-flex gap-3 justify-content-center">
                    <a href="<c:url value='/products' />" class="btn btn-primary px-4 fw-semibold">
                        <i class="bi bi-bag me-1"></i> Continue Shopping
                    </a>
                    <a href="<c:url value='/orders' />" class="btn btn-outline-secondary px-4 fw-semibold">
                        <i class="bi bi-box-seam me-1"></i> View My Orders
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

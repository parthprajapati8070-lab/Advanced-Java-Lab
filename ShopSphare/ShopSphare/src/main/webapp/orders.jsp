<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="My Orders - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <!-- Page Title -->
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h2 class="fw-bold mb-0"><i class="bi bi-box-seam me-2 text-primary"></i>My Order History</h2>
            <a href="<c:url value='/products' />" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i> Continue Shopping
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty orders}">
                <div class="row g-4">
                    <div class="col-12">
                        <c:forEach items="${orders}" var="order">
                            <div class="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden">
                                <div class="card-header bg-light py-3 px-4 border-bottom d-flex flex-wrap align-items-center justify-content-between gap-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <div>
                                            <small class="text-muted d-block text-uppercase" style="font-size: 0.75rem;">Order Number</small>
                                            <span class="fw-bold font-monospace"><c:out value="${order.orderNumber}" /></span>
                                        </div>
                                        <div class="border-start ps-3">
                                            <small class="text-muted d-block text-uppercase" style="font-size: 0.75rem;">Order Placed</small>
                                            <span class="fw-medium"><c:out value="${order.createdAt}" /></span>
                                        </div>
                                    </div>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="text-end">
                                            <small class="text-muted d-block text-uppercase" style="font-size: 0.75rem;">Total Amount</small>
                                            <span class="fw-bold text-primary fs-5">₹<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /></span>
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${'completed'.equalsIgnoreCase(order.orderStatus) || 'delivered'.equalsIgnoreCase(order.orderStatus)}">
                                                    <span class="badge bg-success-subtle text-success px-3 py-2 text-uppercase"><c:out value="${order.orderStatus}" /></span>
                                                </c:when>
                                                <c:when test="${'processing'.equalsIgnoreCase(order.orderStatus)}">
                                                    <span class="badge bg-primary-subtle text-primary px-3 py-2 text-uppercase"><c:out value="${order.orderStatus}" /></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary px-3 py-2 text-uppercase"><c:out value="${order.orderStatus}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body p-4">
                                    <div class="row text-secondary small">
                                        <div class="col-sm-4 mb-2">
                                            <strong>Subtotal:</strong> ₹<fmt:formatNumber value="${order.subtotal}" pattern="#,##0" />
                                        </div>
                                        <div class="col-sm-4 mb-2">
                                            <strong>Discount:</strong> -₹<fmt:formatNumber value="${order.discountAmount}" pattern="#,##0" />
                                        </div>
                                        <div class="col-sm-4 mb-2">
                                            <strong>Shipping & Tax:</strong> ₹<fmt:formatNumber value="${order.shippingFee + order.taxAmount}" pattern="#,##0" />
                                        </div>
                                    </div>
                                    <c:if test="${not empty order.notes}">
                                        <div class="alert alert-light border small text-muted mt-2 mb-0">
                                            <i class="bi bi-info-circle me-1"></i> Delivery Note: <c:out value="${order.notes}" />
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card border-0 shadow-sm rounded-4 text-center py-5 px-3">
                    <div class="card-body">
                        <i class="bi bi-inbox fs-1 text-muted" style="font-size: 4rem;"></i>
                        <h4 class="fw-bold mt-4 mb-2">No Orders Yet</h4>
                        <p class="text-muted mb-4">You haven't placed any orders yet. Discover great items in our catalog!</p>
                        <a href="<c:url value='/products' />" class="btn btn-primary px-4 py-2 fw-semibold">
                            Start Shopping
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

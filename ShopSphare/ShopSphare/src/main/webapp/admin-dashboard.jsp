<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Admin Dashboard - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <!-- Dashboard Header -->
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-shield-lock me-2 text-danger"></i>Admin Dashboard</h2>
                <p class="text-muted mb-0">System overview and management statistics</p>
            </div>
            <a href="<c:url value='/products' />" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i> Storefront
            </a>
        </div>

        <!-- Metrics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-6 col-lg-3">
                <div class="card border-0 shadow-sm rounded-4 p-4 text-center h-100">
                    <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mx-auto mb-3" style="width: 56px; height: 56px;">
                        <i class="bi bi-box-seam fs-3"></i>
                    </div>
                    <h3 class="fw-bold mb-1"><c:out value="${productCount != null ? productCount : 0}" /></h3>
                    <span class="text-muted small text-uppercase fw-semibold">Active Products</span>
                </div>
            </div>

            <div class="col-md-6 col-lg-3">
                <div class="card border-0 shadow-sm rounded-4 p-4 text-center h-100">
                    <div class="d-inline-flex align-items-center justify-content-center bg-warning-subtle text-warning-emphasis rounded-circle mx-auto mb-3" style="width: 56px; height: 56px;">
                        <i class="bi bi-receipt fs-3"></i>
                    </div>
                    <h3 class="fw-bold mb-1"><c:out value="${orderCount != null ? orderCount : 0}" /></h3>
                    <span class="text-muted small text-uppercase fw-semibold">Total Orders</span>
                </div>
            </div>

            <div class="col-md-6 col-lg-3">
                <div class="card border-0 shadow-sm rounded-4 p-4 text-center h-100">
                    <div class="d-inline-flex align-items-center justify-content-center bg-success-subtle text-success rounded-circle mx-auto mb-3" style="width: 56px; height: 56px;">
                        <i class="bi bi-people fs-3"></i>
                    </div>
                    <h3 class="fw-bold mb-1"><c:out value="${userCount != null ? userCount : 0}" /></h3>
                    <span class="text-muted small text-uppercase fw-semibold">Registered Users</span>
                </div>
            </div>

            <div class="col-md-6 col-lg-3">
                <div class="card border-0 shadow-sm rounded-4 p-4 text-center h-100">
                    <div class="d-inline-flex align-items-center justify-content-center bg-info-subtle text-info rounded-circle mx-auto mb-3" style="width: 56px; height: 56px;">
                        <i class="bi bi-shield-check fs-3"></i>
                    </div>
                    <h3 class="fw-bold mb-1">Active</h3>
                    <span class="text-muted small text-uppercase fw-semibold">System Security</span>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

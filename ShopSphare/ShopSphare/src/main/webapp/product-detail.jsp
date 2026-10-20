<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="${product.name} - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<c:url value='/products' />" class="text-decoration-none">Catalog</a></li>
                <li class="breadcrumb-item active" aria-current="page"><c:out value="${product.name}" /></li>
            </ol>
        </nav>

        <div class="card border-0 shadow-sm rounded-4 overflow-hidden p-4 p-md-5 mb-5">
            <div class="row g-4 align-items-center">
                <!-- Product Image Area -->
                <div class="col-md-5 text-center">
                    <div class="bg-light rounded-4 overflow-hidden border shadow-sm d-flex align-items-center justify-content-center p-3" style="min-height: 360px; max-height: 420px;">
                        <c:choose>
                            <c:when test="${not empty product.imageUrl}">
                                <img src="<c:url value='/${product.imageUrl}' />" 
                                     alt="<c:out value='${product.name}' />" 
                                     class="img-fluid rounded-3" 
                                     style="max-height: 380px; width: 100%; object-fit: contain;"
                                     onerror="this.onerror=null; this.src='<c:url value='/assets/images/products/fallback.jpg' />';">
                            </c:when>
                            <c:otherwise>
                                <img src="<c:url value='/assets/images/products/fallback.jpg' />" 
                                     alt="<c:out value='${product.name}' />" 
                                     class="img-fluid rounded-3" 
                                     style="max-height: 380px; width: 100%; object-fit: contain;">
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Product Information -->
                <div class="col-md-7">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-secondary-subtle text-secondary font-monospace">SKU: <c:out value="${product.sku}" /></span>
                        <c:choose>
                            <c:when test="${product.stockQuantity > 0}">
                                <span class="badge bg-success-subtle text-success"><i class="bi bi-check-circle me-1"></i>In Stock (<c:out value="${product.stockQuantity}" /> available)</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-danger-subtle text-danger"><i class="bi bi-x-circle me-1"></i>Out of Stock</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h2 class="fw-bold mb-3"><c:out value="${product.name}" /></h2>

                    <!-- Price Section -->
                    <div class="mb-3 d-flex align-items-baseline gap-3">
                        <c:choose>
                            <c:when test="${not empty product.salePrice && product.salePrice > 0}">
                                <span class="display-6 fw-bold text-danger">₹<fmt:formatNumber value="${product.salePrice}" pattern="#,##0" /></span>
                                <span class="fs-4 text-muted text-decoration-line-through">₹<fmt:formatNumber value="${product.price}" pattern="#,##0" /></span>
                                <c:if test="${product.discountPercentage > 0}">
                                    <span class="badge bg-danger fs-6">-<c:out value="${product.discountPercentage}" />% OFF</span>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <span class="display-6 fw-bold text-dark">₹<fmt:formatNumber value="${product.price}" pattern="#,##0" /></span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Description -->
                    <p class="text-muted leading-relaxed mb-4">
                        <c:out value="${product.description != null ? product.description : 'High-quality item designed to deliver exceptional performance and durability.'}" />
                    </p>

                    <hr class="my-4">

                    <!-- Add to Cart Form -->
                    <form method="POST" action="<c:url value='/cart' />" class="d-flex align-items-center gap-3">
                        <input type="hidden" name="action" value="add"/>
                        <input type="hidden" name="productId" value="<c:out value='${product.productId}' />"/>

                        <div class="d-flex align-items-center gap-2">
                            <label class="form-label small fw-semibold mb-0">Qty:</label>
                            <input type="number" name="quantity" class="form-control form-control-lg text-center" 
                                   value="1" min="1" max="${product.stockQuantity > 0 ? product.stockQuantity : 1}" 
                                   style="width: 80px;" ${product.stockQuantity <= 0 ? 'disabled' : ''} required>
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg px-4 fw-semibold d-flex align-items-center gap-2 flex-grow-1 flex-sm-grow-0"
                                ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                            <i class="bi bi-cart-plus fs-5"></i>
                            <span>${product.stockQuantity > 0 ? 'Add to Cart' : 'Out of Stock'}</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

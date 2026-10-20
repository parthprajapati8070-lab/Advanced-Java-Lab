<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:if test="${products == null}">
    <c:redirect url="/products" />
</c:if>

<c:set var="pageTitle" value="ShopSphere - Home & Products" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-4">
    <div class="container-xxl">
        <!-- Hero Banner (Applied: Fitts's Law, Hick's Law, Von Restorff Effect & Aesthetic-Usability) -->
        <div class="hero-banner mb-4 rounded-4 text-white position-relative overflow-hidden shadow-lg">
            <div class="row align-items-center g-4 position-relative z-1 p-4 p-md-5">
                <!-- Left Column: Compelling Hook, Value Prop, CTAs & Quick Filters -->
                <div class="col-lg-7">
                    <!-- Promo Badge with Pulse Dot (Von Restorff Effect) -->
                    <div class="d-inline-flex align-items-center gap-2 px-3 py-1 mb-3 rounded-pill hero-badge">
                        <span class="pulse-indicator"></span>
                        <span class="small fw-semibold">✨ FESTIVE SALE • UP TO 40% OFF</span>
                    </div>

                    <h1 class="display-4 fw-bold hero-headline mb-3">
                        Next-Gen Products,<br>
                        <span class="hero-gradient-text">Elevated Everyday.</span>
                    </h1>

                    <p class="hero-lead text-white-50 mb-4 fs-6">
                        Explore handpicked collections across top electronics, premium apparel, and modern lifestyle essentials with verified fast delivery across India.
                    </p>

                    <!-- Dual CTAs (Fitts's Law: Clear affordance & proportional sizing) -->
                    <div class="d-flex flex-wrap gap-3 mb-4">
                        <a href="#catalog" class="btn btn-primary btn-lg rounded-pill px-4 py-2 fw-semibold hero-cta-primary d-inline-flex align-items-center gap-2 shadow">
                            <span>Shop Best Deals</span>
                            <i class="bi bi-arrow-right"></i>
                        </a>
                        <a href="<c:url value='/products?category=1' />" class="btn btn-outline-light btn-lg rounded-pill px-4 py-2 fw-semibold hero-cta-secondary d-inline-flex align-items-center gap-2">
                            <i class="bi bi-lightning-charge-fill text-warning"></i>
                            <span>Top Electronics</span>
                        </a>
                    </div>

                    <!-- Quick Jump Trending Tags (Hick's Law: Minimal cognitive load) -->
                    <div class="d-flex flex-wrap align-items-center gap-2 text-white-50 small">
                        <span class="text-uppercase fw-bold text-white-50" style="font-size: 0.72rem; letter-spacing: 0.5px;">Trending:</span>
                        <a href="<c:url value='/products?q=laptop' />" class="badge rounded-pill hero-tag">💻 Laptops</a>
                        <a href="<c:url value='/products?q=headphones' />" class="badge rounded-pill hero-tag">🎧 ANC Audio</a>
                        <a href="<c:url value='/products?q=sneakers' />" class="badge rounded-pill hero-tag">👟 Sneakers</a>
                        <a href="<c:url value='/products?q=smartwatch' />" class="badge rounded-pill hero-tag">⌚ Smartwatches</a>
                        <a href="<c:url value='/products?q=lamp' />" class="badge rounded-pill hero-tag">💡 Home Decor</a>
                    </div>
                </div>

                <!-- Right Column: Interactive / Floating Product Showcase (replaces dead wireframe icon) -->
                <div class="col-lg-5 d-none d-lg-block">
                    <div class="hero-showcase-container position-relative px-2">
                        <!-- Main Showcase Card -->
                        <div class="showcase-card shadow-lg p-3 rounded-4 bg-white text-dark position-relative">
                            <div class="showcase-img-wrap rounded-3 overflow-hidden position-relative mb-3 bg-light">
                                <img src="<c:url value='/assets/images/products/headphones-01.jpg' />" 
                                     alt="Featured Best Seller" 
                                     class="img-fluid w-100 showcase-img" 
                                     style="height: 180px; object-fit: cover;"
                                     onerror="this.src='<c:url value='/assets/images/products/fallback.jpg' />'">
                                <span class="badge bg-danger position-absolute top-0 start-0 m-2 px-2 py-1 shadow-sm">
                                    🔥 BESTSELLER #1
                                </span>
                                <span class="badge bg-dark position-absolute top-0 end-0 m-2 px-2 py-1">
                                    -20% OFF
                                </span>
                            </div>

                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <h6 class="fw-bold mb-1">AcousticPro ANC Headphones</h6>
                                    <div class="d-flex align-items-center gap-1 text-warning small">
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <i class="bi bi-star-fill"></i>
                                        <span class="text-muted ms-1 fw-semibold">(4.9 • 1.8k reviews)</span>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                <div>
                                    <span class="fs-5 fw-bold text-dark">₹7,999</span>
                                    <span class="text-muted text-decoration-line-through small ms-1">₹9,999</span>
                                </div>
                                <a href="<c:url value='/products/3' />" class="btn btn-primary btn-sm rounded-pill px-3 fw-semibold">
                                    View Deal
                                </a>
                            </div>
                        </div>

                        <!-- Floating Glassmorphic Chip 1: Promo Code -->
                        <div class="floating-chip floating-chip-1 shadow d-flex align-items-center gap-2 py-2 px-3 rounded-pill">
                            <i class="bi bi-ticket-perforated-fill text-warning fs-5"></i>
                            <div>
                                <div class="fw-bold text-white small" style="font-size: 0.78rem;">Code: SAVE10</div>
                                <div class="text-white-50" style="font-size: 0.68rem;">Extra 10% Off ₹500+</div>
                            </div>
                        </div>

                        <!-- Floating Glassmorphic Chip 2: Trust & Shipping -->
                        <div class="floating-chip floating-chip-2 shadow d-flex align-items-center gap-2 py-2 px-3 rounded-pill">
                            <div class="rounded-circle bg-success-subtle text-success p-1 d-flex align-items-center justify-content-center" style="width: 26px; height: 26px;">
                                <i class="bi bi-shield-check fs-6"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-white small" style="font-size: 0.78rem;">100% Genuine Certified</div>
                                <div class="text-white-50" style="font-size: 0.68rem;">Free Shipping over ₹999</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trust & Value Proposition Strip (Jakob's Law: E-Commerce Mental Model) -->
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="trust-card p-3 rounded-4 shadow-sm bg-white d-flex align-items-center gap-3 h-100">
                    <div class="trust-icon-box bg-primary-subtle text-primary rounded-circle">
                        <i class="bi bi-truck fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark small">Free Delivery</h6>
                        <small class="text-muted" style="font-size: 0.75rem;">On orders over ₹999</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="trust-card p-3 rounded-4 shadow-sm bg-white d-flex align-items-center gap-3 h-100">
                    <div class="trust-icon-box bg-success-subtle text-success rounded-circle">
                        <i class="bi bi-shield-check fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark small">100% Genuine</h6>
                        <small class="text-muted" style="font-size: 0.75rem;">Authentic guaranteed</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="trust-card p-3 rounded-4 shadow-sm bg-white d-flex align-items-center gap-3 h-100">
                    <div class="trust-icon-box bg-warning-subtle text-warning-emphasis rounded-circle">
                        <i class="bi bi-arrow-repeat fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark small">7-Day Returns</h6>
                        <small class="text-muted" style="font-size: 0.75rem;">Hassle-free replacement</small>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="trust-card p-3 rounded-4 shadow-sm bg-white d-flex align-items-center gap-3 h-100">
                    <div class="trust-icon-box bg-info-subtle text-info-emphasis rounded-circle">
                        <i class="bi bi-credit-card-2-front fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark small">Flexible Payment</h6>
                        <small class="text-muted" style="font-size: 0.75rem;">Cards, UPI &amp; COD</small>
                    </div>
                </div>
            </div>
        </div>

        <c:if test="${param.loggedOut == 'true'}">
            <div class="alert alert-info alert-dismissible fade show mb-4" role="alert">
                <i class="bi bi-info-circle-fill me-2"></i>
                You have been signed out successfully.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Main Layout: Sidebar & Products Grid -->
        <div class="row g-4" id="catalog">
            <!-- Sidebar -->
            <div class="col-lg-3">
                <jsp:include page="/WEB-INF/fragments/sidebar.jsp" />
            </div>

            <!-- Product Grid -->
            <div class="col-lg-9">
                <!-- Sorting & Stats Bar -->
                <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
                    <div>
                        <h4 class="fw-bold mb-0">Products</h4>
                        <small class="text-muted">
                            <c:choose>
                                <c:when test="${not empty products}">Showing <c:out value="${products.size()}" /> items</c:when>
                                <c:otherwise>0 products found</c:otherwise>
                            </c:choose>
                        </small>
                    </div>
                </div>

                <!-- Product Grid Rendering via JSTL -->
                <c:choose>
                    <c:when test="${not empty products}">
                        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-4 g-3 g-xl-4">
                            <c:forEach items="${products}" var="product">
                                <div class="col">
                                    <div class="card product-card">
                                        <!-- Product Image & Discount Badge -->
                                        <div class="product-image-wrapper">
                                            <a href="<c:url value='/products/${product.productId}' />" class="d-block w-100 h-100">
                                                <c:choose>
                                                    <c:when test="${not empty product.imageUrl}">
                                                        <img src="<c:url value='/${product.imageUrl}' />" 
                                                             class="product-img" 
                                                             alt="<c:out value='${product.name}' />"
                                                             loading="lazy"
                                                             onerror="this.onerror=null; this.src='<c:url value='/assets/images/products/fallback.jpg' />';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="<c:url value='/assets/images/products/fallback.jpg' />" 
                                                             class="product-img" 
                                                             alt="<c:out value='${product.name}' />"
                                                             loading="lazy">
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                            <c:if test="${not empty product.salePrice && product.salePrice > 0 && product.discountPercentage > 0}">
                                                <span class="badge bg-danger product-badge shadow-sm">
                                                    -<c:out value="${product.discountPercentage}" />% OFF
                                                </span>
                                            </c:if>
                                        </div>

                                        <!-- Card Body -->
                                        <div class="card-body product-body">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <small class="text-uppercase text-muted fw-semibold" style="font-size: 0.72rem;">
                                                    SKU: <c:out value="${product.sku}" />
                                                </small>
                                                <c:choose>
                                                    <c:when test="${product.stockQuantity > 0}">
                                                        <span class="badge bg-success-subtle text-success small">In Stock</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger-subtle text-danger small">Sold Out</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <h5 class="product-title" title="<c:out value='${product.name}' />">
                                                <a href="<c:url value='/products/${product.productId}' />">
                                                    <c:out value="${product.name}" />
                                                </a>
                                            </h5>

                                            <p class="product-desc" title="<c:out value='${product.description}' />">
                                                <c:out value="${product.description != null ? product.description : 'Premium quality item tailored to your daily needs.'}" />
                                            </p>

                                            <!-- Price & Action Section -->
                                            <div class="product-price-section">
                                                <div class="d-flex align-items-baseline mb-3">
                                                    <c:choose>
                                                        <c:when test="${not empty product.salePrice && product.salePrice > 0}">
                                                            <span class="current-price">₹<fmt:formatNumber value="${product.salePrice}" pattern="#,##0" /></span>
                                                            <span class="original-price">₹<fmt:formatNumber value="${product.price}" pattern="#,##0" /></span>
                                                            <c:if test="${product.discountPercentage > 0}">
                                                                <span class="discount-tag"><c:out value="${product.discountPercentage}" />% off</span>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="current-price">₹<fmt:formatNumber value="${product.price}" pattern="#,##0" /></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <!-- Buttons: View Details & Add To Cart -->
                                                <div class="d-flex gap-2">
                                                    <a href="<c:url value='/products/${product.productId}' />" 
                                                       class="btn btn-outline-secondary btn-sm flex-fill d-flex align-items-center justify-content-center gap-1"
                                                       title="View Details">
                                                        <i class="bi bi-eye"></i>
                                                        <span>Details</span>
                                                    </a>
                                                    <form method="POST" action="<c:url value='/cart' />" class="flex-fill m-0">
                                                        <input type="hidden" name="action" value="add"/>
                                                        <input type="hidden" name="productId" value="<c:out value='${product.productId}' />"/>
                                                        <input type="hidden" name="quantity" value="1"/>
                                                        <button type="submit" class="btn btn-primary btn-sm w-100 d-flex align-items-center justify-content-center gap-1"
                                                                ${product.stockQuantity <= 0 ? 'disabled' : ''}>
                                                            <i class="bi bi-cart-plus"></i>
                                                            <span>${product.stockQuantity > 0 ? 'Add' : 'Out'}</span>
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Pagination -->
                        <nav aria-label="Page navigation" class="mt-5">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${param.page <= 1 || empty param.page ? 'disabled' : ''}">
                                    <a class="page-link" href="<c:url value='/products?page=${(param.page != null ? param.page : 1) - 1}' />">Previous</a>
                                </li>
                                <li class="page-item active"><a class="page-link" href="#"><c:out value="${param.page != null ? param.page : 1}" /></a></li>
                                <li class="page-item">
                                    <a class="page-link" href="<c:url value='/products?page=${(param.page != null ? param.page : 1) + 1}' />">Next</a>
                                </li>
                            </ul>
                        </nav>
                    </c:when>
                    <c:otherwise>
                        <!-- Empty State -->
                        <div class="text-center py-5 bg-white rounded-3 shadow-sm p-4">
                            <i class="bi bi-inbox fs-1 text-muted"></i>
                            <h5 class="mt-3 fw-bold">No Products Found</h5>
                            <p class="text-muted">No items matched your current filter criteria.</p>
                            <a href="<c:url value='/products' />" class="btn btn-outline-primary btn-sm mt-2">Clear Filters</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />


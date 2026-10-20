<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<header>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow-sm py-2 shopsphere-navbar">
        <div class="container-xxl">
            <!-- Brand -->
            <a class="navbar-brand d-flex align-items-center gap-2 me-lg-4" href="<c:url value='/products' />">
                <div class="brand-icon-wrapper rounded-3 d-flex align-items-center justify-content-center bg-primary bg-gradient text-white shadow-sm" style="width: 36px; height: 36px;">
                    <i class="bi bi-bag-check-fill fs-5"></i>
                </div>
                <span class="fw-bold tracking-tight text-white fs-4">Shop<span class="text-primary">Sphere</span></span>
            </a>

            <!-- Mobile Toggle -->
            <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent"
                    aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- Navbar Links & Search -->
            <div class="collapse navbar-collapse" id="navbarContent">
                <!-- Quick Category Links (Hick's Law: Direct Category Access) -->
                <ul class="navbar-nav me-auto mb-2 mb-lg-0 gap-1">
                    <li class="nav-item">
                        <a class="nav-link py-1 px-3 rounded-pill nav-cat-link ${empty param.category && empty param.q ? 'active' : ''}" 
                           href="<c:url value='/products' />">
                            <i class="bi bi-grid-fill me-1 small"></i> All
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link py-1 px-3 rounded-pill nav-cat-link ${param.category == '1' ? 'active' : ''}" 
                           href="<c:url value='/products?category=1' />">
                            <i class="bi bi-laptop me-1 text-primary small"></i> Tech
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link py-1 px-3 rounded-pill nav-cat-link ${param.category == '2' ? 'active' : ''}" 
                           href="<c:url value='/products?category=2' />">
                            <i class="bi bi-tag-fill me-1 text-danger small"></i> Fashion
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link py-1 px-3 rounded-pill nav-cat-link ${param.category == '3' ? 'active' : ''}" 
                           href="<c:url value='/products?category=3' />">
                            <i class="bi bi-house-door-fill me-1 text-success small"></i> Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link py-1 px-3 rounded-pill nav-cat-link ${param.category == '4' ? 'active' : ''}" 
                           href="<c:url value='/products?category=4' />">
                            <i class="bi bi-smartwatch me-1 text-warning small"></i> Accessories
                        </a>
                    </li>
                </ul>

                <!-- Search Bar (Fitts's Law: Large clickable area, pill ergonomics) -->
                <form class="d-flex my-2 my-lg-0 me-lg-3 flex-grow-1" role="search" method="GET" action="<c:url value='/products' />" style="max-width: 360px;">
                    <div class="input-group search-pill-group w-100">
                        <span class="input-group-text bg-white border-end-0 rounded-start-pill ps-3 text-muted">
                            <i class="bi bi-search"></i>
                        </span>
                        <input class="form-control form-control-sm border-start-0 border-end-0 py-2 ps-1 shadow-none" 
                               type="search" name="q" placeholder="Search laptops, sneakers..." 
                               aria-label="Search" value="<c:out value='${param.q}' />">
                        <button class="btn btn-primary rounded-end-pill px-3 py-2 btn-sm fw-semibold" type="submit">
                            Search
                        </button>
                    </div>
                </form>

                <!-- Right Side Actions: Cart & Auth (Miller's Law / Chunking) -->
                <div class="d-flex align-items-center gap-2 mt-3 mt-lg-0">
                    <!-- Shopping Cart Pill -->
                    <a href="<c:url value='/cart' />" class="btn btn-outline-light btn-sm rounded-pill px-3 py-2 position-relative d-flex align-items-center gap-2 border-opacity-25">
                        <i class="bi bi-cart3 fs-6"></i>
                        <span class="d-none d-md-inline fw-medium">Cart</span>
                        <span class="badge rounded-pill bg-warning text-dark fw-bold px-2">
                            <c:out value="${sessionScope.cartCount != null ? sessionScope.cartCount : 0}" />
                        </span>
                    </a>

                    <!-- User Account / Auth Dropdown -->
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <div class="dropdown">
                                <button class="btn btn-secondary btn-sm rounded-pill px-3 py-2 dropdown-toggle d-flex align-items-center gap-2 shadow-sm"
                                        type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="bi bi-person-circle fs-6"></i>
                                    <span class="fw-medium"><c:out value="${sessionScope.user.firstName}" /></span>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow-lg rounded-3 border-0 mt-2 p-2">
                                    <li>
                                        <h6 class="dropdown-header text-truncate" style="max-width: 200px;">
                                            Signed in as<br><strong><c:out value="${sessionScope.user.email}" /></strong>
                                        </h6>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <a class="dropdown-item rounded-2 py-2" href="<c:url value='/profile' />">
                                            <i class="bi bi-person me-2 text-primary"></i> My Profile
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item rounded-2 py-2" href="<c:url value='/orders' />">
                                            <i class="bi bi-box-seam me-2 text-success"></i> My Orders
                                        </a>
                                    </li>
                                    <c:if test="${'ADMIN'.equalsIgnoreCase(sessionScope.user.role)}">
                                        <li><hr class="dropdown-divider"></li>
                                        <li>
                                            <a class="dropdown-item rounded-2 py-2 text-danger fw-semibold" href="<c:url value='/admin/dashboard' />">
                                                <i class="bi bi-shield-lock me-2"></i> Admin Panel
                                            </a>
                                        </li>
                                    </c:if>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <a class="dropdown-item rounded-2 py-2 text-danger" href="<c:url value='/logout' />">
                                            <i class="bi bi-box-arrow-right me-2"></i> Sign Out
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="<c:url value='/login' />" class="btn btn-outline-light btn-sm rounded-pill px-3 py-2 fw-medium border-opacity-25">
                                Sign In
                            </a>
                            <a href="<c:url value='/register' />" class="btn btn-primary btn-sm rounded-pill px-3 py-2 fw-semibold shadow-sm">
                                Register
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </nav>
</header>


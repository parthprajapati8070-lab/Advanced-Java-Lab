<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Sign In - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mb-3" style="width: 64px; height: 64px;">
                            <i class="bi bi-person-fill-lock fs-2"></i>
                        </div>
                        <h3 class="fw-bold">Welcome Back</h3>
                        <p class="text-muted small">Sign in to your ShopSphere account to continue</p>
                    </div>

                    <c:if test="${param.registered == 'true'}">
                        <div class="alert alert-success alert-dismissible fade show small mb-3" role="alert">
                            <i class="bi bi-check-circle-fill me-2"></i>
                            Account created successfully! Please sign in with your credentials.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${param.loggedOut == 'true'}">
                        <div class="alert alert-info alert-dismissible fade show small mb-3" role="alert">
                            <i class="bi bi-info-circle-fill me-2"></i>
                            You have been signed out safely.
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show small mb-3" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <c:out value="${error}" />
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form method="POST" action="<c:url value='/login' />">
                        <input type="hidden" name="redirect" value="<c:out value='${redirectUrl != null ? redirectUrl : param.redirect}' />"/>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                <input type="email" name="email" class="form-control border-start-0" 
                                       placeholder="you@example.com" value="<c:out value='${param.email}' />" required autofocus>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-semibold">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-key text-muted"></i></span>
                                <input type="password" name="password" class="form-control border-start-0" 
                                       placeholder="••••••••" required>
                            </div>
                        </div>

                        <div class="d-grid mb-3">
                            <button type="submit" class="btn btn-primary btn-lg fw-semibold">Sign In</button>
                        </div>
                    </form>

                    <div class="text-center mt-3 pt-3 border-top">
                        <span class="text-muted small">New to ShopSphere?</span>
                        <a href="<c:url value='/register' />" class="small fw-semibold text-decoration-none ms-1">Create an account</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

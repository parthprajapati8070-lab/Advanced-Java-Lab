<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Create Account - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-6">
                <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center bg-primary-subtle text-primary rounded-circle mb-3" style="width: 64px; height: 64px;">
                            <i class="bi bi-person-plus-fill fs-2"></i>
                        </div>
                        <h3 class="fw-bold">Create an Account</h3>
                        <p class="text-muted small">Join ShopSphere to manage your cart, orders, and addresses</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show small mb-3" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <c:out value="${error}" />
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form method="POST" action="<c:url value='/register' />">
                        <div class="row g-3 mb-3">
                            <div class="col-sm-6">
                                <label class="form-label small fw-semibold">First Name</label>
                                <input type="text" name="firstName" class="form-control" placeholder="John" 
                                       value="<c:out value='${param.firstName}' />" required>
                            </div>
                            <div class="col-sm-6">
                                <label class="form-label small fw-semibold">Last Name</label>
                                <input type="text" name="lastName" class="form-control" placeholder="Doe" 
                                       value="<c:out value='${param.lastName}' />" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Email Address</label>
                            <input type="email" name="email" class="form-control" placeholder="john.doe@example.com" 
                                   value="<c:out value='${param.email}' />" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Password</label>
                            <input type="password" name="password" class="form-control" placeholder="Minimum 8 characters" 
                                   minlength="8" required>
                            <small class="text-muted">Must be at least 8 characters.</small>
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-semibold">Phone Number (Optional)</label>
                            <input type="tel" name="phoneNumber" class="form-control" placeholder="+1 (555) 000-0000" 
                                   value="<c:out value='${param.phoneNumber}' />">
                        </div>

                        <div class="d-grid mb-3">
                            <button type="submit" class="btn btn-primary btn-lg fw-semibold">Register Account</button>
                        </div>
                    </form>

                    <div class="text-center mt-3 pt-3 border-top">
                        <span class="text-muted small">Already have an account?</span>
                        <a href="<c:url value='/login' />" class="small fw-semibold text-decoration-none ms-1">Sign in here</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

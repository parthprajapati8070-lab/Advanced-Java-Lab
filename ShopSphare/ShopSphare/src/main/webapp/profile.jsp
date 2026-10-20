<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="My Profile - ShopSphere" scope="request" />
<jsp:include page="/WEB-INF/fragments/header.jsp" />
<jsp:include page="/WEB-INF/fragments/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <!-- User Profile Card -->
                <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5 mb-4">
                    <div class="d-flex align-items-center gap-4 mb-4">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fs-1 fw-bold" style="width: 80px; height: 80px;">
                            <c:out value="${user.firstName.substring(0, 1)}" />
                        </div>
                        <div>
                            <h3 class="fw-bold mb-1"><c:out value="${user.firstName} ${user.lastName}" /></h3>
                            <span class="badge bg-primary-subtle text-primary text-uppercase me-2"><c:out value="${user.role}" /></span>
                            <span class="badge bg-success-subtle text-success text-uppercase"><c:out value="${user.status}" /></span>
                        </div>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label small text-muted text-uppercase fw-semibold">Email Address</label>
                            <div class="p-2 bg-light rounded"><c:out value="${user.email}" /></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small text-muted text-uppercase fw-semibold">Phone Number</label>
                            <div class="p-2 bg-light rounded"><c:out value="${user.phoneNumber != null ? user.phoneNumber : 'Not provided'}" /></div>
                        </div>
                    </div>
                </div>

                <!-- Saved Addresses Card -->
                <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0"><i class="bi bi-geo-alt me-2 text-primary"></i>Saved Delivery Addresses</h5>
                    </div>

                    <c:choose>
                        <c:when test="${not empty addresses}">
                            <div class="list-group">
                                <c:forEach items="${addresses}" var="addr">
                                    <div class="list-group-item p-3 rounded mb-2 border">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <strong><c:out value="${addr.recipientName}" /></strong>
                                            <span class="badge bg-light text-dark"><c:out value="${addr.addressType}" /></span>
                                        </div>
                                        <div class="text-muted small mt-1">
                                            <c:out value="${addr.streetAddressLine1}" />
                                            <c:if test="${not empty addr.streetAddressLine2}">, <c:out value="${addr.streetAddressLine2}" /></c:if><br>
                                            <c:out value="${addr.city}" />, <c:out value="${addr.state}" /> <c:out value="${addr.postalCode}" />, <c:out value="${addr.country}" />
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted small mb-0">No saved addresses yet. Addresses are saved automatically during checkout.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp" />

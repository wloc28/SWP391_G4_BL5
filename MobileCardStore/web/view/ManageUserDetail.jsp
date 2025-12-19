<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi tiết người dùng</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container py-4">
            <h2 class="mb-3">Chi tiết người dùng</h2>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <c:if test="${not empty user}">
                <div class="row">
                    <div class="col-md-12">
                        <div class="card shadow-sm mb-3">
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <h5 class="card-title mb-1">${user.username}</h5>
                                        <div class="text-muted small">${user.email}</div>
                                    </div>
                                    <div>
                                        <span class="badge bg-secondary me-2">${user.role}</span>
                                        <c:choose>
                                            <c:when test="${user.status == 'ACTIVE'}">
                                                <span class="badge bg-success">ACTIVE</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger">BANNED</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <hr>
                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Họ tên</div>
                                        <div class="fw-semibold">${user.fullName}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Số điện thoại</div>
                                        <div class="fw-semibold">${user.phoneNumber}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Số dư</div>
                                        <div class="fw-semibold"><fmt:formatNumber value="${user.balance}" type="number" maxFractionDigits="0" /> đ</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Ngày tạo</div>
                                        <div class="fw-semibold"><fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex gap-3 flex-wrap">
                            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left"></i> Quay lại danh sách
                            </a>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>

        <%@include file="../components/footer.jsp" %>
        <!-- Hành động khoá/chỉnh sửa đã được loại bỏ để đồng bộ với các trang quản lý khác -->
    </body>
</html>

